-- アナリティクス用テーブル。Supabaseの SQL Editor で実行する。
create table if not exists analytics_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  event_name text not null,
  properties jsonb,
  created_at timestamptz not null default now()
);

-- RLSを無効にして全ユーザーから書き込み可能にする（ハッカソン用の簡易設定）。
alter table analytics_events enable row level security;

create policy "誰でもinsertできる"
  on analytics_events for insert
  with check (true);

create policy "誰でもselectできる"
  on analytics_events for select
  using (true);
