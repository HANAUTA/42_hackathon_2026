-- users.icon_url 削除マイグレーション（既存DB向け）
-- アイコン機能は使わない方針のためカラムを削除する。
-- schema.sql はテーブルをdrop&再作成するためデータが消える。データ投入済みのDBには
-- こちらの ALTER を Supabase の SQL Editor で実行する（再実行可能）。

alter table public.users
  drop column if exists icon_url;
