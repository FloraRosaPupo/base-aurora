# Base Aurora — Team Kera

Educational prototype built with **Flutter web** for the **Build a Junior Astronaut Mission Trainer** challenge. Learners record an expectation, decide how to manage energy and food production on a fictional Mars base, observe the outcome, and compare strategies from the same initial state.

> **Português:** [README.pt.md](README.pt.md) · **Live demo:** https://base-aurora.vercel.app · **30 s video:** [YouTube](https://youtu.be/fEmvsGXurzI) · **Slides (7, English):** [PDF](docs/apresentacao/Base_Aurora_Kera_Submissao.pdf)

![Concept art of Base Aurora, generated with AI](assets/mars.png)

The interface is available in **Portuguese and English**. The language is detected from the browser on the first visit, can be switched in the header, and the choice is saved locally.

## Access and presentation

- [Open the public demo](https://base-aurora.vercel.app/)
- [Demo video (30 s, English narration and subtitles)](https://youtu.be/fEmvsGXurzI)
- [Demo video MP4 backup](docs/apresentacao/Base_Aurora_Kera_Demo_30s.mp4)
- [Editable PowerPoint](docs/apresentacao/Base_Aurora_Kera_Submissao.pptx)
- [PDF presentation](docs/apresentacao/Base_Aurora_Kera_Submissao.pdf)
- [GitHub deploy workflow](docs/VERCEL.md)

The presentation has 7 slides in English, screenshots of the real prototype, a strategy comparison and source links. The PowerPoint includes dissolve transitions.

## What works

- Responsive landing page in Portuguese and English, with science, attributions, an entrance animation and a slow zoom on the background art.
- Animated indicators, highlighting in the 3D scene and a pause control for animations. The browser's reduced-motion preference is respected.
- WebGL 3D scene with terrain, habitat, greenhouse, solar panels and shelter. Orbital camera and click/tap selection. Flutter controls also allow selecting modules.
- Deterministic engine in Dart, with five indicators and three strategies.
- Learners record the resource they expect to preserve and the expected cost before results are revealed.
- Verifiable energy balance, controlled comparison and a final reflection question.
- Local JSON export of the mission log, without collecting personal identification.
- AURA in local mode: lexical search over reviewed science summaries, explanations and links to the retrieved references. No LLM is used unless configured.
- Optional Node backend with weighted lexical retrieval and generation through a Chat Completions-compatible API. Citation validation, server-side recomputation of outcomes, rate limiting and response-time limits.

The 3D view uses **Three.js 0.180.0**, integrated with Flutter through `HtmlElementView` and a local page. Flutter controls the interface and the engine; JavaScript controls only the visualization. This is not the Dart `three_js` package. Renderer files ship with the project, with no CDN at runtime.

## Run locally without an AI key

Requires stable Flutter with Dart >= 3.8 and a modern browser for the scene. WebGL2 provides the main rendering; without it, a CPU renderer projects the same 3D geometry onto Canvas 2D, with an orbital camera and selection. Version used for the build: Flutter 3.50.0 / Dart 3.14.0. Node >= 22 for the optional backend.

```sh
git clone https://github.com/FloraRosaPupo/base-aurora.git
cd base-aurora
flutter pub get
flutter run -d chrome --web-port 3000
```

To build:

```sh
flutter build web --release --output dist --no-wasm-dry-run
```

Host **all** files from `dist/`, including `scene.html`, `scene.js`, `vendor/`, `assets/` and the Flutter/CanvasKit files. `base href` is `/`. Subdirectory deployments also require adjusting the scene URL. The first build and the first load may need the official Flutter artifacts.

## Enable generation with RAG

The published prototype uses the reviewed local mode. To enable a model:

1. Copy `backend/.env.example` to `backend/.env`, which must not enter Git.
2. Set `LLM_API_KEY`, `LLM_BASE_URL` (compatible base URL) and `LLM_MODEL` for the available provider.
3. Set `ALLOWED_ORIGINS` to the exact frontend origins, separated by commas.
4. Start the backend:

```sh
node --env-file=backend/.env backend/server.mjs
```

5. Run/build Flutter with the full endpoint URL:

```sh
flutter run -d chrome --web-port 3000 --dart-define=AURA_API_URL=http://localhost:8787/commander/help
```

For an HTTPS-hosted frontend, the endpoint also needs HTTPS. Never include the model key in `--dart-define`, in Flutter code or in the browser.

The backend retrieves documents from `assets/knowledge.json` and sends context, expectation and evidence to the model. Before the decision, it does not send the withheld outcome. After it, the result is recomputed on the server. Only citations from retrieved sources are accepted. The model does not change resources. On network or model failure, Flutter falls back to local mode and says so.

**What this does not prove:** no external provider was activated and generative quality has not been evaluated with a real key. Embeddings or pgvector are not implemented in this version. Lexical retrieval is a functional fit for a small corpus. Migrating to vector search is a later step.

## Science and limitations

Sources live in `assets/knowledge.json`, with URLs and original reviewed summaries. They are not full copies of the documents or telemetry data.

- NASA, ECLSS: water recovery, air revitalization and oxygen generation on the ISS.
- NASA, Martian Dust Storms: dust and solar power.
- NASA Science, VEGGIE: crop studies and food supplementation on the ISS.
- NASA, Space Radiation: radiation risks for human exploration.

The game uses **didactic units**, compressed periods and established plants. Exposure is a game index, not a medical dose. Maintenance, production and consumption constants are balancing choices, not NASA-certified parameters. ISS materials support principles and do not validate a human habitat on Mars.

All three strategies are viable from the initial state and carry different trade-offs. With a different resource configuration, the engine can detect failure without hiding the deficit.

Before submitting, the team must confirm that at least one resource actually used belongs to the challenge's Resources list and complies with the current rules. There is no confirmation of eligibility, team registration or automatic submission.

## Structure

- `lib/features/mission/domain/`: state, strategies and pure rules.
- `lib/features/base_scene/`: Flutter/iframe visualization integration.
- `lib/features/commander/`: local retrieval and backend client.
- `lib/i18n.dart`: app language state and translation helper.
- `lib/main.dart`: landing, journey, controls and comparison.
- `web/scene.*`, `web/vendor/`: 3D scene and local renderer.
- `assets/knowledge.json`: scientific sources and summaries.
- `backend/`: retrieval, optional generation, HTTP and tests.
- `test/simulation_test.dart`: engine invariants.

## Test without consuming AI

```sh
flutter test test/simulation_test.dart
node --test backend/test/*.test.mjs
```

Tests cover balance, determinism, trade-offs, preserved initial state, exposure, insufficient resources and backend source/input validation. Verified in this delivery: release web build; 8 Dart tests; 8 Node tests; landing, orbital camera in CPU 3D mode, expectation, outcome, comparison, AURA sources and final reflection in Chrome. The test environment did not provide WebGL, so GPU rendering remains visually unverified. This is not equivalent to scientific validation or an educational efficacy study.

We do not collect names, emails or personal conversations from learners. State is kept in session memory and can be exported by the user. If an AI provider is configured, context sent to the backend may be processed by that provider; choose and document that service before using it with students.

## Contributing and docs

- [Contributing](CONTRIBUTING.md) and [security](SECURITY.md).
- [Architecture](docs/ARCHITECTURE.md), [environment](docs/ENVIRONMENT.md) and [validation](docs/VALIDATION.md).
- [Science and simplifications](docs/SCIENCE.md), [roadmap](docs/ROADMAP.md) and [Vercel deploy](docs/VERCEL.md).

## Attribution and AI use

Team Kera: Flora Rosa Pupo and Kevyn, as provided by the team.

Code and text were prepared with assistance from ChatGPT/Codex. The 30 s video and the English summary were assembled with assistance from Claude (Anthropic) from a real recording of the prototype. English narration and soundtrack were AI-generated (ElevenLabs) and this is labeled in the video itself. The landing illustration was generated with OpenAI image generation and is presented as conceptual art. It is not an image of a real mission. The 3D models are geometries created in code. No NASA logos, flags or mission identifiers are used.

Three.js: MIT license, included in `web/vendor/THREE-LICENSE.txt`. Flutter: open-source project. Manrope and Space Grotesk fonts: OFL licenses in `assets/fonts/`. DejaVu Sans license in `assets/FONT-LICENSE.txt`. The project code is under [MIT](LICENSE). Dependencies and third-party materials keep their own licenses.

Public references:

- https://www.spaceappschallenge.org/2026/challenges/junior-astronaut-mission-trainer/
- https://www.nasa.gov/reference/environmental-control-and-life-support-systems-eclss/
- https://www.nasa.gov/solar-system/the-fact-and-fiction-of-martian-dust-storms/
- https://science.nasa.gov/mission/veggie/
- https://www.nasa.gov/hrp/hazard-space-radiation/

## Authors

| Member | Team |
| --- | --- |
| [Flora Rosa Pupo](https://github.com/FloraRosaPupo) | Kera |
| [Kevyn](https://github.com/offkevyn) | Kera |
