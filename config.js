# VitalHub · Ativar o Backend (Supabase) — passo a passo

Este pacote liga o sistema a um **backend real**: login de verdade por usuário e
dados na nuvem (compartilhados entre dispositivos), com **isolamento por usuário**
via RLS (cada login só vê os próprios dados).

```
deploy/backend/
├── schema.sql          ← cria as tabelas + segurança (RLS)
├── seed.sql            ← dados de exemplo para o usuário logado (opcional)
├── config.js           ← onde você cola a URL e a chave pública do Supabase
├── supabase-api.js     ← cliente pronto (auth + CRUD), sem build
└── README-BACKEND.md   ← este guia
```

> Eu gero todos os arquivos e o código de integração. Os passos que dependem do
> **seu** login (criar o projeto Supabase, criar o usuário, publicar na Vercel)
> **você executa** — estão detalhados abaixo e levam ~10 minutos.

---

## Passo 1 — Criar o projeto no Supabase
1. Acesse <https://supabase.com> → **New project**.
2. Defina nome, senha do banco e região (escolha a mais próxima, ex.: *South America (São Paulo)*).
3. Aguarde provisionar (~1 min).

## Passo 2 — Criar as tabelas e a segurança
1. No projeto: **SQL Editor → New query**.
2. Cole TODO o conteúdo de `schema.sql` e clique em **Run**.
   - Cria as tabelas: `contas`, `categorias`, `lancamentos`, `contas_pr`,
     `recorrentes`, `transferencias`.
   - Ativa **RLS** com a política “cada usuário só acessa os próprios registros”.

## Passo 3 — Criar o usuário de acesso
1. **Authentication → Users → Add user**.
2. Informe e-mail (ex.: `admin@vitalhub.com`) e uma **senha forte**.
3. (Opcional) Em **Authentication → Providers**, desligue *Confirm email* para
   permitir login imediato sem confirmação.

## Passo 4 — (Opcional) Carregar dados de exemplo
Para já ver o sistema preenchido:
1. Copie o **UID** do usuário em **Authentication → Users**.
2. Abra `seed.sql`, troque `auth.uid()` pelo UID copiado (entre aspas simples),
   cole no **SQL Editor** e **Run**.
   - Ou, mais simples: depois de conectar o app (passo 6), entre no sistema e use
     o botão **Restaurar dados de exemplo** — ele recria os dados localmente; para
     gravá-los na nuvem, mantenha a integração de escrita do passo 6 ligada.

## Passo 5 — Pegar as credenciais e preencher o `config.js`
1. **Project Settings → API**.
2. Copie **Project URL** e a chave **anon public**.
3. Edite `config.js`:
   ```js
   window.VITALHUB_SUPABASE = {
     url: "https://SEU-PROJETO.supabase.co",
     anonKey: "eyJhbGciOi...sua-anon-key..."
   };
   ```
   > A `anon key` é pública por natureza — a proteção real vem do RLS (passo 2).

---

## Passo 6 — Conectar o app ao Supabase (integração de código)
Hoje o app guarda tudo no navegador (localStorage). Para usar o Supabase, carregue
o cliente e troque 3 pontos no componente `Controle de Caixa.dc.html`. Os arquivos
`config.js` e `supabase-api.js` devem ficar ao lado do HTML publicado.

**a) Carregar o cliente** — no `<helmet>` do componente, adicione:
```html
<script src="config.js"></script>
<script type="module">
  import * as API from './supabase-api.js';
  window.API = API;
</script>
```

**b) Login real** — no método `login()`, troque a checagem local por:
```js
async login() {
  try {
    await window.API.entrar(this.state.loginForm.user, this.state.loginForm.pass);
    const dados = await window.API.carregarTudo();      // puxa os dados do usuário
    this.setState(Object.assign({ auth: true, loginForm:{user:'',pass:'',erro:''} }, dados));
    this.toast('Bem-vindo de volta!', 'ok');
  } catch (e) {
    this.setState(s => ({ loginForm: Object.assign({}, s.loginForm, { erro:'E-mail ou senha incorretos.' }) }));
  }
}
```
E no `logout()`: `await window.API.sair();` antes de `this.setState({ auth:false })`.

**c) Persistência na nuvem** — em vez de gravar no localStorage, mande cada
operação para o Supabase. O `supabase-api.js` já expõe:
```js
await window.API.inserir('lancamentos', registro);     // CREATE
await window.API.atualizar('lancamentos', id, campos); // UPDATE
await window.API.excluir('lancamentos', [id1, id2]);   // DELETE (aceita 1 ou vários)
```
Use a mesma chave para as outras entidades: `'contas'`, `'categorias'`,
`'contasPR'`, `'recorrentes'`, `'transferencias'`. O módulo já converte
camelCase ↔ snake_case e mantém os valores em centavos. Basta chamar essas
funções dentro de `salvar()`, `excluir()`, `confirmar()`, `darBaixa()`,
`salvarConta()`, `salvarCategoria()`, etc. (e pode remover o `persist()`/`loadSaved()`).

> Quer que eu já faça essa troca toda no componente e te entregue pronto? É só pedir
> “migra o app para o Supabase” — eu reescrevo os métodos e devolvo o arquivo final.

---

## Passo 7 — Publicar na Vercel
1. Coloque na mesma pasta: `index.html` (app), `config.js` e `supabase-api.js`
   (e mantenha `vercel.json`).
2. **vercel.com → Add New → Project**, arraste a pasta ou conecte o Git.
3. Framework: **Other** (sem build). **Deploy**.
4. Abra a URL, faça login com o usuário do passo 3 — pronto, backend ativo. ✅

---

## Segurança e manutenção
- **Trocar senha de um usuário:** Authentication → Users → (usuário) → *Reset password*.
- **Novos usuários:** crie em Authentication → Users; cada um verá apenas os próprios dados.
- **Backups:** o Supabase faz backup automático; também dá para exportar pelo painel.
- **Limites:** o plano gratuito do Supabase atende bem um uso pequeno/médio.

## Resumo
- ✅ `schema.sql` — tabelas + RLS por usuário.
- ✅ `seed.sql` — dados de exemplo.
- ✅ `config.js` — suas credenciais.
- ✅ `supabase-api.js` — cliente pronto (auth + CRUD, sem build).
- ⏳ Passo 6 (integração no componente) — posso fazer por você quando quiser.
