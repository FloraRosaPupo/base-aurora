import http from 'node:http';
import {help,corpus} from './rag.mjs';
const port=Number(process.env.PORT||8787),origins=(process.env.ALLOWED_ORIGINS||'http://localhost:3000').split(',');
const rate=new Map();
const server=http.createServer(async(req,res)=>{
 const origin=req.headers.origin;
 if(origin&&!origins.includes(origin)){res.writeHead(403);res.end('Origin not allowed');return;}
 if(origin)res.setHeader('access-control-allow-origin',origin);
 res.setHeader('vary','Origin');res.setHeader('content-type','application/json; charset=utf-8');res.setHeader('x-content-type-options','nosniff');
 if(req.method==='OPTIONS'){res.setHeader('access-control-allow-methods','POST,GET,OPTIONS');res.setHeader('access-control-allow-headers','content-type');res.writeHead(204);res.end();return;}
 if(req.method==='GET'&&req.url==='/health'){res.end(JSON.stringify({ok:true,generationConfigured:!!(process.env.LLM_API_KEY&&process.env.LLM_BASE_URL&&process.env.LLM_MODEL)}));return;}
 if(req.method==='GET'&&req.url==='/science/sources'){res.end(JSON.stringify(corpus.map(({id,title,source,url})=>({id,title,source,url}))));return;}
 if(req.method!=='POST'||req.url!=='/commander/help'){res.writeHead(404);res.end('{"error":"Not found"}');return;}
 const key=req.socket.remoteAddress,now=Date.now(),recent=(rate.get(key)||[]).filter(t=>now-t<60000);
 if(recent.length>=20){res.writeHead(429);res.end('{"error":"Please wait"}');return;}
 recent.push(now);rate.set(key,recent);
 for(const [ip,times]of rate)if(!times.some(t=>now-t<60000))rate.delete(ip);
 let body='';
 try{for await(const chunk of req){body+=chunk;if(Buffer.byteLength(body)>8192){res.writeHead(413);res.end('{"error":"Body too large"}');return;}}const result=await help(JSON.parse(body));res.end(JSON.stringify(result));}
 catch(e){res.writeHead(e.message.startsWith('Invalid')||e.message.startsWith('Unknown')?400:503);res.end(JSON.stringify({error:'Não foi possível gerar a explicação. O aplicativo pode usar a alternativa local revisada.'}));}
});
server.listen(port,()=>console.log('AURA backend ready on port '+port));
