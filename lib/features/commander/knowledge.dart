import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../i18n.dart';
import '../mission/domain/simulation.dart';

class ScienceSource {
  final String id, titlePt, titleEn, source, url, topic, textPt, textEn;
  const ScienceSource(
    this.id,
    this.titlePt,
    this.titleEn,
    this.source,
    this.url,
    this.topic,
    this.textPt,
    this.textEn,
  );
  factory ScienceSource.fromJson(Map<String, dynamic> j) => ScienceSource(
    j['id'],
    j['title'],
    j['title_en'] ?? j['title'],
    j['source'],
    j['url'],
    j['topic'],
    j['text'],
    j['text_en'] ?? j['text'],
  );
  String get title => tr(titlePt, titleEn);
  String get text => tr(textPt, textEn);
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
                  (w) => '${s.topic} ${s.textPt} ${s.titlePt} ${s.textEn}'
                      .toLowerCase()
                      .contains(w),
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
        '${choice.detail} ${intent == 'science' ? 'ciência energia suporte estufa radiação science energy life support greenhouse radiation' : ''}';
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
                  ? tr(
                      'IA com recuperação de fontes',
                      'AI with source retrieval',
                    )
                  : tr(
                      'Explicação local revisada',
                      'Reviewed local explanation',
                    ),
              valid,
            );
        }
      } catch (_) {
        /* Reviewed local explanation remains available. */
      }
    }
    final hint = switch (choice) {
      Strategy.conserve => tr(
        'Observe a relação entre o consumo da estufa e a contribuição dela para os alimentos. Qual recurso você quer preservar e qual compromisso aceita?',
        'Notice the link between greenhouse consumption and its contribution to food. Which resource do you want to preserve, and which trade-off do you accept?',
      ),
      Strategy.reserve => tr(
        'A reserva mantém os sistemas em funcionamento por um período. Pense no que muda na energia disponível ao final, mesmo quando os alimentos recebem maior contribuição.',
        'The reserve keeps systems running for a period. Think about what changes in the energy available at the end, even when food gets a larger contribution.',
      ),
      Strategy.repair => tr(
        'Uma atividade externa pode recuperar capacidade, mas exige recursos e envolve exposição. Compare esse custo com permanecer protegido e usar a reserva.',
        'An external activity can recover capacity, but it demands resources and involves exposure. Compare that cost with staying protected and using the reserve.',
      ),
    };
    final message = intent == 'hint' && !decided
        ? hint
        : intent == 'science'
        ? tr(
            '${found.map((s) => s.text).join('\n\n')}\n\nOs números da missão são unidades didáticas. As referências descrevem princípios e experiências reais, não validam as constantes da simulação.',
            '${found.map((s) => s.text).join('\n\n')}\n\nThe mission numbers are didactic units. The references describe principles and real experiments; they do not validate the simulation constants.',
          )
        : Simulation.explanation(choice) +
              (expected == null
                  ? tr(
                      ' Você marcou “não sei”. Compare agora as alternativas para construir sua explicação.',
                      ' You marked “don\'t know”. Now compare the alternatives to build your explanation.',
                    )
                  : tr(
                      ' Sua expectativa registrada foi preservar ${expected.label.toLowerCase()}. Veja as variações e compare com a outra estratégia antes de concluir.',
                      ' Your recorded expectation was to preserve ${expected.label.toLowerCase()}. Look at the variations and compare with the other strategy before finishing.',
                    ));
    return AuraAnswer(
      message,
      tr('Explicação local revisada', 'Reviewed local explanation'),
      found,
    );
  }
}
