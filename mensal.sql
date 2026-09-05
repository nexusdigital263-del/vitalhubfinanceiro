-- =====================================================================
--  VitalHub — Controle MENSAL de clientes e recorrentes
--  Adiciona a coluna "mes" (YYYY-MM) nas tabelas clientes e recorrentes,
--  para que cada mês guarde seus próprios valores e o histórico não seja
--  alterado quando você atualizar algo no mês atual.
--
--  Seguro: não apaga dados. Rode no Supabase:
--  Dashboard > SQL Editor > New query > cole tudo > Run.
-- =====================================================================

alter table if exists public.clientes    add column if not exists mes text;
alter table if exists public.recorrentes add column if not exists mes text;

create index if not exists idx_clientes_mes    on public.clientes    (mes);
create index if not exists idx_recorrentes_mes on public.recorrentes (mes);

-- Registros antigos (sem mês) continuam servindo como base: eles aparecem
-- em qualquer mês até você editar aquele mês pela primeira vez — a partir daí
-- o mês passa a ter a própria cópia, e os meses anteriores ficam intactos.
