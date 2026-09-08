-- =====================================================================
--  VitalHub — Sincronizar na nuvem: fechamento, histórico, orçamento e provisões
--
--  Cria 3 tabelas compartilhadas pela equipe:
--   • fechamentos  → meses travados (fechamento mensal)
--   • auditoria    → histórico de alterações (quem fez o quê)
--   • app_config   → configurações, provisões, metas de orçamento e
--                    valores mensais de pró-labore (guardados em JSON)
--
--  Seguro: não apaga dados. Rode no Supabase:
--  Dashboard > SQL Editor > New query > cole tudo > Run.
-- =====================================================================

create table if not exists public.fechamentos (
  mes       text primary key,             -- 'AAAA-MM'
  owner     uuid default auth.uid() references auth.users(id) on delete cascade,
  quem      text,
  criado_em timestamptz not null default now()
);

create table if not exists public.auditoria (
  id      text primary key,
  owner   uuid default auth.uid() references auth.users(id) on delete cascade,
  quando  timestamptz not null default now(),
  quem    text,
  acao    text not null,
  detalhe text
);

create table if not exists public.app_config (
  chave        text primary key,          -- 'config' | 'mensalCfg' | 'orcamentos'
  owner        uuid default auth.uid() references auth.users(id) on delete cascade,
  valor        jsonb not null default '{}'::jsonb,
  atualizado_em timestamptz not null default now()
);

-- ---------------- Acesso compartilhado pela equipe ----------------
do $$
declare t text;
begin
  foreach t in array array['fechamentos','auditoria','app_config']
  loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('drop policy if exists "owner_all"  on public.%I;', t);
    execute format('drop policy if exists "equipe_all" on public.%I;', t);
    execute format('create policy "equipe_all" on public.%I for all to authenticated using (true) with check (true);', t);
    begin
      execute format('alter table public.%I alter column owner drop not null;', t);
    exception when others then null;
    end;
  end loop;
end $$;

create index if not exists idx_auditoria_quando on public.auditoria (quando desc);

-- =====================================================================
--  Pronto. Depois de rodar, o fechamento de mês, o histórico, as metas de
--  orçamento e as provisões passam a valer para você e para os sócios.
-- =====================================================================
