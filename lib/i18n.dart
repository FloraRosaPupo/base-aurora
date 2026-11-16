import 'package:flutter/foundation.dart';

enum AppLang { pt, en }

/// Idioma atual da interface. Alterado pelo seletor PT/EN no cabeçalho.
final appLang = ValueNotifier<AppLang>(AppLang.pt);

/// Retorna o texto em português ou inglês conforme o idioma atual.
String tr(String pt, String en) => appLang.value == AppLang.en ? en : pt;
