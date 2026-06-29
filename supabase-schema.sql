# VitalHub · Controle de Caixa — Deploy

Este pacote contém tudo para publicar o sistema na **Vercel** e (opcionalmente)
ligar um **backend real com login de usuário** via **Supabase**.

```
deploy/
├── index.html            ← aplicação completa, já empacotada (1 arquivo, funciona offline)
├── vercel.json           ← configuração de hospedagem estática
├── supabase-schema.sql   ← criação das tabelas + segurança por usuário (RLS)
└── README.md             ← este guia
```

> ⚠️ **Importante:** eu gero os arquivos e a configuração, mas **não consigo
> publicar na sua conta da Vercel nem criar contas/usuários no Supabase a partir
> daqui** — esses passos finais (que dependem do *seu* login) estão abaixo, prontos
> para você executar em poucos minutos.

---

## 1. Publicar na Vercel (hospedagem) — ~3 min

O `index.html` é **autossuficiente** (HTML + CSS + JS + logo já embutidos), então
basta hospedá-lo como site estático.

### Opção A — Pelo site (sem instalar nada)
1. Acesse <https://vercel.com> e faça login.
2. **Add New… > Project > Deploy** e arraste a pasta `deploy/` inteira
   (ou conecte um repositório Git que contenha esses arquivos).
3. Em *Framework Preset* escolha **Other**. Não há build — é estático.
4. Clique em **Deploy**. Em segundos você recebe a URL pública
   (ex.: `https://controle-vitalhub.vercel.app`).

### Opção B — Pela CLI
```bash
npm i -g vercel
cd deploy
vercel        # responda as perguntas; aceite os padrões
vercel --prod # publica em produção
```

**Login da demonstração** (já embutido no app, sem backend):
- e-mail: `admin@vitalhub.com`
- senha: `vitalhub2026`

Para trocar essas credenciais da demo, edite as constantes `this.USER` / `this.PASS`
no componente `Controle de Caixa.dc.html` e gere o `index.html` de novo.

---

## 2. Backend real com login de usuário (Supabase) — opcional

A versão publicada acima já tem **tela de login funcional** e guarda os dados no
navegador (localStorage). Para ter **autenticação de verdade** e **dados na nuvem
compartilhados entre dispositivos**, use o Supabase (plano gratuito serve):

1. Crie um projeto em <https://supabase.com>.
2. **SQL Editor > New query** → cole o conteúdo de `supabase-schema.sql` → **Run**.
   Isso cria as tabelas e a segurança por usuário (cada login vê só os próprios dados).
3. **Authentication > Users > Add user** → crie o usuário que terá acesso
   (ex.: `admin@vitalhub.com` + uma senha forte).
4. **Project Settings > API** → copie a `Project URL` e a chave `anon public`.
5. Configure-as como variáveis de ambiente na Vercel
   (*Project > Settings > Environment Variables*):
   ```
   VITE_SUPABASE_URL = https://xxxx.supabase.co
   VITE_SUPABASE_ANON_KEY = eyJ...
   ```

### Passo de integração (trabalho de desenvolvedor)
Hoje o app lê/grava no `localStorage`. Para usar o Supabase é preciso substituir
essa camada por chamadas ao Supabase (login via `supabase.auth.signInWithPassword`
e CRUD via `supabase.from('lancamentos')...`). Os pontos de troca já estão isolados
no componente:
- **Login:** método `login()` → trocar a checagem local por `supabase.auth.signInWithPassword`.
- **Persistência:** métodos `persist()` / `loadSaved()` → trocar por leitura/escrita nas tabelas.
- **CRUD:** `salvar()`, `excluir()`, `darBaixa()`, etc. → emitir `insert/update/delete`.

Os nomes das tabelas e colunas no `supabase-schema.sql` já correspondem ao modelo
de dados do app (valores em centavos, `tipo`, `status`, `vencimento`, etc.), então a
integração é direta. Posso fazer essa migração de código se você quiser — é só pedir.

---

## Resumo do que está pronto
- ✅ App completo, responsivo, tema claro/escuro, com a identidade VitalHub e a logo.
- ✅ Tela de login no padrão visual + sessão persistida.
- ✅ Arquivo único `index.html` pronto para a Vercel.
- ✅ `vercel.json` e esquema SQL com segurança por usuário.
- ⏳ Conexão do app ao Supabase (auth + nuvem): requer o passo de integração acima.
