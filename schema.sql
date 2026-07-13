-- =====================================================================
--  VitalHub · Controle de Caixa — Esquema do banco (Supabase / PostgreSQL)
--  Rode no Supabase:  Dashboard > SQL Editor > New query > cole tudo > Run.
--
--  ⚠️ IMPORTANTE: este script APAGA e RECRIA as tabelas com a estrutura
--     correta (ids de TEXTO). Rode-o mesmo que já tenha criado as tabelas
--     antes — a versão antiga usava outro tipo de id e por isso os dados
--     apareciam zerados. Faça isto com o banco ainda sem dados de verdade.
--
--  • RLS por auth.uid(): cada login só acessa os próprios dados.
--    → Para você e seu sócio compartilharem os MESMOS dados, usem o
--      MESMO login do Supabase (logins diferentes = bases separadas).
--  • IDs são TEXTO (gerados pelo app); valores monetários em CENTAVOS.
--  • Os dados de exemplo são criados automaticamente pelo app no 1º acesso.
-- =====================================================================

drop table if exists public.transferencias cascade;
drop table if exists public.recorrentes    cascade;
drop table if exists public.contas_pr       cascade;
drop table if exists public.lancamentos     cascade;
drop table if exists public.usuarios        cascade;
drop table if exists public.categorias      cascade;
drop table if exists public.contas          cascade;

create table public.contas (
  id            text primary key,
  owner         uuid not null default auth.uid() references auth.users(id) on delete cascade,
  nome          text not null,
  tipo          text not null default 'Banco',
  saldo_inicial bigint not null default 0,
  cor           text not null default '#1f4d3a',
  criado_em     timestamptz not null default now()
);

create table public.categorias (
  id        text primary key,
  owner     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  nome      text not null,
  tipo      text not null,
  cor       text not null default '#2f8d59',
  criado_em timestamptz not null default now()
);

create table public.usuarios (
  id            text primary key,
  owner         uuid not null default auth.uid() references auth.users(id) on delete cascade,
  nome          text not null,
  email         text not null,
  papel         text not null default 'Financeiro',
  status        text not null default 'ativo',
  ultimo_acesso date,
  criado_em     timestamptz not null default now()
);

create table public.lancamentos (
  id           text primary key,
  owner        uuid not null default auth.uid() references auth.users(id) on delete cascade,
  tipo         text not null,
  valor        bigint not null check (valor > 0),
  data         date not null,
  categoria_id text,
  conta_id     text,
  forma        text,
  status       text not null default 'efetivado',
  descricao    text not null default '',
  obs          text default '',
  criado_em    timestamptz not null default now()
);

create table public.contas_pr (
  id           text primary key,
  owner        uuid not null default auth.uid() references auth.users(id) on delete cascade,
  tipo         text not null,               -- pagar | receber
  descricao    text not null,
  valor        bigint not null check (valor > 0),
  vencimento   date not null,
  status       text not null default 'pendente',
  categoria_id text,
  criado_em    timestamptz not null default now()
);

create table public.recorrentes (
  id           text primary key,
  owner        uuid not null default auth.uid() references auth.users(id) on delete cascade,
  tipo         text not null,
  descricao    text not null,
  valor        bigint not null check (valor > 0),
  frequencia   text not null default 'Mensal',
  proxima_data date not null,
  categoria_id text,
  criado_em    timestamptz not null default now()
);

create table public.transferencias (
  id        text primary key,
  owner     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  de        text,
  para      text,
  valor     bigint not null check (valor > 0),
  data      date not null,
  criado_em timestamptz not null default now()
);

-- ---------------- ROW LEVEL SECURITY ----------------
do $$
declare t text;
begin
  foreach t in array array['contas','categorias','usuarios','lancamentos','contas_pr','recorrentes','transferencias']
  loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('drop policy if exists "owner_all" on public.%I;', t);
    execute format('create policy "owner_all" on public.%I for all using (owner = auth.uid()) with check (owner = auth.uid());', t);
  end loop;
end $$;

-- ---------------- ÍNDICES ----------------
create index if not exists idx_lanc_owner_data on public.lancamentos (owner, data);
create index if not exists idx_pr_owner_venc    on public.contas_pr   (owner, vencimento);

-- =====================================================================
--  CRIAR O LOGIN DE ACESSO:  Authentication > Users > Add user
--  (e-mail + senha; desligue "Confirm email" em Authentication > Providers).
--  Use o MESMO login em todos os dispositivos para compartilhar os dados.
-- =====================================================================
