# Ambiente e configuração

O protótipo publicado usa o modo local revisado. Para ativar um modelo:

1. Copie `backend/.env.example` para `backend/.env`, que não deve entrar no Git.
2. Informe `LLM_API_KEY`, `LLM_BASE_URL` (URL base compatível) e `LLM_MODEL` do provedor disponível.
3. Configure `ALLOWED_ORIGINS` com os endereços exatos do frontend, separados por vírgula.
4. Inicie o backend:

```sh
node --env-file=backend/.env backend/server.mjs
```

5. Rode/compile Flutter com a URL completa do endpoint:

```sh
flutter run -d chrome --web-port 3000 --dart-define=AURA_API_URL=http://localhost:8787/commander/help
```

Para um frontend hospedado em HTTPS, o endpoint também precisa de HTTPS. Nunca inclua chave do modelo em `--dart-define`, no código Flutter ou no navegador.

O backend recupera documentos em `assets/knowledge.json` e envia contexto, expectativa e evidências ao modelo. Antes da decisão, não envia o resultado reservado. Depois, recalcula o resultado no servidor. Somente citações de fontes recuperadas são aceitas. O modelo não altera recursos. Em falha de rede/modelo, Flutter recorre ao modo local e o identifica.

**O que isso não comprova:** não houve ativação de provedor externo nem avaliação de qualidade generativa com chave real. Não há embeddings ou pgvector implementados nesta versão. A recuperação lexical é um recorte funcional para um corpus pequeno. A migração para busca vetorial é uma evolução posterior.

