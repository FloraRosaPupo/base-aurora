import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../../i18n.dart';

class BaseScene extends StatefulWidget {
  final String selected;
  final String strategy;
  final bool motion;
  final ValueChanged<String> onSelect;
  const BaseScene({
    super.key,
    required this.selected,
    required this.strategy,
    this.motion = true,
    required this.onSelect,
  });
  @override
  State<BaseScene> createState() => _BaseSceneState();
}

class _BaseSceneState extends State<BaseScene> {
  static int nextId = 0;
  late final String viewType;
  late final web.HTMLIFrameElement frame;
  late final JSFunction listener;
  bool ready = false, failed = false;
  @override
  void initState() {
    super.initState();
    viewType = 'aurora-scene-${nextId++}';
    frame = web.HTMLIFrameElement()
      ..src = 'scene.html'
      ..title = tr(
        'Visualização 3D interativa da Base Aurora',
        'Interactive 3D view of Base Aurora',
      );
    frame.style
      ..border = '0'
      ..width = '100%'
      ..height = '100%';
    ui_web.platformViewRegistry.registerViewFactory(viewType, (_) => frame);
    listener = ((web.MessageEvent event) {
      if (event.origin != web.window.location.origin ||
          event.source != frame.contentWindow)
        return;
      try {
        final data =
            jsonDecode((event.data as JSString).toDart) as Map<String, dynamic>;
        if (data['type'] == 'ready') {
          if (mounted) setState(() => ready = true);
          sync();
        }
        if (data['type'] == 'error') {
          if (mounted) setState(() => failed = true);
        }
        if (data['type'] == 'select' &&
            ['habitat', 'solar', 'greenhouse', 'shelter'].contains(data['id']))
          widget.onSelect(data['id']);
      } catch (_) {}
    }).toJS;
    web.window.addEventListener('message', listener);
  }

  void sync() {
    frame.contentWindow?.postMessage(
      jsonEncode({
        'type': 'state',
        'selected': widget.selected,
        'strategy': widget.strategy,
        'motion': widget.motion,
        'lang': appLang.value.name,
      }).toJS,
      web.window.location.origin.toJS,
    );
  }

  @override
  void didUpdateWidget(covariant BaseScene old) {
    super.didUpdateWidget(old);
    if (ready) sync();
  }

  @override
  void dispose() {
    web.window.removeEventListener('message', listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(child: HtmlElementView(viewType: viewType)),
      if (!ready && !failed)
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFFFFA76D)),
              const SizedBox(height: 18),
              Text(tr('Preparando a base 3D…', 'Preparing the 3D base…')),
            ],
          ),
        ),
      if (failed)
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              tr(
                'O navegador não disponibilizou WebGL. Você pode continuar usando os controles dos módulos abaixo.',
                'The browser did not provide WebGL. You can keep using the module controls below.',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
    ],
  );
}
