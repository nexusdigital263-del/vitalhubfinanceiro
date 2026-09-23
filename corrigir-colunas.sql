-- =====================================================================
--  VitalHub — Colunas que faltam no banco (rode UMA vez)
--  Corrige: "Could not find the 'cliente_nome' column of 'lancamentos'"
--  Seguro: só adiciona colunas, não apaga nada. Pode rodar de novo sem problema.
--  Supabase > SQL Editor > New query > cole tudo > Run.
-- =====================================================================

-- Lançamentos: cliente vinculado, link do comprovante e observações
alter table if exists public.lancamentos add column if not exists cliente_nome text;
alter table if exists public.lancamentos add column if not exists comprovante  text;
alter table if exists public.lancamentos add column if not exists obs          text default '';

-- Clientes e recorrentes: controle por mês
alter table if exists public.clientes    add column if not exists mes text;
alter table if exists public.recorrentes add column if not exists mes text;

-- Categorias: teto de orçamento
alter table if exists public.categorias  add column if not exists orcamento bigint;

-- "Pago via" (conta da empresa ou cartão pessoal) em recorrentes e contas a pagar/receber
alter table if exists public.recorrentes add column if not exists forma text;
alter table if exists public.contas_pr   add column if not exists forma text;

-- Gasto no cartão do sócio marcado como reembolsado (evita lançamento duplicado de reembolso)
alter table if exists public.lancamentos add column if not exists reembolsado text;

-- Força o Supabase a reconhecer as colunas novas imediatamente
notify pgrst, 'reload schema';
