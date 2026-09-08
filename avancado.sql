-- =====================================================================
--  VitalHub — Novas colunas para as funções avançadas
--  Adiciona: comprovante e cliente no lançamento, orçamento na categoria.
--  Seguro: não apaga dados. Rode no Supabase:
--  Dashboard > SQL Editor > New query > cole tudo > Run.
-- =====================================================================

-- Comprovante (link da nota/recibo) e cliente vinculado ao lançamento
alter table if exists public.lancamentos add column if not exists comprovante   text;
alter table if exists public.lancamentos add column if not exists cliente_nome  text;

-- Teto de orçamento mensal por categoria (em centavos)
alter table if exists public.categorias  add column if not exists orcamento     bigint;

create index if not exists idx_lanc_cliente on public.lancamentos (cliente_nome);

-- =====================================================================
--  Observação: fechamento de mês, histórico de alterações, provisões e
--  metas de orçamento ficam salvos no navegador de cada usuário. Se quiser
--  que também sejam compartilhados na nuvem entre os sócios, me avise que
--  eu crio as tabelas correspondentes.
-- =====================================================================
