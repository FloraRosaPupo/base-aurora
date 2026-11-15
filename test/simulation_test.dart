import 'package:flutter_test/flutter_test.dart';
import 'package:base_aurora/features/mission/domain/simulation.dart';
void main(){
 test('conservation preserves more energy at a food cost',(){final a=Simulation.run(Strategy.conserve),b=Simulation.run(Strategy.reserve);expect(a.state.energy,greaterThan(b.state.energy));expect(a.state.food,lessThan(b.state.food));expect(a.state.water,greaterThan(b.state.water));});
 test('life support remains active under every available strategy',(){for(final s in Strategy.values){expect(Simulation.run(s).state.oxygen,79);}});
 test('external repair has an exposure tradeoff',(){expect(Simulation.run(Strategy.repair).state.radiation,greaterThan(Simulation.run(Strategy.reserve).state.radiation));});
 test('energy output reconciles with reported balance',(){for(final s in Strategy.values){final o=Simulation.run(s),b=o.balance;expect(o.state.energy,o.initial.energy+b['solarGeneration']!-b['lifeSupportConsumption']!-b['greenhouseConsumption']!-b['maintenanceConsumption']!);}});
 test('counterfactual preserves the original state',(){final first=Simulation.run(Strategy.conserve);Simulation.run(Strategy.reserve);expect(first.state.energy,58);expect(Simulation.initial.energy,65);});
 test('all provided strategies are viable from the default state',(){for(final s in Strategy.values){expect(Simulation.run(s).state.viable,isTrue);}});
 test('low reserves expose failure instead of silently clamping',(){const s=MissionState(energy:1);final o=Simulation.run(Strategy.reserve,start:s);expect(o.state.energy,-13);expect(o.state.viable,isFalse);});
 test('deterministic replay returns identical resources',(){expect(Simulation.run(Strategy.repair).state.toJson(),Simulation.run(Strategy.repair).state.toJson());});
}
