-- =====================================================================
--  VitalHub · Controle de Caixa — Esquema do banco (Supabase / PostgreSQL)
--  Rode no Supabase: Dashboard > SQL Editor > New query > cole tudo > Run.
--  Cada usuário só enxerga/edita os próprios dados (RLS por auth.uid()).
--  IDs são TEXTO (gerados pelo app) e os valores monetários ficam em CENTAVOS.
-- =====================================================================

create table if not exists public.contas (
  id            text primary key,
  owner         uuid not null default auth.uid() references auth.users(id) on delete cascade,
  nome          text not null,
  tipo          text not null default 'Banco',
  saldo_inicial bigint not null default 0,
  cor           text not null default '#1f4d3a',
  criado_em     timestamptz not null default now()
);

create table if not exists public.categorias (
  id        text primary key,
  owner     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  nome      text not null,
  tipo      text not null,
  cor       text not null default '#2f8d59',
  criado_em timestamptz not null default now()
);

create table if not exists public.lancamentos (
  id           text primary key,
  owner        uuid not null default auth.uid() references auth.users(id) on delete cascade,
  tipo         text not null,
  valor        bigint not null check (valor > 0),
  data         date not null,
  categoria_id text references public.categorias(id) on delete set null,
  conta_id     text references public.contas(id) on delete set null,
  forma        text,
  status       text not null default 'efetivado',
  descricao    text not null default '',
  obs          text default '',
  criado_em    timestamptz not null default now()
);

create table if not exists public.contas_pr (
  id           text primary key,
  owner        uuid not null default auth.uid() references auth.users(id) on delete cascade,
  tipo         text not null,                  -- pagar | receber
  descricao    text not null,
  valor        bigint not null check (valor > 0),
  vencimento   date not null,
  status       text not null default 'pendente',
  categoria_id text references public.categorias(id) on delete set null,
  criado_em    timestamptz not null default now()
);

create table if not exists public.recorrentes (
  id           text primary key,
  owner        uuid not null default auth.uid() references auth.users(id) on delete cascade,
  tipo         text not null,
  descricao    text not null,
  valor        bigint not null check (valor > 0),
  frequencia   text not null default 'Mensal',
  proxima_data date not null,
  categoria_id text references public.categorias(id) on delete set null,
  criado_em    timestamptz not null default now()
);

create table if not exists public.transferencias (
  id        text primary key,
  owner     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  de        text references public.contas(id) on delete set null,
  para      text references public.contas(id) on delete set null,
  valor     bigint not null check (valor > 0),
  data      date not null,
  criado_em timestamptz not null default now()
);

-- ---------------- ROW LEVEL SECURITY ----------------
alter table public.contas         enable row level security;
alter table public.categorias     enable row level security;
alter table public.lancamentos    enable row level security;
alter table public.contas_pr      enable row level security;
alter table public.recorrentes    enable row level security;
alter table public.transferencias enable row level security;

do $$
declare t text;
begin
  foreach t in array array['contas','categorias','lancamentos','contas_pr','recorrentes','transferencias']
  loop
    execute format('drop policy if exists "owner_all" on public.%I;', t);
    execute format('create policy "owner_all" on public.%I for all using (owner = auth.uid()) with check (owner = auth.uid());', t);
  end loop;
end $$;

-- ---------------- ÍNDICES ----------------
create index if not exists idx_lanc_owner_data on public.lancamentos (owner, data);
create index if not exists idx_pr_owner_venc    on public.contas_pr   (owner, vencimento);
create index if not exists idx_rec_owner        on public.recorrentes (owner);

-- =====================================================================
--  CRIAR UM USUÁRIO:  Authentication > Users > Add user
--  (e-mail + senha). Com RLS ativo, ele só verá os próprios dados.
-- =====================================================================
