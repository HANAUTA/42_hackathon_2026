-- プロフィール画面向け users カラム追加マイグレーション（既存DB向け）
-- 名前の編集に加えて自己紹介(bio)と更新日時(updated_at)を扱えるようにする。
-- schema.sql はテーブルをdrop&再作成するためデータが消える。データ投入済みのDBには
-- こちらの ALTER を Supabase の SQL Editor で実行する（再実行可能）。

alter table public.users
  add column if not exists bio text;
alter table public.users
  add column if not exists updated_at timestamptz not null default now();

-- updated_at をUPDATE時に自動更新するトリガ（再実行可能）。
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists users_set_updated_at on public.users;
create trigger users_set_updated_at
  before update on public.users
  for each row execute function public.set_updated_at();
