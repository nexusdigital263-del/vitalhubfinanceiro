-- =====================================================================
--  VitalHub — Criar SOMENTE a tabela de usuários (seguro: não mexe nas
--  outras tabelas nem apaga dados). Rode no Supabase:
--  Dashboard > SQL Editor > New query > cole tudo > Run.
-- =====================================================================
create table if not exists public.usuarios (
  id            text primary key,
  owner         uuid not null default auth.uid() references auth.users(id) on delete cascade,
  nome          text not null,
  email         text not null,
  papel         text not null default 'Financeiro',   -- Administrador | Financeiro | Visualizador
  status        text not null default 'ativo',         -- ativo | inativo
  ultimo_acesso date,
  criado_em     timestamptz not null default now()
);

alter table public.usuarios enable row level security;
drop policy if exists "owner_all" on public.usuarios;
create policy "owner_all" on public.usuarios
  for all using (owner = auth.uid()) with check (owner = auth.uid());
