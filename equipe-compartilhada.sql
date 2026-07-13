-- =====================================================================
--  VitalHub — Modo EQUIPE (logins separados, dados COMPARTILHADOS)
--
--  Troca a regra de segurança de "cada usuário vê só o seu" para
--  "todo login autenticado vê e edita a MESMA base" (uma empresa).
--
--  • Seguro: NÃO apaga tabelas nem dados — só substitui as políticas.
--  • Depois de rodar, qualquer usuário criado em Authentication > Users
--    enxerga e edita os mesmos lançamentos/contas/etc.
--  • Você controla quem tem acesso pela lista de usuários do Supabase.
--
--  Rode no Supabase:  Dashboard > SQL Editor > New query > cole tudo > Run.
-- =====================================================================
do $$
declare t text;
begin
  foreach t in array array['contas','categorias','usuarios','lancamentos','contas_pr','recorrentes','transferencias']
  loop
    execute format('alter table public.%I enable row level security;', t);
    -- remove a política antiga (por dono) se existir
    execute format('drop policy if exists "owner_all" on public.%I;', t);
    execute format('drop policy if exists "equipe_all" on public.%I;', t);
    -- nova política: qualquer usuário autenticado acessa tudo (base compartilhada)
    execute format('create policy "equipe_all" on public.%I for all to authenticated using (true) with check (true);', t);
  end loop;
end $$;
