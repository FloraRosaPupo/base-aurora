export const INITIAL=Object.freeze({energy:65,water:72,oxygen:76,food:68,radiation:8});
export const STRATEGIES=['conserve','reserve','repair'];
export function simulate(strategy,start=INITIAL){
 if(!STRATEGIES.includes(strategy))throw new Error('Invalid strategy');
 const reduced=strategy==='conserve',repair=strategy==='repair';
 return {energy:start.energy+16+(repair?18:0)-18-(reduced?5:12)-(repair?8:0),water:start.water+5-8-(reduced?3:8),oxygen:start.oxygen+12-9,food:start.food-10+(reduced?1:5),radiation:start.radiation+(repair?18:2)};
}
