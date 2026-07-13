# VitalHub · Controle de Caixa

App de controle de caixa (site estático) com login real e dados na nuvem via Supabase.

## Arquivos (todos na RAIZ — sem subpastas, sem config.js duplicado)
- `index.html` — a aplicação
- `config.js` — credenciais públicas do Supabase (já preenchidas)
- `supabase-api.js` — cliente (login + dados)
- `schema.sql` — rodar UMA vez no Supabase (SQL Editor)

## 1. Preparar o banco (uma vez)
1. Supabase → **SQL Editor → New query** → cole todo o `schema.sql` → **Run**.
   (ele recria as tabelas com a estrutura correta e ativa a segurança por usuário)
2. **Authentication → Users → Add user** → crie cada login (e-mail + senha).
3. **Authentication → Providers → Email** → desligue *Confirm email* (login imediato).

> Os **dados de exemplo** são criados automaticamente pelo app no primeiro
> acesso de cada usuário — não precisa rodar nenhum "seed".

## 2. Publicar
1. Suba **os 4 arquivos na raiz** do repositório (não há subpastas → não aparece `config.js(1)`).
2. Vercel → Add New → Project → importe o repositório → Framework **Other** → **Deploy**.
3. A cada `git push`, a Vercel republica sozinha.

## Como funciona
- **Login real:** cada usuário criado no Supabase entra e vê os próprios dados.
- **Nuvem compartilhada:** ao logar com o MESMO usuário em qualquer navegador/dispositivo,
  os dados são os mesmos (ficam no Supabase, não no navegador).
- **Primeiro acesso:** se o banco do usuário estiver vazio, o app popula com os
  exemplos automaticamente.
- Sem `config.js` válido, o app roda em modo demonstração (login `admin@vitalhub.com` / `vitalhub2026`, dados só no navegador).

## Segurança
A `anon key` do `config.js` é pública por design — a proteção vem do RLS criado no `schema.sql`
(cada login só acessa os próprios dados). Nunca exponha a *service_role* key.
