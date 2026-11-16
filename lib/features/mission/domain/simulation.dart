import '../../../i18n.dart';

enum Strategy { conserve, reserve, repair }

enum Resource { energy, water, oxygen, food, radiation }

extension StrategyInfo on Strategy {
  String get title => switch (this) {
    Strategy.conserve => tr('Priorizar a reserva', 'Prioritize the reserve'),
    Strategy.reserve => tr('Manter a estufa', 'Keep the greenhouse'),
    Strategy.repair => tr('Manutenção externa', 'External maintenance'),
  };
  String get detail => switch (this) {
    Strategy.conserve => tr(
      'Reduzir a operação da estufa para consumir menos água e energia.',
      'Reduce greenhouse operation to use less water and energy.',
    ),
    Strategy.reserve => tr(
      'Usar a energia armazenada para manter a estufa em operação normal.',
      'Use the stored energy to keep the greenhouse running normally.',
    ),
    Strategy.repair => tr(
      'Recuperar parte da geração solar, com gasto de energia e maior exposição externa.',
      'Recover part of the solar generation, spending energy and increasing external exposure.',
    ),
  };
  Resource get preserved =>
      this == Strategy.reserve ? Resource.food : Resource.energy;
  Resource get sacrificed => switch (this) {
    Strategy.conserve => Resource.food,
    Strategy.reserve => Resource.energy,
    Strategy.repair => Resource.radiation,
  };
}

extension ResourceInfo on Resource {
  String get label => switch (this) {
    Resource.energy => tr('Energia', 'Energy'),
    Resource.water => tr('Água', 'Water'),
    Resource.oxygen => tr('Oxigênio', 'Oxygen'),
    Resource.food => tr('Alimentos', 'Food'),
    Resource.radiation => tr('Exposição', 'Exposure'),
  };
}

class MissionState {
  final int energy, water, oxygen, food, radiation;
  const MissionState({
    this.energy = 65,
    this.water = 72,
    this.oxygen = 76,
    this.food = 68,
    this.radiation = 8,
  });
  Map<Resource, int> get values => {
    Resource.energy: energy,
    Resource.water: water,
    Resource.oxygen: oxygen,
    Resource.food: food,
    Resource.radiation: radiation,
  };
  Map<String, int> toJson() => {
    for (final e in values.entries) e.key.name: e.value,
  };
  bool get viable =>
      energy > 0 && water > 0 && oxygen > 0 && food > 0 && radiation < 60;
}

class MissionOutcome {
  final Strategy strategy;
  final MissionState initial, state;
  final Map<String, int> balance;
  const MissionOutcome(this.strategy, this.initial, this.state, this.balance);
  int delta(Resource r) => state.values[r]! - initial.values[r]!;
}

class Simulation {
  static const version = 'aurora-educational-1';
  static const initial = MissionState();
  static MissionOutcome run(Strategy choice, {MissionState start = initial}) {
    final reduced = choice == Strategy.conserve;
    final maintenance = choice == Strategy.repair;
    final generation = 16 + (maintenance ? 18 : 0);
    const support = 18;
    final greenhouse = reduced ? 5 : 12;
    final repairCost = maintenance ? 8 : 0;
    final next = MissionState(
      energy: start.energy + generation - support - greenhouse - repairCost,
      water: start.water + 5 - 8 - (reduced ? 3 : 8),
      oxygen: start.oxygen + 12 - 9,
      food: start.food - 10 + (reduced ? 1 : 5),
      radiation: start.radiation + (maintenance ? 18 : 2),
    );
    return MissionOutcome(choice, start, next, {
      'solarGeneration': generation,
      'lifeSupportConsumption': support,
      'greenhouseConsumption': greenhouse,
      'maintenanceConsumption': repairCost,
    });
  }

  static String explanation(Strategy choice) => switch (choice) {
    Strategy.conserve => tr(
      'Você preservou mais energia e água. A estufa operou em modo reduzido, então sua contribuição para os alimentos foi menor neste período didático. O suporte à vida permaneceu ativo.',
      'You preserved more energy and water. The greenhouse ran in reduced mode, so its contribution to food was smaller in this didactic period. Life support remained active.',
    ),
    Strategy.reserve => tr(
      'Você manteve maior contribuição da estufa para os alimentos. O custo foi consumir mais da reserva de energia e mais água. O suporte à vida permaneceu ativo.',
      'You kept a larger greenhouse contribution to food. The cost was drawing more from the energy reserve and using more water. Life support remained active.',
    ),
    Strategy.repair => tr(
      'A manutenção recuperou parte da geração neste cenário roteirizado, mas consumiu energia e aumentou a exposição externa. Recuperação e exposição são regras didáticas, não previsões de uma missão real.',
      'Maintenance recovered part of the generation in this scripted scenario, but it consumed energy and increased external exposure. Recovery and exposure are didactic rules, not predictions for a real mission.',
    ),
  };
}
