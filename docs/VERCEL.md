# Deploy pela integração GitHub e Vercel

O projeto Vercel `base-aurora` usa o repositório `FloraRosaPupo/base-aurora`. A branch de produção é `main`.

## Configuração versionada

`vercel.json` define framework Other, instalação vazia, build `bash scripts/build-vercel.sh` e saída estática `dist`.

O script usa Flutter 3.50.0, verifica a revisão do SDK, instala dependências, roda os 8 testes Dart e os 8 testes Node e compila a versão web release. A Vercel publica todos os arquivos de `dist`. O primeiro build baixa o SDK e pode levar alguns minutos.

## Atualizar o site

1. Faça alterações em uma branch e teste localmente.
2. Envie um pull request para revisão.
3. Ao atualizar a `main`, a integração inicia uma nova publicação de produção.
4. Confira os logs e o status Ready em Deployments antes de considerar a versão publicada.

O backend de geração opcional não é publicado neste fluxo. A demonstração utiliza explicações locais e não requer chaves de IA. Para usar um modelo externo, publique o backend separadamente e configure o endpoint HTTPS durante o build do frontend, conforme [ambiente](ENVIRONMENT.md). Nunca coloque chaves em código Flutter ou `--dart-define`.

O status de cada publicação deve ser confirmado no painel. Configuração e vínculo, isoladamente, não comprovam sucesso do build.
