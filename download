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
export const configurado = !!(cfg.url && cfg.anonKey && cfg.url.indexOf("SEU-PROJETO") < 0);
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
const TABELAS = {
  contas: "contas", categorias: "categorias", lancamentos: "lancamentos",
  contasPR: "contas_pr", recorrentes: "recorrentes", transferencias: "transferencias",
};
const APP_2_DB = { saldoInicial: "saldo_inicial", categoriaId: "categoria_id", contaId: "conta_id", proximaData: "proxima_data" };
const DB_2_APP = Object.fromEntries(Object.entries(APP_2_DB).map(([a, b]) => [b, a]));
const conv = (obj, dict) => { const o = {}; for (const k in obj) o[dict[k] || k] = obj[k]; return o; };
const paraBanco = (r) => conv(r, APP_2_DB);   // mantém o id (texto)
const paraApp   = (l) => conv(l, DB_2_APP);

/* ----------------------- LEITURA ----------------------- */
export async function carregarTudo() {
  const out = {};
  for (const [appKey, tabela] of Object.entries(TABELAS)) {
    const { data, error } = await supabase.from(tabela).select("*");
    if (error) throw error;
    out[appKey] = (data || []).map(paraApp);
  }
  return out;
}

/* ----------------------- ESCRITA ----------------------- */
// Cria OU atualiza (upsert pelo id). Use a chave do app (ex.: 'lancamentos', 'contasPR').
export async function salvar(appKey, registro) {
  const { data, error } = await supabase.from(TABELAS[appKey]).upsert(paraBanco(registro)).select().single();
  if (error) throw error;
  return paraApp(data);
}
// Exclui 1 ou vários ids.
export async function excluir(appKey, ids) {
  const lista = Array.isArray(ids) ? ids : [ids];
  const { error } = await supabase.from(TABELAS[appKey]).delete().in("id", lista);
  if (error) throw error;
  return true;
}
