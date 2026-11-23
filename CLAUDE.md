# Base Aurora (Team Kera)

Protótipo educativo em **Flutter web** para o desafio "Build a Junior Astronaut Mission Trainer". A pessoa registra uma expectativa, decide como gerir energia e comida numa base fictícia em Marte, observa o resultado e compara estratégias a partir do mesmo estado inicial. Demo: https://base-aurora.vercel.app

## Arquitetura
```
Flutter web (lib/) ──postMessage──> iframe Three.js (web/scene.js)   [só visual, sem autoridade]
      │
      ├── domínio puro: lib/features/mission/domain/simulation.dart  (calcula tudo)
      └── AURA: lib/features/commander/knowledge.dart ──(opcional)──> backend Node (POST /commander/help)
                         └── fallback local com assets/knowledge.json (padrão em produção)
```
- `lib/features/mission/domain/simulation.dart`: **regras puras** (estado, estratégias, resultados). É a única fonte de verdade dos recursos. Testes em `test/simulation_test.dart`.
- `lib/features/base_scene/base_scene.dart`: integração Flutter ↔ iframe. As mensagens verificam origem e remetente.
- `lib/features/commander/knowledge.dart`: recuperação local e cliente do backend.
- `lib/main.dart` (**cerca de 2.000 linhas**): landing, jornada, controles e comparação. É o maior débito técnico. Código novo vai para `lib/features/*` e, ao mexer aqui, extraia widgets aos poucos.
- `lib/i18n.dart`: PT/EN.
- `web/scene.js`, `web/software-renderer.js`, `web/vendor/`: cena 3D e renderer local (sem CDN).
- `backend/` (Node, `.mjs`, sem dependências):
  - `server.mjs`: `http` nativo. Rotas `GET /health`, `GET /science/sources` e `POST /commander/help`.
  - Proteções: allowlist de origem via `ALLOWED_ORIGINS`, rate limit de 20 por minuto por IP, corpo de até 8 KB e `nosniff`.
  - `rag.mjs`: recuperação lexical com citações.
  - `engine.mjs`: geração opcional (Chat Completions via `LLM_API_KEY`, `LLM_BASE_URL`, `LLM_MODEL`).

Arquitetura detalhada em `docs/ARCHITECTURE.md`. A ciência e as fontes ficam em `docs/SCIENCE.md`.

## Comandos (PowerShell)
```powershell
flutter pub get; flutter analyze; flutter test
flutter run -d chrome
npm run test:backend      # node --test backend/test/*.test.mjs
npm run aura              # backend local na porta 8787 (copie backend/.env.example)
flutter build web --release --output dist
```
Não há GitHub Actions: a verificação roda **dentro do build da Vercel**.

## Deploy (Vercel + integração GitHub)
- Projeto Vercel `base-aurora`, branch de produção `main`. **Push ou merge na main publica em produção.**
- `vercel.json`: framework Other, install vazio, build `bash scripts/build-vercel.sh`, saída `dist/`.
- `scripts/build-vercel.sh`:
  - Clona o **Flutter 3.50.0 com a revisão fixada** e falha se a revisão divergir.
  - Roda `flutter test test/simulation_test.dart` e `node --test backend/test/*.test.mjs`.
  - Faz `flutter build web --release --output dist`.
  - Teste quebrado = deploy bloqueado.
- Para atualizar o Flutter: mude a versão **e** a revisão no script e teste localmente.
- O backend AURA **não** é publicado nesse fluxo: produção usa só o fallback local. Para usar o LLM, publique o backend separado e configure o endpoint HTTPS no build. **Nunca** coloque chaves em Flutter nem em `--dart-define`.
- Confirme o status "Ready" no painel da Vercel. Configuração não prova que o build passou (`docs/VERCEL.md`).

## Regras
- Recursos e resultados são calculados **só no domínio Dart**. O iframe apenas exibe.
- Interface PT/EN. `README.md` (EN) e `README.pt.md` (PT) andam juntos.
- Respeite `prefers-reduced-motion` e o controle de pausa.
- Não chame o projeto de "IA generativa ativa": a versão pública não tem modelo generativo.
- Não altere `docs/apresentacao/` (submissão do desafio) sem pedido.
- Agentes: `flutter-dev` (UI/domínio) e `ia-engineer` (recuperação/citações).
