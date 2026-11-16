import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart' hide Simulation;
import 'package:web/web.dart' as web;

import 'features/mission/domain/simulation.dart';
import 'features/commander/knowledge.dart';
import 'features/base_scene/base_scene.dart';
import 'i18n.dart';

const bg = Color(0xFF080D16),
    surface = Color(0xFF111C2B),
    line = Color(0xFF273347),
    accent = Color(0xFFFFA270),
    muted = Color(0xFF9DADC2),
    white = Color(0xFFF4F3EE),
    green = Color(0xFF8CCFAF);
final knowledge = KnowledgeService();

const demoVideoId = 'fEmvsGXurzI';
const demoVideoUrl = 'https://youtu.be/fEmvsGXurzI';

/// O HtmlElementView da cena 3D fica acima da camada de eventos do Flutter
/// web, então modais desenhados sobre ele não recebem cliques. A cena é
/// ocultada enquanto um modal está aberto.
final sceneCovered = ValueNotifier(false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initLang();
  await knowledge.load();
  runApp(const AuroraApp());
}

void initLang() {
  final stored = web.window.localStorage.getItem('aurora-lang');
  appLang.value =
      (stored ?? web.window.navigator.language).toLowerCase().startsWith('en')
      ? AppLang.en
      : AppLang.pt;
  applyLang();
}

void chooseLang(AppLang lang) {
  if (appLang.value == lang) return;
  appLang.value = lang;
  web.window.localStorage.setItem('aurora-lang', lang.name);
  applyLang();
}

void applyLang() {
  final en = appLang.value == AppLang.en;
  web.document.documentElement?.setAttribute('lang', en ? 'en' : 'pt-BR');
  web.document.title = en
      ? 'Base Aurora — Kera · Mars decision lab'
      : 'Base Aurora — Kera';
  web.document
      .querySelector('meta[name="description"]')
      ?.setAttribute(
        'content',
        en
            ? 'Educational decision lab on Mars. Team Kera. Independent simulation, not endorsed by NASA.'
            : 'Laboratório educativo de decisões em Marte. Equipe Kera.',
      );
}

class AuroraApp extends StatefulWidget {
  const AuroraApp({super.key});
  @override
  State<AuroraApp> createState() => _AuroraAppState();
}

class _AuroraAppState extends State<AuroraApp> {
  bool playing = false, video = false;
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<AppLang>(
    valueListenable: appLang,
    builder: (context, lang, _) => MaterialApp(
      title: tr('Base Aurora — Kera', 'Base Aurora — Kera · Mars decision lab'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'AuroraSans',
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          surface: surface,
          onSurface: white,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: white, fontSize: 15),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(borderSide: BorderSide(color: line)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: line),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: bg,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
        ),
      ),
      home: Scaffold(
        body: playing
            ? MissionPage(onExit: () => setState(() => playing = false))
            : video
            ? VideoPage(
                onBack: () => setState(() => video = false),
                onStart: () => setState(() {
                  video = false;
                  playing = true;
                }),
              )
            : LandingPage(
                onStart: () => setState(() => playing = true),
                onVideo: () => setState(() => video = true),
              ),
      ),
    ),
  );
}

Widget txt(
  String s, {
  double size = 16,
  Color color = white,
  FontWeight weight = FontWeight.normal,
  double height = 1.5,
}) => Text(
  s,
  style: TextStyle(
    fontSize: size,
    fontFamily: size >= 24 ? 'AuroraDisplay' : 'AuroraSans',
    letterSpacing: size >= 30 ? -1.2 : 0,
    color: color,
    fontWeight: weight,
    height: height,
  ),
);
Widget eyebrow(String s) => Text(
  s,
  style: const TextStyle(
    fontSize: 11,
    color: accent,
    fontWeight: FontWeight.bold,
    letterSpacing: 2.1,
  ),
);
Widget brand({VoidCallback? onTap}) => InkWell(
  onTap: onTap,
  borderRadius: BorderRadius.circular(8),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: const Icon(Icons.explore_outlined, color: bg, size: 23),
      ),
      const SizedBox(width: 11),
      const Text(
        'AURORA',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontFamily: 'AuroraDisplay',
          fontSize: 19,
          letterSpacing: 3,
        ),
      ),
    ],
  ),
);
Widget outlineButton(String label, IconData icon, VoidCallback f) =>
    OutlinedButton.icon(
      onPressed: f,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: white,
        side: const BorderSide(color: line),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
void openLink(String url) {
  web.window.open(url, '_blank', 'noopener,noreferrer');
}

Widget langSwitch() => Container(
  decoration: BoxDecoration(
    border: Border.all(color: line),
    borderRadius: BorderRadius.circular(7),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final l in AppLang.values)
        InkWell(
          onTap: () => chooseLang(l),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: appLang.value == l ? accent : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              l.name.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: appLang.value == l ? bg : muted,
              ),
            ),
          ),
        ),
    ],
  ),
);

Future<void> sources(BuildContext context) async {
  sceneCovered.value = true;
  try {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      showDragHandle: true,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              eyebrow(tr('CIÊNCIA E TRANSPARÊNCIA', 'SCIENCE & TRANSPARENCY')),
              const SizedBox(height: 12),
              txt(
                tr(
                  'A ciência por trás da missão',
                  'The science behind the mission',
                ),
                size: 27,
                weight: FontWeight.bold,
              ),
              const SizedBox(height: 12),
              txt(
                tr(
                  'Sínteses revisadas de referências públicas da NASA. O jogo usa unidades didáticas e não representa uma missão real ou dose médica. Fontes da ISS explicam princípios, não uma base marciana existente.',
                  'Reviewed summaries of public NASA references. The game uses didactic units and does not represent a real mission or medical dose. ISS sources explain principles, not an existing Mars base.',
                ),
                color: muted,
              ),
              const SizedBox(height: 22),
              ...knowledge.corpus.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      txt(s.title, size: 19, weight: FontWeight.bold),
                      const SizedBox(height: 6),
                      txt(s.text, color: muted),
                      TextButton.icon(
                        onPressed: () => openLink(s.url),
                        label: Text(s.source),
                        icon: const Icon(Icons.open_in_new, size: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(color: line),
              txt(
                tr(
                  'AURA usa explicações locais revisadas nesta versão. A geração com modelo pode ser ativada por um backend configurado. A ilustração da página inicial foi gerada com IA. Os módulos 3D são geometrias criadas para esta simulação.',
                  'AURA uses reviewed local explanations in this version. Model generation can be enabled through a configured backend. The landing-page illustration was generated with AI. The 3D modules are geometries created for this simulation.',
                ),
                size: 13,
                color: muted,
              ),
              const SizedBox(height: 20),
              outlineButton(
                tr('Ver desafio oficial', 'View the official challenge'),
                Icons.open_in_new,
                () => openLink(
                  'https://www.spaceappschallenge.org/2026/challenges/junior-astronaut-mission-trainer/',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } finally {
    sceneCovered.value = false;
  }
}

class LandingPage extends StatelessWidget {
  final VoidCallback onStart, onVideo;
  const LandingPage({super.key, required this.onStart, required this.onVideo});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final small = c.maxWidth < 760;
      final pad = small ? 24.0 : 64.0;
      final reduced = MediaQuery.disableAnimationsOf(context);
      return SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: small ? 800 : 840,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1.06, end: 1),
                      duration: reduced
                          ? Duration.zero
                          : const Duration(seconds: 4),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, child) =>
                          Transform.scale(scale: v, child: child),
                      child: Image.asset(
                        'assets/mars.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.centerRight,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            bg.withValues(alpha: .98),
                            bg.withValues(alpha: small ? 0.62 : 0.08),
                          ],
                          stops: const [.15, 1],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [bg, bg.withValues(alpha: 0)],
                          stops: const [0, .4],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 30,
                    left: pad,
                    right: pad,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        brand(),
                        if (!small)
                          Row(
                            children: [
                              langSwitch(),
                              const SizedBox(width: 22),
                              TextButton(
                                onPressed: () => sources(context),
                                child: Text(
                                  tr('Ciência da missão', 'Mission science'),
                                  style: const TextStyle(color: white),
                                ),
                              ),
                              TextButton(
                                onPressed: onVideo,
                                child: Text(
                                  tr('Vídeo (30 s)', 'Video (30 s)'),
                                  style: const TextStyle(color: white),
                                ),
                              ),
                              const SizedBox(width: 18),
                              outlineButton(
                                tr('Iniciar missão', 'Start mission'),
                                Icons.north_east,
                                onStart,
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              langSwitch(),
                              IconButton(
                                onPressed: onVideo,
                                tooltip: tr('Ver o vídeo', 'Watch the video'),
                                icon: const Icon(Icons.play_circle_outline),
                              ),
                              IconButton(
                                onPressed: () => sources(context),
                                icon: const Icon(Icons.menu_book_outlined),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: small ? 160 : 172,
                    left: pad,
                    right: pad,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: reduced
                          ? Duration.zero
                          : const Duration(milliseconds: 1100),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, child) => Opacity(
                        opacity: v,
                        child: Transform.translate(
                          offset: Offset(0, 26 * (1 - v)),
                          child: child,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          eyebrow(
                            tr(
                              'EQUIPE KERA / LABORATÓRIO DE DECISÕES',
                              'KERA TEAM / DECISION LAB',
                            ),
                          ),
                          const SizedBox(height: 27),
                          txt(
                            tr('Uma base em Marte.', 'A base on Mars.'),
                            size: small ? 40 : 68,
                            weight: FontWeight.w700,
                            height: 1.08,
                          ),
                          txt(
                            tr('A sua decisão.', 'Your decision.'),
                            size: small ? 47 : 80,
                            color: accent,
                            weight: FontWeight.w700,
                            height: 1.12,
                          ),
                          const SizedBox(height: 28),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 465),
                            child: txt(
                              tr(
                                'Explore os sistemas. Antecipe consequências. Compare caminhos para manter a missão viva.',
                                'Explore the systems. Anticipate consequences. Compare paths to keep the mission alive.',
                              ),
                              size: small ? 17 : 19,
                              color: const Color(0xFFB8C6D5),
                              height: 1.7,
                            ),
                          ),
                          const SizedBox(height: 33),
                          FilledButton.icon(
                            onPressed: onStart,
                            icon: const Icon(Icons.arrow_forward, size: 20),
                            label: Text(
                              tr('Assumir o comando', 'Take command'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 17),
                          txt(
                            tr(
                              'Uma experiência curta. Uma escolha que faz pensar.',
                              'A short experience. A choice that makes you think.',
                            ),
                            size: 12,
                            color: muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 35,
                    left: pad,
                    right: pad,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 1,
                          color: white.withValues(alpha: .15),
                        ),
                        const SizedBox(height: 22),
                        Wrap(
                          spacing: small ? 32 : 70,
                          runSpacing: 16,
                          children: [
                            metric(
                              '03',
                              tr(
                                'estratégias reais no jogo',
                                'real strategies in the game',
                              ),
                            ),
                            metric(
                              '05',
                              tr('sistemas conectados', 'connected systems'),
                            ),
                            metric(
                              'NASA',
                              tr(
                                'referências científicas',
                                'scientific references',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        txt(
                          tr(
                            'Ilustração conceitual gerada com IA',
                            'AI-generated conceptual illustration',
                          ),
                          size: 9,
                          color: muted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: const Color(0xFFF2EEE7),
              padding: EdgeInsets.symmetric(
                horizontal: pad,
                vertical: small ? 48 : 78,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('O DESAFIO', 'THE CHALLENGE'),
                    style: const TextStyle(
                      color: Color(0xFF9A5334),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  txt(
                    tr('Tudo está conectado.', 'Everything is connected.'),
                    size: small ? 36 : 55,
                    color: const Color(0xFF14202E),
                    weight: FontWeight.w700,
                    height: 1.1,
                  ),
                  const SizedBox(height: 25),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: txt(
                      tr(
                        'A poeira reduz a energia solar. O suporte à vida continua ativo. Você poupa a reserva, mantém a estufa ou faz uma manutenção externa?',
                        'Dust reduces solar power. Life support stays active. Do you save the reserve, keep the greenhouse running, or perform external maintenance?',
                      ),
                      size: small ? 17 : 21,
                      color: const Color(0xFF586476),
                    ),
                  ),
                  const SizedBox(height: 35),
                  Wrap(
                    spacing: 30,
                    runSpacing: 22,
                    children: Resource.values
                        .map(
                          (r) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                switch (r) {
                                  Resource.energy => Icons.bolt,
                                  Resource.water => Icons.water_drop_outlined,
                                  Resource.oxygen => Icons.air,
                                  Resource.food => Icons.eco_outlined,
                                  Resource.radiation => Icons.shield_outlined,
                                },
                                color: const Color(0xFFA45F3B),
                                size: 22,
                              ),
                              const SizedBox(width: 9),
                              txt(
                                r.label,
                                size: 16,
                                color: const Color(0xFF172233),
                                weight: FontWeight.w600,
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: pad,
                vertical: small ? 48 : 76,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  eyebrow(
                    tr('A MISSÃO É ENTENDER', 'THE MISSION IS TO UNDERSTAND'),
                  ),
                  const SizedBox(height: 17),
                  txt(
                    tr(
                      'Você prevê. O jogo responde.',
                      'You predict. The game answers.',
                    ),
                    size: small ? 32 : 46,
                    weight: FontWeight.w700,
                    height: 1.15,
                  ),
                  const SizedBox(height: 35),
                  Wrap(
                    spacing: 35,
                    runSpacing: 28,
                    children: [
                      step(
                        '01',
                        tr('Preveja', 'Predict'),
                        tr(
                          'O que a sua estratégia vai preservar?',
                          'What will your strategy preserve?',
                        ),
                      ),
                      step(
                        '02',
                        tr('Experimente', 'Experiment'),
                        tr(
                          'Observe o resultado calculado.',
                          'Observe the calculated outcome.',
                        ),
                      ),
                      step(
                        '03',
                        tr('Compare', 'Compare'),
                        tr(
                          'Outra escolha, o mesmo início.',
                          'Another choice, the same starting point.',
                        ),
                      ),
                      step(
                        '04',
                        tr('Explique', 'Explain'),
                        tr(
                          'AURA conecta sua decisão à ciência.',
                          'AURA connects your decision to the science.',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Wrap(
                    spacing: 14,
                    runSpacing: 12,
                    children: [
                      outlineButton(
                        tr('Ver o vídeo', 'Watch the video'),
                        Icons.play_circle_outline,
                        onVideo,
                      ),
                      outlineButton(
                        tr('Abrir as fontes da missão', 'Open mission sources'),
                        Icons.menu_book_outlined,
                        () => sources(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: pad, vertical: 44),
              decoration: const BoxDecoration(
                color: surface,
                border: Border(top: BorderSide(color: line)),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 40,
                runSpacing: 25,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      brand(),
                      const SizedBox(height: 13),
                      txt(
                        tr(
                          'Desenvolvido pela equipe Kera.',
                          'Built by team Kera.',
                        ),
                        size: 13,
                        color: muted,
                      ),
                    ],
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 550),
                    child: txt(
                      tr(
                        'Build a Junior Astronaut Mission Trainer\nNASA Space Apps 2026 · Ribeirão Preto\nSimulação didática independente. Sem endosso da NASA.',
                        'Build a Junior Astronaut Mission Trainer\nNASA Space Apps 2026 · Ribeirão Preto\nIndependent educational simulation. Not endorsed by NASA.',
                      ),
                      size: 12,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
  Widget metric(String n, String label) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      txt(n, size: 28, weight: FontWeight.w700),
      const SizedBox(height: 3),
      txt(label, size: 11, color: muted),
    ],
  );
  Widget step(String n, String title, String body) => SizedBox(
    width: 245,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        txt(n, size: 13, color: accent),
        const SizedBox(height: 12),
        txt(title, size: 25, weight: FontWeight.w600),
        const SizedBox(height: 8),
        txt(body, size: 14, color: muted),
      ],
    ),
  );
}

class VideoPage extends StatelessWidget {
  final VoidCallback onBack, onStart;
  const VideoPage({super.key, required this.onBack, required this.onStart});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final small = c.maxWidth < 760;
      final pad = small ? 24.0 : 64.0;
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 24, pad, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  brand(onTap: onBack),
                  Row(
                    children: [
                      langSwitch(),
                      const SizedBox(width: 10),
                      TextButton.icon(
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back, size: 17),
                        label: Text(tr('Voltar', 'Back')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: line),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: pad,
                vertical: small ? 34 : 56,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  eyebrow(tr('VÍDEO DE DEMONSTRAÇÃO', 'DEMO VIDEO')),
                  const SizedBox(height: 14),
                  txt(
                    tr(
                      'A missão em 30 segundos.',
                      'The mission in 30 seconds.',
                    ),
                    size: small ? 32 : 44,
                    weight: FontWeight.w700,
                    height: 1.1,
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: txt(
                      tr(
                        'Gravação real do protótipo, com narração e legendas em inglês. Mostra a decisão, o resultado e a comparação entre estratégias.',
                        'Real prototype footage with English narration and subtitles. It shows the decision, the outcome and the comparison between strategies.',
                      ),
                      color: muted,
                    ),
                  ),
                  const SizedBox(height: 28),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: const AspectRatio(
                        aspectRatio: 16 / 9,
                        child: VideoEmbed(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 14,
                    runSpacing: 12,
                    children: [
                      outlineButton(
                        tr('Abrir no YouTube', 'Open on YouTube'),
                        Icons.open_in_new,
                        () => openLink(demoVideoUrl),
                      ),
                      FilledButton.icon(
                        onPressed: onStart,
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        label: Text(tr('Jogar agora', 'Play now')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

class VideoEmbed extends StatefulWidget {
  const VideoEmbed({super.key});
  @override
  State<VideoEmbed> createState() => _VideoEmbedState();
}

class _VideoEmbedState extends State<VideoEmbed> {
  static int nextId = 0;
  late final String viewType;
  @override
  void initState() {
    super.initState();
    viewType = 'aurora-video-${nextId++}';
    final frame = web.HTMLIFrameElement()
      ..src = 'https://www.youtube-nocookie.com/embed/$demoVideoId?rel=0'
      ..title = tr(
        'Vídeo de demonstração da Base Aurora',
        'Base Aurora demo video',
      );
    frame.setAttribute(
      'allow',
      'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share',
    );
    frame.setAttribute('allowfullscreen', '');
    frame.setAttribute('loading', 'lazy');
    frame.style
      ..border = '0'
      ..width = '100%'
      ..height = '100%';
    ui_web.platformViewRegistry.registerViewFactory(viewType, (_) => frame);
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: viewType);
}

class MissionPage extends StatefulWidget {
  final VoidCallback onExit;
  const MissionPage({super.key, required this.onExit});
  @override
  State<MissionPage> createState() => _MissionPageState();
}

class _MissionPageState extends State<MissionPage> {
  int stage = 0, session = 0;
  bool motion = !web.window
      .matchMedia('(prefers-reduced-motion: reduce)')
      .matches;
  Strategy choice = Strategy.conserve, alternative = Strategy.reserve;
  Resource? expectation, sacrifice;
  MissionOutcome? result;
  String selected = 'habitat';
  int? quiz;
  final scroll = ScrollController();
  void next(int n) {
    setState(() => stage = n);
    if (scroll.hasClients)
      scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
  }

  void reset() {
    setState(() {
      stage = 0;
      choice = Strategy.conserve;
      alternative = Strategy.reserve;
      expectation = null;
      sacrifice = null;
      result = null;
      quiz = null;
      selected = 'habitat';
      session++;
    });
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  Future<void> aura(String intent) async {
    final future = knowledge.ask(intent, choice, expectation, result != null);
    sceneCovered.value = true;
    try {
      await showModalBottomSheet(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        backgroundColor: surface,
        builder: (context) => ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .85,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                eyebrow(tr('COMANDANTE AURA', 'COMMANDER AURA')),
                const SizedBox(height: 12),
                txt(
                  intent == 'hint'
                      ? tr('Uma pista para pensar', 'A hint to think about')
                      : intent == 'science'
                      ? tr(
                          'O que a ciência explica',
                          'What the science explains',
                        )
                      : tr(
                          'Sua decisão, explicada',
                          'Your decision, explained',
                        ),
                  size: 26,
                  weight: FontWeight.bold,
                ),
                const SizedBox(height: 20),
                FutureBuilder<AuraAnswer>(
                  future: future,
                  builder: (context, s) {
                    if (!s.hasData)
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: CircularProgressIndicator(color: accent),
                        ),
                      );
                    final a = s.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        txt(a.text, size: 17),
                        const SizedBox(height: 24),
                        eyebrow(
                          tr('REFERÊNCIAS RECUPERADAS', 'RETRIEVED REFERENCES'),
                        ),
                        const SizedBox(height: 10),
                        ...a.sources.map(
                          (s) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: txt(
                              s.title,
                              size: 15,
                              weight: FontWeight.bold,
                            ),
                            subtitle: txt(s.source, size: 12, color: muted),
                            trailing: const Icon(
                              Icons.open_in_new,
                              size: 17,
                              color: accent,
                            ),
                            onTap: () => openLink(s.url),
                          ),
                        ),
                        const Divider(color: line),
                        txt(
                          a.mode +
                              tr(
                                ' · A consulta não altera os recursos da missão.',
                                ' · The query does not change the mission resources.',
                              ),
                          size: 12,
                          color: muted,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } finally {
      sceneCovered.value = false;
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final narrow = c.maxWidth < 1000;
      final contentWidth = math.min(c.maxWidth - 40, 1400.0);
      final state = result?.state ?? Simulation.initial;
      return SingleChildScrollView(
        controller: scroll,
        child: Center(
          child: SizedBox(
            width: contentWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      brand(onTap: widget.onExit),
                      Row(
                        children: [
                          if (c.maxWidth > 650)
                            eyebrow(
                              tr(
                                'MISSÃO 01 / A POEIRA CHEGOU',
                                'MISSION 01 / THE DUST HAS ARRIVED',
                              ),
                            ),
                          const SizedBox(width: 12),
                          if (c.maxWidth > 620)
                            langSwitch()
                          else
                            IconButton(
                              tooltip: appLang.value == AppLang.en
                                  ? tr(
                                      'Mudar para português',
                                      'Switch to Portuguese',
                                    )
                                  : tr(
                                      'Mudar para inglês',
                                      'Switch to English',
                                    ),
                              onPressed: () => chooseLang(
                                appLang.value == AppLang.en
                                    ? AppLang.pt
                                    : AppLang.en,
                              ),
                              icon: Text(
                                appLang.value == AppLang.en ? 'PT' : 'EN',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          const SizedBox(width: 4),
                          IconButton(
                            tooltip: motion
                                ? tr('Pausar animações', 'Pause animations')
                                : tr('Ativar animações', 'Enable animations'),
                            onPressed: () => setState(() => motion = !motion),
                            icon: Icon(
                              motion
                                  ? Icons.pause_circle_outline
                                  : Icons.play_circle_outline,
                              size: 21,
                            ),
                          ),
                          IconButton(
                            tooltip: tr(
                              'Fontes e ciência',
                              'Sources & science',
                            ),
                            onPressed: () => sources(context),
                            icon: const Icon(
                              Icons.menu_book_outlined,
                              size: 21,
                            ),
                          ),
                          IconButton(
                            tooltip: tr('Reiniciar missão', 'Restart mission'),
                            onPressed: () async {
                              sceneCovered.value = true;
                              final restart = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: Text(
                                    tr(
                                      'Reiniciar a missão?',
                                      'Restart the mission?',
                                    ),
                                  ),
                                  content: Text(
                                    tr(
                                      'As escolhas desta sessão serão apagadas.',
                                      "This session's choices will be erased.",
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(c, false),
                                      child: Text(
                                        tr(
                                          'Continuar missão',
                                          'Continue mission',
                                        ),
                                      ),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(c, true),
                                      child: Text(tr('Reiniciar', 'Restart')),
                                    ),
                                  ],
                                ),
                              );
                              sceneCovered.value = false;
                              if (restart == true) reset();
                            },
                            icon: const Icon(Icons.refresh, size: 21),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: line),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 18,
                  runSpacing: 10,
                  children:
                      [
                            tr('Explorar', 'Explore'),
                            tr('Prever', 'Predict'),
                            tr('Observar', 'Observe'),
                            tr('Comparar', 'Compare'),
                            tr('Explicar', 'Explain'),
                          ]
                          .asMap()
                          .entries
                          .map(
                            (e) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  e.key < stage
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  size: 15,
                                  color: e.key <= stage ? accent : muted,
                                ),
                                const SizedBox(width: 6),
                                txt(
                                  '${e.key + 1}. ${e.value}',
                                  size: 12,
                                  color: e.key == stage ? white : muted,
                                ),
                              ],
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: Resource.values
                      .map((r) => resourceTile(r, state, contentWidth, narrow))
                      .toList(),
                ),
                const SizedBox(height: 10),
                txt(
                  tr(
                    'Unidades didáticas (0–100). Na exposição, menor é melhor. Estado inicial preservado para a comparação.',
                    'Didactic units (0–100). For exposure, lower is better. Initial state preserved for comparison.',
                  ),
                  size: 10,
                  color: muted,
                ),
                const SizedBox(height: 24),
                if (narrow) ...[
                  scenePanel(),
                  const SizedBox(height: 20),
                  controlPanel(),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 17, child: scenePanel()),
                      const SizedBox(width: 22),
                      Expanded(flex: 11, child: controlPanel()),
                    ],
                  ),
                const SizedBox(height: 24),
                if (stage <= 1) strategySelector(narrow),
                if (stage == 2) balancePanel(),
                if (stage == 3) comparisonPanel(narrow),
                if (stage == 4) debrief(),
                const SizedBox(height: 35),
                const Divider(color: line),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Wrap(
                    spacing: 25,
                    runSpacing: 8,
                    children: [
                      txt('KERA / BASE AURORA', size: 10, color: muted),
                      txt(
                        tr(
                          'Simulação educativa. Regras v1.0. Nenhum indicador representa dose ou previsão real.',
                          'Educational simulation. Rules v1.0. No indicator represents real dose or prediction.',
                        ),
                        size: 10,
                        color: muted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  Widget resourceTile(Resource r, MissionState s, double width, bool narrow) {
    final val = s.values[r]!;
    final color = r == Resource.radiation
        ? const Color(0xFFBAA5EE)
        : r == Resource.energy
        ? accent
        : r == Resource.food
        ? green
        : const Color(0xFF8CBEDB);
    return SizedBox(
      width: width < 600 ? (width - 12) / 2 : (width - 48) / 5,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(iconFor(r), size: 16, color: color),
                const SizedBox(width: 7),
                txt(r.label, size: 11, color: muted),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: motion ? 700 : 0),
                  tween: Tween<double>(
                    begin: Simulation.initial.values[r]!.toDouble(),
                    end: val.toDouble(),
                  ),
                  builder: (context, value, child) => txt(
                    '${value.round()}',
                    size: 29,
                    weight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 6),
                txt('/100', size: 11, color: muted),
              ],
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: val.clamp(0, 100) / 100,
              color: color,
              backgroundColor: line,
              minHeight: 3,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  IconData iconFor(Resource r) => switch (r) {
    Resource.energy => Icons.bolt,
    Resource.water => Icons.water_drop_outlined,
    Resource.oxygen => Icons.air,
    Resource.food => Icons.eco_outlined,
    Resource.radiation => Icons.shield_outlined,
  };
  Widget scenePanel() => Container(
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: line),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              eyebrow(
                tr('BASE AURORA / VISUALIZAÇÃO 3D', 'BASE AURORA / 3D VIEW'),
              ),
              txt(
                tr('MARTE · CENÁRIO DIDÁTICO', 'MARS · DIDACTIC SCENARIO'),
                size: 9,
                color: muted,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 390,
          child: ValueListenableBuilder<bool>(
            valueListenable: sceneCovered,
            builder: (context, covered, scene) => Stack(
              fit: StackFit.expand,
              children: [
                if (covered)
                  ColoredBox(
                    color: surface,
                    child: Center(
                      child: txt(
                        tr(
                          'Cena 3D pausada enquanto o diálogo está aberto',
                          '3D scene paused while the dialog is open',
                        ),
                        size: 12,
                        color: muted,
                      ),
                    ),
                  ),
                Offstage(offstage: covered, child: scene),
              ],
            ),
            child: BaseScene(
              key: ValueKey(session),
              selected: selected,
              strategy: result?.strategy.name ?? 'normal',
              motion: motion,
              onSelect: (id) => setState(() => selected = id),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Wrap(
            spacing: 6,
            runSpacing: 5,
            children:
                {
                      'habitat': tr('Habitat', 'Habitat'),
                      'solar': tr('Painéis solares', 'Solar panels'),
                      'greenhouse': tr('Estufa', 'Greenhouse'),
                      'shelter': tr('Abrigo', 'Shelter'),
                    }.entries
                    .map(
                      (e) => ChoiceChip(
                        label: Text(
                          e.value,
                          style: const TextStyle(fontSize: 11),
                        ),
                        selected: selected == e.key,
                        onSelected: (_) => setState(() => selected = e.key),
                        selectedColor: accent.withValues(alpha: .15),
                        side: BorderSide(
                          color: selected == e.key ? accent : line,
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: txt(moduleDescription, size: 12, color: muted),
        ),
      ],
    ),
  );
  String get moduleDescription => switch (selected) {
    'solar' => tr(
      'Painéis solares: a poeira reduz a geração. A bateria oferece uma reserva limitada para os sistemas.',
      'Solar panels: dust reduces generation. The battery offers a limited reserve for the systems.',
    ),
    'greenhouse' => tr(
      'Estufa: cultivo estabelecido usa água e energia. Sua contribuição para os alimentos depende do modo escolhido.',
      'Greenhouse: the established crop uses water and energy. Its contribution to food depends on the chosen mode.',
    ),
    'shelter' => tr(
      'Abrigo: representa a proteção disponível. A manutenção externa aumenta o índice didático de exposição.',
      'Shelter: represents available protection. External maintenance increases the didactic exposure index.',
    ),
    _ => tr(
      'Habitat: mantém o suporte à vida. O cenário preserva a operação dos sistemas essenciais.',
      'Habitat: keeps life support running. The scenario preserves essential systems operation.',
    ),
  };
  Widget controlPanel() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          eyebrow(
            stage < 2
                ? tr('TRANSMISSÃO DA MISSÃO', 'MISSION TRANSMISSION')
                : tr('REGISTRO DA MISSÃO', 'MISSION LOG'),
          ),
          const SizedBox(height: 16),
          txt(
            switch (stage) {
              0 => tr('A poeira chegou.', 'The dust has arrived.'),
              1 => tr('Antes de decidir…', 'Before deciding…'),
              2 => tr('Essa foi a sua escolha.', 'That was your choice.'),
              3 => tr(
                'Outra escolha.\nO mesmo ponto de partida.',
                'Another choice.\nThe same starting point.',
              ),
              _ => tr('O que você aprendeu?', 'What did you learn?'),
            },
            size: 28,
            weight: FontWeight.bold,
            height: 1.2,
          ),
          const SizedBox(height: 17),
          if (stage == 0) ...[
            txt(
              tr(
                'A geração solar caiu. Água, oxigênio e alimentação continuam dependendo dos sistemas da base.',
                'Solar generation has dropped. Water, oxygen and food still depend on the base systems.',
              ),
              color: muted,
              size: 15,
            ),
            const SizedBox(height: 15),
            txt(
              tr(
                'Seu objetivo é manter a missão viável e entender o custo da estratégia escolhida.',
                'Your goal is to keep the mission viable and understand the cost of the strategy you chose.',
              ),
              size: 14,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => next(1),
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: Text(tr('Preparar minha decisão', 'Prepare my decision')),
            ),
          ],
          if (stage == 1) ...[
            txt(
              tr(
                'Sua estratégia: ${choice.title}. Registre sua expectativa antes de ver o resultado.',
                'Your strategy: ${choice.title}. Record your expectation before seeing the result.',
              ),
              size: 14,
              color: muted,
            ),
            const SizedBox(height: 18),
            predictionField(
              tr(
                'O que você espera preservar?',
                'What do you expect to preserve?',
              ),
              expectation,
              (v) => setState(() => expectation = v),
            ),
            const SizedBox(height: 14),
            predictionField(
              tr(
                'Qual custo você espera assumir?',
                'What cost do you expect to take on?',
              ),
              sacrifice,
              (v) => setState(() => sacrifice = v),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () {
                setState(() => result = Simulation.run(choice));
                alternative = choice == Strategy.reserve
                    ? Strategy.conserve
                    : Strategy.reserve;
                next(2);
              },
              icon: const Icon(Icons.play_arrow, size: 18),
              label: Text(tr('Confirmar e simular', 'Confirm and simulate')),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => next(0),
              child: Text(tr('Voltar à exploração', 'Back to exploration')),
            ),
          ],
          if (stage == 2) ...[
            txt(choice.title, size: 17, weight: FontWeight.bold),
            const SizedBox(height: 12),
            txt(Simulation.explanation(choice), size: 14, color: muted),
            const SizedBox(height: 16),
            txt(
              tr(
                'Você esperava preservar: ${expectation?.label ?? 'Não sei'}.\nCusto previsto: ${sacrifice?.label ?? 'Não sei'}.',
                "You expected to preserve: ${expectation?.label ?? "I don't know"}.\nExpected cost: ${sacrifice?.label ?? "I don't know"}.",
              ),
              size: 13,
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () => next(3),
              icon: const Icon(Icons.compare_arrows, size: 18),
              label: Text(
                tr('Comparar outra estratégia', 'Compare another strategy'),
              ),
            ),
          ],
          if (stage == 3) ...[
            txt(
              tr(
                'Mudamos somente a estratégia. O estado inicial e o evento permanecem iguais.',
                'We changed only the strategy. The initial state and the event stay the same.',
              ),
              size: 14,
              color: muted,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<Strategy>(
              initialValue: alternative,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: tr('Estratégia alternativa', 'Alternative strategy'),
              ),
              items: Strategy.values
                  .where((s) => s != choice)
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        s.title,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => alternative = v!),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () => next(4),
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: Text(tr('Concluir minha análise', 'Finish my analysis')),
            ),
          ],
          if (stage == 4) ...[
            txt(
              tr(
                'Manter a base funcionando é parte da missão. Explicar o compromisso entre os recursos completa o aprendizado.',
                'Keeping the base running is part of the mission. Explaining the trade-off between resources completes the learning.',
              ),
              size: 15,
              color: muted,
            ),
            const SizedBox(height: 20),
            outlineButton(
              tr('Baixar registro da missão', 'Download mission log'),
              Icons.download_outlined,
              downloadReport,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: reset,
              child: Text(tr('Explorar novamente', 'Explore again')),
            ),
          ],
          const SizedBox(height: 25),
          const Divider(color: line),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.auto_awesome_outlined, size: 20, color: accent),
              const SizedBox(width: 10),
              txt('AURA', size: 15, weight: FontWeight.bold),
              const Spacer(),
              txt(tr('MODO LOCAL', 'LOCAL MODE'), size: 9, color: muted),
            ],
          ),
          const SizedBox(height: 10),
          txt(
            tr(
              'Explicações revisadas com referências NASA. A IA não altera o estado da missão.',
              'Reviewed explanations with NASA references. The AI does not change the mission state.',
            ),
            size: 11,
            color: muted,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              outlineButton(
                result == null
                    ? tr('Uma pista', 'A hint')
                    : tr('Por que foi assim?', 'Why did that happen?'),
                Icons.chat_bubble_outline,
                () => aura(result == null ? 'hint' : 'explain'),
              ),
              outlineButton(
                tr('A ciência', 'The science'),
                Icons.menu_book_outlined,
                () => aura('science'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget predictionField(
    String label,
    Resource? value,
    ValueChanged<Resource?> changed,
  ) => DropdownButtonFormField<String>(
    key: ValueKey('$label-${value?.name}'),
    initialValue: value?.name ?? 'unknown',
    isExpanded: true,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 11),
    ),
    items: [
      DropdownMenuItem(
        value: 'unknown',
        child: Text(
          tr('Não sei ainda', 'Not sure yet'),
          style: const TextStyle(fontSize: 13),
        ),
      ),
      ...Resource.values.map(
        (r) => DropdownMenuItem(
          value: r.name,
          child: Text(
            r == Resource.radiation
                ? tr('Proteção / exposição', 'Protection / exposure')
                : r.label,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),
    ],
    onChanged: (v) => changed(
      v == 'unknown' ? null : Resource.values.firstWhere((r) => r.name == v),
    ),
  );
  Widget strategySelector(bool narrow) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      eyebrow(tr('ESTRATÉGIAS DISPONÍVEIS', 'AVAILABLE STRATEGIES')),
      const SizedBox(height: 15),
      LayoutBuilder(
        builder: (context, c) => Wrap(
          spacing: 12,
          runSpacing: 12,
          children: Strategy.values
              .map(
                (s) => SizedBox(
                  width: narrow ? c.maxWidth : (c.maxWidth - 24) / 3,
                  child: Semantics(
                    selected: choice == s,
                    button: true,
                    label: s.title,
                    child: InkWell(
                      onTap: () => setState(() => choice = s),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: choice == s
                              ? const Color(0xFF252329)
                              : surface,
                          border: Border.all(
                            color: choice == s ? accent : line,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  choice == s
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: choice == s ? accent : muted,
                                  size: 19,
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: txt(
                                    s.title,
                                    size: 15,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 13),
                            txt(s.detail, size: 12, color: muted),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    ],
  );
  Widget balancePanel() {
    final b = result!.balance;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          eyebrow(tr('O CÁLCULO DA ENERGIA', 'THE ENERGY CALCULATION')),
          const SizedBox(height: 12),
          txt(
            tr(
              '${Simulation.initial.energy} inicial + ${b['solarGeneration']} geração − ${b['lifeSupportConsumption']} suporte − ${b['greenhouseConsumption']} estufa − ${b['maintenanceConsumption']} manutenção = ${result!.state.energy}',
              '${Simulation.initial.energy} initial + ${b['solarGeneration']} generation − ${b['lifeSupportConsumption']} life support − ${b['greenhouseConsumption']} greenhouse − ${b['maintenanceConsumption']} maintenance = ${result!.state.energy}',
            ),
            size: 21,
            weight: FontWeight.bold,
          ),
          const SizedBox(height: 12),
          txt(
            tr(
              'Esses valores pertencem às regras da simulação. Não são medições ou projeções NASA.',
              'These values belong to the simulation rules. They are not NASA measurements or projections.',
            ),
            size: 12,
            color: muted,
          ),
        ],
      ),
    );
  }

  Widget comparisonPanel(bool narrow) {
    final a = result!, b = Simulation.run(alternative);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          eyebrow(tr('COMPARAÇÃO CONTROLADA', 'CONTROLLED COMPARISON')),
          const SizedBox(height: 15),
          txt(
            tr(
              'O que muda quando você escolhe diferente?',
              'What changes when you choose differently?',
            ),
            size: 24,
            weight: FontWeight.bold,
          ),
          const SizedBox(height: 20),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.1),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                children: [
                  tableCell(tr('Recurso', 'Resource'), muted),
                  tableCell(
                    narrow ? tr('Sua escolha', 'Your choice') : choice.title,
                    accent,
                  ),
                  tableCell(
                    narrow
                        ? tr('Alternativa', 'Alternative')
                        : alternative.title,
                    green,
                  ),
                ],
              ),
              ...Resource.values.map(
                (r) => TableRow(
                  children: [
                    tableCell(r.label, white),
                    tableCell(
                      '${a.state.values[r]}  (${a.delta(r) > 0 ? '+' : ''}${a.delta(r)})',
                      white,
                    ),
                    tableCell(
                      '${b.state.values[r]}  (${b.delta(r) > 0 ? '+' : ''}${b.delta(r)})',
                      green,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          txt(
            tr(
              'Valores finais e variação em relação ao mesmo estado inicial. Menor exposição é melhor. As demais reservas têm limites didáticos de viabilidade.',
              'Final values and change from the same initial state. Lower exposure is better. Other reserves have didactic viability limits.',
            ),
            size: 12,
            color: muted,
          ),
        ],
      ),
    );
  }

  Widget tableCell(String s, Color c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
    child: txt(s, size: 12, color: c),
  );
  Widget debrief() => Container(
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        eyebrow(tr('UMA ÚLTIMA PERGUNTA', 'ONE LAST QUESTION')),
        const SizedBox(height: 15),
        txt(
          tr(
            'Se a crise durasse mais, qual compromisso mereceria atenção ao reduzir a estufa?',
            'If the crisis lasted longer, which trade-off would deserve attention when reducing the greenhouse?',
          ),
          size: 23,
          weight: FontWeight.bold,
        ),
        const SizedBox(height: 16),
        ...[
          tr(
            'Preservar energia, mas reduzir a contribuição para os alimentos.',
            'Preserve energy, but reduce the contribution to food.',
          ),
          tr(
            'Preservar todos os recursos sem assumir nenhum custo.',
            'Preserve all resources without taking on any cost.',
          ),
          tr(
            'Aumentar automaticamente o oxigênio e eliminar a exposição.',
            'Automatically increase oxygen and eliminate exposure.',
          ),
        ].asMap().entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => setState(() => quiz = e.key),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  border: Border.all(color: quiz == e.key ? accent : line),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: txt(e.value, size: 14),
              ),
            ),
          ),
        ),
        if (quiz != null)
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: txt(
              quiz == 0
                  ? tr(
                      'Você identificou o compromisso. A estratégia pode preservar uma reserva e reduzir outra contribuição. A duração da missão muda a importância dessa escolha.',
                      'You identified the trade-off. A strategy can preserve one reserve and reduce another contribution. Mission duration changes how important that choice is.',
                    )
                  : tr(
                      'Reveja a comparação: reduzir uma operação pode economizar recursos, mas também diminuir sua contribuição. Tente explicar qual benefício tem um custo.',
                      'Revisit the comparison: reducing an operation can save resources, but it also lowers its contribution. Try to explain which benefit has a cost.',
                    ),
              color: quiz == 0 ? green : accent,
              size: 15,
            ),
          ),
      ],
    ),
  );
  void downloadReport() {
    final report = {
      'project': 'Base Aurora',
      'team': 'Kera',
      'rulesVersion': Simulation.version,
      'initialState': Simulation.initial.toJson(),
      'strategy': choice.name,
      'expectation': expectation?.name,
      'expectedCost': sacrifice?.name,
      'outcome': result?.state.toJson(),
      'alternative': alternative.name,
      'alternativeOutcome': Simulation.run(alternative).state.toJson(),
      'reflectionAnswer': quiz,
      'notice': tr(
        'Unidades e regras didáticas. Não representa missão ou dose real.',
        'Didactic units and rules. Does not represent a real mission or dose.',
      ),
    };
    final uri =
        'data:application/json;charset=utf-8,${Uri.encodeComponent(const JsonEncoder.withIndent('  ').convert(report))}';
    final a = web.HTMLAnchorElement()
      ..href = uri
      ..download = 'base-aurora-registro.json';
    a.click();
  }
}
