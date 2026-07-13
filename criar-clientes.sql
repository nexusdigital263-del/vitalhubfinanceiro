-- =====================================================================
--  VitalHub — Criar a tabela de CLIENTES (mensalidades)
--  Seguro: não apaga nada. Rode no Supabase:
--  Dashboard > SQL Editor > New query > cole tudo > Run.
--
--  Usa a MESMA política de equipe (todos os logins compartilham os dados),
--  igual às outras tabelas do modo equipe.
-- =====================================================================
create table if not exists public.clientes (
  id           text primary key,
  owner        uuid not null default auth.uid() references auth.users(id) on delete cascade,
  nome         text not null,
  valor_mensal bigint not null default 0,
  dia_venc     text,
  status       text not null default 'ativo',
  criado_em    timestamptz not null default now()
);

alter table public.clientes enable row level security;
drop policy if exists "owner_all"  on public.clientes;
drop policy if exists "equipe_all" on public.clientes;
create policy "equipe_all" on public.clientes
  for all to authenticated using (true) with check (true);
