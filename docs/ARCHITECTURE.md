# Arquitetura

- `lib/features/mission/domain/`: estado, estratégias e regras puras.
- `lib/features/base_scene/`: integração de visualização Flutter/iframe.
- `lib/features/commander/`: recuperação local e cliente do backend.
- `lib/main.dart`: landing, jornada, controles e comparação.
- `web/scene.*`, `web/vendor/`: cena 3D e renderer local.
- `assets/knowledge.json`: fontes e sínteses científicas.
- `backend/`: recuperação, geração opcional, HTTP e testes.
- `test/simulation_test.dart`: invariantes do motor.


O domínio em Dart calcula resultados e comparações. Flutter controla a jornada. O iframe Three.js recebe seleção e estratégia, sem autoridade sobre os recursos. Mensagens verificam origem e remetente. AURA usa o estado e a expectativa para explicar o resultado.
