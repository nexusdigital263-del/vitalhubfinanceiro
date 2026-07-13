// =====================================================================
//  supabase-api.js — cliente + API de dados do VitalHub (ES module)
//  Carrega o supabase-js via CDN (sem build). Use junto com config.js:
//
//    <script src="config.js"></script>
//    <script type="module">
//      import * as API from './supabase-api.js';
//      window.API = API;            // o app detecta e usa automaticamente
//      window.dispatchEvent(new Event('vitalhub-api-ready'));
//    </script>
//
//  Converte entre o formato do app (camelCase, valores em CENTAVOS,
//  chave "contasPR") e o banco (snake_case, tabela "contas_pr").
//  Os ids são gerados pelo app (texto) e reaproveitados no banco.
// =====================================================================
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const cfg = window.VITALHUB_SUPABASE || {};
export const configurado = !!(cfg.url && cfg.anonKey && cfg.url.indexOf("SEU-PROJETO") < 0 && cfg.anonKey.indexOf("PLACEHOLDER") < 0);
export const supabase = configurado ? createClient(cfg.url, cfg.anonKey) : null;

/* ----------------------- AUTENTICAÇÃO ----------------------- */
export async function entrar(email, senha) {
  const { data, error } = await supabase.auth.signInWithPassword({ email, password: senha });
  if (error) throw error;
  return data.user;
}
export async function sair() { if (supabase) await supabase.auth.signOut(); }
export async function sessaoAtual() {
  if (!supabase) return null;
  const { data } = await supabase.auth.getSession();
  return data.session;
}

/* ----------------- MAPEAMENTO APP <-> BANCO ----------------- */
// A ORDEM importa na leitura/escrita por causa das chaves estrangeiras.
const TABELAS = {
  contas: "contas", categorias: "categorias", usuarios: "usuarios",
  lancamentos: "lancamentos", contasPR: "contas_pr",
  recorrentes: "recorrentes", transferencias: "transferencias", clientes: "clientes",
};
const APP_2_DB = { saldoInicial: "saldo_inicial", categoriaId: "categoria_id", contaId: "conta_id", proximaData: "proxima_data", ultimoAcesso: "ultimo_acesso", valorMensal: "valor_mensal", diaVenc: "dia_venc" };
const DB_2_APP = Object.fromEntries(Object.entries(APP_2_DB).map(([a, b]) => [b, a]));
const conv = (obj, dict) => { const o = {}; for (const k in obj) o[dict[k] || k] = obj[k]; return o; };
const paraBanco = (r) => { const o = conv(r, APP_2_DB); delete o.obs; return o; };   // mantém o id (texto); 'obs' não existe no banco
const paraApp   = (l) => conv(l, DB_2_APP);

/* ----------------------- LEITURA ----------------------- */
// Lê todas as tabelas. Se alguma falhar (ex.: schema incompleto), devolve []
// para aquela tabela em vez de derrubar o login inteiro.
export async function carregarTudo() {
  const out = {};
  for (const [appKey, tabela] of Object.entries(TABELAS)) {
    try {
      const { data, error } = await supabase.from(tabela).select("*");
      if (error) throw error;
      out[appKey] = (data || []).map(paraApp);
    } catch (e) {
      out[appKey] = [];
    }
  }
  return out;
}

// true quando o banco do usuário ainda não tem nada (primeiro acesso).
export async function bancoVazio() {
  try {
    const { count } = await supabase.from("contas").select("id", { count: "exact", head: true });
    return !count;
  } catch (e) { return false; }
}

/* ----------------------- ESCRITA ----------------------- */
// Cria OU atualiza (upsert pelo id). Não usa .single() para evitar o erro de
// "0 rows" que o RLS pode causar no retorno; devolve o próprio registro.
export async function salvar(appKey, registro) {
  const { error } = await supabase.from(TABELAS[appKey]).upsert(paraBanco(registro));
  if (error) throw error;
  return registro;
}
// Upsert em lote (usado na carga inicial de exemplos).
export async function salvarVarios(appKey, registros) {
  if (!registros || !registros.length) return [];
  const { error } = await supabase.from(TABELAS[appKey]).upsert(registros.map(paraBanco));
  if (error) throw error;
  return registros;
}
// Grava os dados de exemplo respeitando a ordem das chaves estrangeiras.
// Resiliente: se uma tabela falhar (ex.: ausente no schema), segue as demais.
export async function semear(dados) {
  const ordem = ["contas", "categorias", "usuarios", "lancamentos", "contasPR", "recorrentes", "transferencias", "clientes"];
  const erros = [];
  for (const appKey of ordem) {
    if (dados[appKey] && dados[appKey].length) {
      try { await salvarVarios(appKey, dados[appKey]); }
      catch (e) { erros.push(appKey + ": " + ((e && e.message) || e)); }
    }
  }
  if (erros.length) throw new Error(erros.join(" | "));
  return true;
}
// Exclui 1 ou vários ids.
export async function excluir(appKey, ids) {
  const lista = Array.isArray(ids) ? ids : [ids];
  const { error } = await supabase.from(TABELAS[appKey]).delete().in("id", lista);
  if (error) throw error;
  return true;
}
