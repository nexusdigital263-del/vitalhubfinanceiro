-- =====================================================================
--  VitalHub — MODO EQUIPE (dados compartilhados entre todos os logins)
--
--  Problema que isto resolve: hoje cada usuário só enxerga as linhas que
--  ELE criou (política "owner = auth.uid()"). Por isso o que um sócio
--  lança não aparece para o outro.
--
--  Este script troca a política de TODAS as tabelas para: qualquer usuário
--  autenticado vê e edita os mesmos dados (uma base única da empresa).
--
--  Como rodar:  Supabase > SQL Editor > New query > cole tudo > Run.
--  Seguro: não apaga nenhum dado, só troca as permissões.
-- =====================================================================

do $$
declare t text;
begin
  foreach t in array array[
    'contas','categorias','usuarios','lancamentos',
    'contas_pr','recorrentes','transferencias','clientes'
  ]
  loop
    -- pula tabelas que ainda não existem
    if to_regclass('public.'||t) is null then
      continue;
    end if;

    execute format('alter table public.%I enable row level security;', t);

    -- remove as políticas antigas (por dono)
    execute format('drop policy if exists "owner_all"  on public.%I;', t);
    execute format('drop policy if exists "equipe_all" on public.%I;', t);

    -- nova política: todo usuário logado acessa os mesmos dados
    execute format(
      'create policy "equipe_all" on public.%I for all to authenticated using (true) with check (true);', t
    );

    -- o campo owner deixa de ser obrigatório para escrever
    begin
      execute format('alter table public.%I alter column owner drop not null;', t);
    exception when others then null;
    end;
  end loop;
end $$;

-- =====================================================================
--  IMPORTANTE — unificar os dados que já existem
--  Se cada sócio já tinha lançado coisas separadamente, agora TODOS
--  passarão a ver tudo o que já foi criado (as linhas continuam lá).
--  Nada precisa ser feito além de rodar este script.
-- =====================================================================
