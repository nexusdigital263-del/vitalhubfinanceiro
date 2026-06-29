-- =====================================================================
--  seed.sql — dados de exemplo da VitalHub para o USUÁRIO LOGADO
--  Rode DEPOIS do schema.sql e DEPOIS de criar/entrar com o usuário.
--  Como usa auth.uid(), execute pelo app já logado OU rode no SQL Editor
--  e troque auth.uid() pelo id do usuário (Authentication > Users > copiar UID).
--  Valores em CENTAVOS.
-- =====================================================================
with
u as (select auth.uid() as id),
-- ---------- CONTAS ----------
c as (
  insert into public.contas (id, owner, nome, tipo, saldo_inicial, cor)
  select gen_random_uuid()::text, u.id, x.nome, x.tipo, x.saldo, x.cor from u, (values
    ('Caixa / Dinheiro','Dinheiro', 120000,'#8a8a80'),
    ('Conta Inter PJ',  'Banco',   3500000,'#e8730a'),
    ('Conta Nubank PJ', 'Banco',   1800000,'#8a2be2')
  ) as x(nome,tipo,saldo,cor)
  returning id, nome
),
-- ---------- CATEGORIAS ----------
cat as (
  insert into public.categorias (id, owner, nome, tipo, cor)
  select gen_random_uuid()::text, u.id, x.nome, x.tipo, x.cor from u, (values
    ('Retainers','entrada','#2f9e6f'),
    ('Projetos','entrada','#3a86c8'),
    ('Gestão de Tráfego','entrada','#5fb39a'),
    ('Outras receitas','entrada','#8aa1a8'),
    ('Salários','saida','#c23b34'),
    ('Freelancers','saida','#e0794b'),
    ('Ferramentas / Software','saida','#b8791f'),
    ('Tráfego (Ads clientes)','saida','#9b6cd1'),
    ('Aluguel','saida','#7a6f63'),
    ('Impostos','saida','#5a6b7a'),
    ('Operacional','saida','#a08c5b')
  ) as x(nome,tipo,cor)
  returning id, nome
)
-- ---------- LANÇAMENTOS (exemplos de junho/2026) ----------
insert into public.lancamentos (id, owner, tipo, valor, data, categoria_id, conta_id, forma, status, descricao)
select
  gen_random_uuid()::text,
  (select id from u),
  x.tipo, x.valor, x.data::date,
  (select id from cat where nome = x.cat),
  (select id from c   where nome = x.conta),
  x.forma, x.status, x.descricao
from (values
  ('entrada', 850000,'2026-06-02','Retainers','Conta Inter PJ','PIX','efetivado','Retainer mensal — Cliente Aurora'),
  ('saida',   420000,'2026-06-03','Aluguel','Conta Inter PJ','Boleto','efetivado','Aluguel do escritório'),
  ('saida',  2200000,'2026-06-05','Salários','Conta Inter PJ','Transferência','efetivado','Folha de salários — equipe'),
  ('entrada',1200000,'2026-06-05','Projetos','Conta Nubank PJ','PIX','efetivado','Projeto branding — Cliente Bloom'),
  ('saida',   135000,'2026-06-08','Ferramentas / Software','Conta Nubank PJ','Cartão crédito','efetivado','Adobe CC + Figma'),
  ('entrada', 600000,'2026-06-10','Retainers','Conta Inter PJ','PIX','efetivado','Retainer mensal — Cliente Coraline'),
  ('saida',   540000,'2026-06-12','Freelancers','Conta Inter PJ','PIX','efetivado','Freelancers — design e copy'),
  ('entrada', 450000,'2026-06-15','Gestão de Tráfego','Conta Inter PJ','PIX','efetivado','Gestão de tráfego — Cliente Drix'),
  ('entrada', 980000,'2026-06-20','Projetos','Conta Nubank PJ','PIX','efetivado','Projeto site — Cliente Évora'),
  ('saida',   390000,'2026-06-22','Impostos','Conta Inter PJ','Boleto','efetivado','Simples Nacional — DAS')
) as x(tipo,valor,data,cat,conta,forma,status,descricao);
