import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../mission/domain/simulation.dart';

class ScienceSource {
  final String id, title, source, url, topic, text;
  const ScienceSource(
    this.id,
    this.title,
    this.source,
    this.url,
    this.topic,
    this.text,
  );
  factory ScienceSource.fromJson(Map<String, dynamic> j) => ScienceSource(
    j['id'],
    j['title'],
    j['source'],
    j['url'],
    j['topic'],
    j['text'],
  );
}

class AuraAnswer {
  final String text, mode;
  final List<ScienceSource> sources;
  const AuraAnswer(this.text, this.mode, this.sources);
}

class KnowledgeService {
  List<ScienceSource> corpus = [];
  Future<void> load() async {
    final data =
        jsonDecode(await rootBundle.loadString('assets/knowledge.json'))
            as List;
    corpus = data
        .map((e) => ScienceSource.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  List<ScienceSource> retrieve(String query) {
    final words = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2)
        .toSet();
    final scored = corpus
        .map(
          (s) => (
            s,
            words
                .where(
                  (w) => ('${s.topic} ${s.text}').toLowerCase().contains(w),
                )
                .length,
          ),
        )
        .toList();
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    return scored.where((s) => s.$2 > 0).take(2).map((s) => s.$1).toList();
  }

  Future<AuraAnswer> ask(
    String intent,
    Strategy choice,
    Resource? expected,
    bool decided,
  ) async {
    final query =
        '${choice.detail} ${intent == 'science' ? 'ciência energia suporte estufa radiação' : ''}';
    final found = retrieve(query);
    const endpoint = String.fromEnvironment('AURA_API_URL');
    if (endpoint.isNotEmpty) {
      try {
        final payload = <String, dynamic>{
          'intent': intent,
          'phase': decided ? 'after' : 'before',
          'strategy': choice.name,
          'expectation': expected?.name,
          'state': Simulation.initial.toJson(),
          'rulesVersion': Simulation.version,
        };
        if (decided) payload['outcome'] = Simulation.run(choice).state.toJson();
        final response = await http
            .post(
              Uri.parse(endpoint),
              headers: {'content-type': 'application/json'},
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final j = jsonDecode(response.body) as Map<String, dynamic>;
          final ids = (j['citations'] as List).cast<String>();
          final valid = corpus.where((s) => ids.contains(s.id)).toList();
          if (j['text'] is String && valid.isNotEmpty)
            return AuraAnswer(
              j['text'],
              j['mode'] == 'llm'
                  ? 'IA com recuperação de fontes'
                  : 'Explicação local revisada',
              valid,
            );
        }
      } catch (_) {
        /* Reviewed local explanation remains available. */
      }
    }
    final hint = switch (choice) {
      Strategy.conserve =>
        'Observe a relação entre o consumo da estufa e a contribuição dela para os alimentos. Qual recurso você quer preservar e qual compromisso aceita?',
      Strategy.reserve =>
        'A reserva mantém os sistemas em funcionamento por um período. Pense no que muda na energia disponível ao final, mesmo quando os alimentos recebem maior contribuição.',
      Strategy.repair =>
        'Uma atividade externa pode recuperar capacidade, mas exige recursos e envolve exposição. Compare esse custo com permanecer protegido e usar a reserva.',
    };
    final message = intent == 'hint' && !decided
        ? hint
        : intent == 'science'
        ? '${found.map((s) => s.text).join('\n\n')}\n\nOs números da missão são unidades didáticas. As referências descrevem princípios e experiências reais, não validam as constantes da simulação.'
        : Simulation.explanation(choice) +
              (expected == null
                  ? ' Você marcou “não sei”. Compare agora as alternativas para construir sua explicação.'
                  : ' Sua expectativa registrada foi preservar ${expected.label.toLowerCase()}. Veja as variações e compare com a outra estratégia antes de concluir.');
    return AuraAnswer(message, 'Explicação local revisada', found);
  }
}
