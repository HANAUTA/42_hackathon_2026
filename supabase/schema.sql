-- Setlog風アプリ Supabaseスキーマ
-- Supabase ダッシュボードの SQL Editor に貼り付けて実行する。
-- テーブル定義は docs/データベース設計.md と対応。
--
-- このスクリプトは「再実行可能」。先頭で既存テーブルを削除してから作り直すため、
-- 何度流しても同じ状態になる（※開発初期向け。データが入った後は実行しないこと）。

-- ============================================================
-- クリーンスタート（既存があれば削除）
-- ============================================================
drop table if exists public.post_shares cascade;
drop table if exists public.posts cascade;
drop table if exists public.group_members cascade;
drop table if exists public.groups cascade;
drop table if exists public.users cascade;

-- ============================================================
-- テーブル
-- ============================================================

-- users: ユーザー情報（Supabase AuthのユーザーIDと対応）
create table public.users (
  id uuid primary key references auth.users (id) on delete cascade,
  name text not null,
  icon_url text,
  created_at timestamptz not null default now()
);

-- groups: グループ
create table public.groups (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  invite_code text not null unique,
  owner_id uuid not null references public.users (id) on delete cascade,
  created_at timestamptz not null default now()
);

-- group_members: グループ参加メンバー
create table public.group_members (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups (id) on delete cascade,
  user_id uuid not null references public.users (id) on delete cascade,
  joined_at timestamptz not null default now(),
  unique (group_id, user_id)
);

-- posts: 投稿（動画本体）。共有先は post_shares で管理する。
-- needs_flip: 撮影時にファイル自体が上下逆で記録された動画(Android前面カメラ等)に立てる。
-- 再生時にこのフラグを見て180度回転して向きを補正する。
create table public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users (id) on delete cascade,
  video_url text not null,
  needs_flip boolean not null default false,
  created_at timestamptz not null default now()
);

-- post_shares: 投稿の共有先グループ。1投稿を複数グループへ共有できる。
-- shared_date(日付) と shared_hour(時) を明示的に持ち、
-- 「1グループ・同じユーザー・同じ日・同じ時間帯は1回まで」を一意制約で保証する（投稿ルール）。
-- ※制約に user_id を含めるため、誰か1人が投稿しても他メンバーは同じ時間帯に投稿できる。
-- 日付を式(created_at::date)で持つとIMMUTABLEでなくインデックスに使えないため、
-- 日本時間の日付をカラムとして保存する。
create table public.post_shares (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts (id) on delete cascade,
  group_id uuid not null references public.groups (id) on delete cascade,
  user_id uuid not null references public.users (id) on delete cascade,
  shared_date date not null default ((now() at time zone 'Asia/Tokyo')::date),
  shared_hour int not null check (shared_hour between 0 and 23),
  created_at timestamptz not null default now(),
  unique (group_id, user_id, shared_date, shared_hour)
);

-- 一覧取得を速くするためのインデックス
create index posts_user_created_idx
  on public.posts (user_id, created_at desc);
create index post_shares_group_idx
  on public.post_shares (group_id, created_at desc);
create index group_members_user_idx
  on public.group_members (user_id);

-- ============================================================
-- RLS（Row Level Security）
-- ============================================================
-- 方針: ログインユーザーは読み取り可。書き込みは本人のデータのみ。
-- ハッカソンMVP向けに緩めの設定。発表後に必要なら厳格化する。

alter table public.users enable row level security;
alter table public.groups enable row level security;
alter table public.group_members enable row level security;
alter table public.posts enable row level security;
alter table public.post_shares enable row level security;

-- users: 全員読める / 自分の行だけ作成・更新できる
create policy "users_select_all" on public.users
  for select using (true);
create policy "users_insert_self" on public.users
  for insert with check (auth.uid() = id);
create policy "users_update_self" on public.users
  for update using (auth.uid() = id);

-- groups: ログインユーザーは読める / 作成は本人がownerのときのみ
create policy "groups_select_all" on public.groups
  for select using (auth.role() = 'authenticated');
create policy "groups_insert_owner" on public.groups
  for insert with check (auth.uid() = owner_id);

-- group_members: ログインユーザーは読める / 参加・退出は自分の行のみ
create policy "group_members_select_all" on public.group_members
  for select using (auth.role() = 'authenticated');
create policy "group_members_insert_self" on public.group_members
  for insert with check (auth.uid() = user_id);
create policy "group_members_delete_self" on public.group_members
  for delete using (auth.uid() = user_id);

-- posts: ログインユーザーは読める / 投稿・削除は本人のみ
create policy "posts_select_all" on public.posts
  for select using (auth.role() = 'authenticated');
create policy "posts_insert_self" on public.posts
  for insert with check (auth.uid() = user_id);
create policy "posts_delete_self" on public.posts
  for delete using (auth.uid() = user_id);

-- post_shares: ログインユーザーは読める / 作成は本人の投稿のみ
create policy "post_shares_select_all" on public.post_shares
  for select using (auth.role() = 'authenticated');
create policy "post_shares_insert_owner" on public.post_shares
  for insert with check (
    auth.uid() = user_id
    and exists (
      select 1 from public.posts p
      where p.id = post_id and p.user_id = auth.uid()
    )
  );

-- ============================================================
-- Storage バケット
-- ============================================================
-- 動画とアイコン用のバケットを作成（公開読み取り）。

insert into storage.buckets (id, name, public)
values ('videos', 'videos', true)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('icons', 'icons', true)
on conflict (id) do nothing;

-- 認証ユーザーはアップロード可 / 読み取りは公開（再実行できるよう先に削除）
drop policy if exists "videos_read_public" on storage.objects;
drop policy if exists "videos_insert_auth" on storage.objects;
drop policy if exists "icons_read_public" on storage.objects;
drop policy if exists "icons_insert_auth" on storage.objects;

create policy "videos_read_public" on storage.objects
  for select using (bucket_id = 'videos');
create policy "videos_insert_auth" on storage.objects
  for insert with check (bucket_id = 'videos' and auth.role() = 'authenticated');

create policy "icons_read_public" on storage.objects
  for select using (bucket_id = 'icons');
create policy "icons_insert_auth" on storage.objects
  for insert with check (bucket_id = 'icons' and auth.role() = 'authenticated');
