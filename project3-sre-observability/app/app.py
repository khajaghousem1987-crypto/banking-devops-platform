import random,time
from flask import Flask,jsonify,Response
from prometheus_client import Counter,Histogram,generate_latest,CONTENT_TYPE_LATEST
app=Flask(__name__)
REQ=Counter("banking_http_requests_total","HTTP requests",["method","endpoint","status"])
LAT=Histogram("banking_http_request_duration_seconds","HTTP latency",["endpoint"],buckets=(.05,.1,.2,.5,1,2,5))
@app.route("/")
def home():
 with LAT.labels("/").time():
  REQ.labels("GET","/","200").inc(); return "<h1>Banking DevOps Platform</h1><h2>Project 3 - SRE Observability</h2><p>Metrics + Logs + Traces + SLOs + Alerting</p><h3>Environment: DEV</h3>"
@app.route("/health")
def health(): REQ.labels("GET","/health","200").inc(); return jsonify(status="healthy")
@app.route("/simulate-error")
def err():
 with LAT.labels("/simulate-error").time():
  time.sleep(random.uniform(.05,.3)); REQ.labels("GET","/simulate-error","500").inc(); return jsonify(status="error",message="Synthetic SRE lab incident"),500
@app.route("/metrics")
def metrics(): return Response(generate_latest(),mimetype=CONTENT_TYPE_LATEST)
if __name__=="__main__": app.run(host="0.0.0.0",port=5000)
