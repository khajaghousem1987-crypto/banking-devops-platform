import http from 'k6/http'; import { sleep } from 'k6';
export const options={stages:[{duration:'30s',target:5},{duration:'1m',target:10},{duration:'30s',target:0}]};
const base=__ENV.BASE_URL||'http://localhost:5000';
export default function(){http.get(`${base}/`);if(Math.random()<0.2)http.get(`${base}/simulate-error`);sleep(1);}
