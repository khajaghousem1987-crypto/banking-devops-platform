FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
RUN useradd --create-home --shell /usr/sbin/nologin appuser
EXPOSE 5000
ENV TMPDIR=/tmp
CMD ["gunicorn","--bind","0.0.0.0:5000","--workers","2","--threads","2","--timeout","60","--worker-tmp-dir","/tmp","--user","appuser","--group","appuser","app:app"]
