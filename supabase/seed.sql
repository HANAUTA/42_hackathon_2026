-- 開発用シードデータ（テスト用ダミーデータ）
-- Lane B/C/D が他レーンの完成を待たずに開発・確認できるようにするためのもの。
--
-- 【前提】Supabase Auth に自分のユーザーが1人いること。
--   まだ無い場合: Supabase ダッシュボード → Authentication → Users → Add user
--   （メール確認をOFFにしておくとアプリからもログインできる）
--
-- 【手順】
--   1. Authentication → Users で自分のUUIDをコピー
--   2. 下の v_user の 'PASTE-YOUR-AUTH-USER-UUID' を、そのUUIDに置き換える
--   3. SQL Editor に貼り付けて Run
--
-- ※ 再実行可能（先頭でこのユーザーのテストデータを消してから入れ直す）。

do $$
declare
  v_user uuid := 'PASTE-YOUR-AUTH-USER-UUID';  -- ← ここを自分のUUIDに置き換える
  v_group_a uuid;
  v_group_b uuid;
  v_post1 uuid;
  v_post2 uuid;
  v_post3 uuid;
  v_now_hour int := extract(hour from (now() at time zone 'Asia/Tokyo'))::int;
begin
  -- 既存のテストデータを削除（再実行用）
  delete from public.groups where invite_code in ('TESTAA', 'TESTBB');
  delete from public.posts where user_id = v_user;

  -- プロフィール
  insert into public.users (id, name)
    values (v_user, 'テスト太郎')
    on conflict (id) do update set name = excluded.name;

  -- グループ2つ作成（自分がowner）
  insert into public.groups (name, invite_code, owner_id)
    values ('テストグループA', 'TESTAA', v_user)
    returning id into v_group_a;
  insert into public.groups (name, invite_code, owner_id)
    values ('テストグループB', 'TESTBB', v_user)
    returning id into v_group_b;

  -- 両グループに自分が参加
  insert into public.group_members (group_id, user_id) values (v_group_a, v_user);
  insert into public.group_members (group_id, user_id) values (v_group_b, v_user);

  -- 投稿3件（再生確認用に公開サンプル動画URL）
  insert into public.posts (user_id, video_url)
    values (v_user, 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4')
    returning id into v_post1;
  insert into public.posts (user_id, video_url)
    values (v_user, 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4')
    returning id into v_post2;
  insert into public.posts (user_id, video_url)
    values (v_user, 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4')
    returning id into v_post3;

  -- 共有（グループAに現在時刻の時間帯 / 1つ前の時間帯、グループBに現在時刻）
  -- グループ詳細画面の「時間移動」を確認できるよう、複数の時間帯に配置。
  insert into public.post_shares (post_id, group_id, shared_date, shared_hour)
    values (v_post1, v_group_a, current_date, v_now_hour);
  insert into public.post_shares (post_id, group_id, shared_date, shared_hour)
    values (v_post2, v_group_a, current_date, greatest(v_now_hour - 1, 0));
  insert into public.post_shares (post_id, group_id, shared_date, shared_hour)
    values (v_post3, v_group_b, current_date, v_now_hour);
end $$;
