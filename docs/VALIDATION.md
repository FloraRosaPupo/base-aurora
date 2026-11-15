# Validação

```sh
flutter test test/simulation_test.dart
node --test backend/test/*.test.mjs
```

Testes cobrem balanço, determinismo, compromissos, estado inicial preservado, exposição, recursos insuficientes e validação de fontes/entrada do backend. Verificados nesta entrega: build web release; 8 testes Dart; 8 testes Node; landing, câmera orbital no modo 3D por CPU, expectativa, resultado, comparação, fontes da AURA e reflexão final em Chrome. O ambiente de teste não disponibilizou WebGL, então a renderização por GPU permanece sem validação visual. Isso não equivale a validação científica ou estudo de eficácia educativa.

Não coletamos nomes, e-mail ou conversas pessoais de alunos. O estado é mantido na memória da sessão e pode ser exportado pelo usuário. Ao configurar um provedor de IA, o contexto enviado ao backend pode ser processado por esse provedor; escolha e documente esse serviço antes de usar com alunos.

