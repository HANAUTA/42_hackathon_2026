-- マイグレーション: post_shares に user_id を追加する（データを保持したまま）
-- 「1グループ・同じ時間帯に1回」を “グループ全体” から “ユーザーごと” に直すための変更。
-- 既存データがある本番/開発DBに対して、Supabase の SQL Editor で1回だけ実行する。
-- ※ schema.sql は既に user_id 入りに更新済み。新規にDBを作る場合は schema.sql を使えばよい。

-- 1) user_id カラムを追加（まずは NULL 許容で追加）
alter table public.post_shares
  add column if not exists user_id uuid references public.users (id) on delete cascade;

-- 2) 既存行を posts.user_id で埋める
update public.post_shares ps
  set user_id = p.user_id
  from public.posts p
  where ps.post_id = p.id and ps.user_id is null;

-- 3) NOT NULL 化
alter table public.post_shares
  alter column user_id set not null;

-- 4) 一意制約を貼り替え（グループ全体 → ユーザー単位）
alter table public.post_shares
  drop constraint if exists post_shares_group_id_shared_date_shared_hour_key;
alter table public.post_shares
  add constraint post_shares_group_user_date_hour_key
  unique (group_id, user_id, shared_date, shared_hour);

-- 5) RLS の insert ポリシーを更新（本人の投稿のみ）
drop policy if exists "post_shares_insert_owner" on public.post_shares;
create policy "post_shares_insert_owner" on public.post_shares
  for insert with check (
    auth.uid() = user_id
    and exists (
      select 1 from public.posts p
      where p.id = post_id and p.user_id = auth.uid()
    )
  );
