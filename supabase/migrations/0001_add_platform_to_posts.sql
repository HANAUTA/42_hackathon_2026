-- posts.platform 追加マイグレーション（既存DB向け）
-- 動画の性質上、Web動画はWebのみ・スマホ動画はスマホのみで取得できるよう棲み分ける。
-- schema.sql はテーブルをdrop&再作成するためデータが消える。データ投入済みのDBには
-- こちらの ALTER を Supabase の SQL Editor で実行する（再実行可能）。
--
-- 既存データには platform を持たないため 'mobile' を既定値とする
-- （= 既存動画はスマホでのみ表示される。Web限定にしたい行は後から個別に update する）。

alter table public.posts
  add column if not exists platform text not null default 'mobile';

alter table public.posts
  drop constraint if exists posts_platform_check;
alter table public.posts
  add constraint posts_platform_check check (platform in ('web', 'mobile'));
