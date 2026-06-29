# VitalHub · Controle de Caixa

App de controle de caixa (estático) com login e dados na nuvem via Supabase.

## Arquivos (todos na raiz — sem subpastas)
- `index.html` — a aplicação
- `config.js` — credenciais públicas do Supabase
- `supabase-api.js` — cliente (auth + dados)
- `schema.sql` — rodar uma vez no Supabase (SQL Editor)
- `seed.sql` — dados de exemplo (opcional)

## Publicar
1. Suba **todos os arquivos na raiz** do repositório (não há subpastas, então não há `config.js` duplicado).
2. Na Vercel: Add New → Project → importar o repositório → Framework **Other** → Deploy.

## Ativar backend
1. Supabase → SQL Editor → cole `schema.sql` → Run.
2. Authentication → Users → criar usuário (desligar *Confirm email*).
3. Pronto: abra o site e faça login.

Sem `config.js` válido o app roda em modo demonstração (login `admin@vitalhub.com` / `vitalhub2026`).
