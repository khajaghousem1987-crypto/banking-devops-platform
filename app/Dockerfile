FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# OS security updates
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy dependencies
COPY requirements.txt .

# Install application dependencies
RUN python -m pip install --no-cache-dir --upgrade pip \
    && python -m pip install --no-cache-dir -r requirements.txt \
    && python -m pip install --no-cache-dir --upgrade \
       "msgpack>=1.2.1" \
       "setuptools>=78.1.1"

# IMPORTANT:
# Remove stale dist-info metadata left from vulnerable versions
RUN find /usr/local/lib/python3.12/site-packages \
      -type d \
      \( -name "msgpack-1.1.2.dist-info" \
         -o -name "setuptools-70.3.0.dist-info" \) \
      -prune -exec rm -rf {} +

# Fail Docker build itself if wrong versions are active
RUN python -c "import msgpack; print('msgpack:', msgpack.__version__)" \
    && python -c "import importlib.metadata as m; print('setuptools:', m.version('setuptools'))"

COPY . .

RUN useradd --create-home --shell /usr/sbin/nologin appuser \
    && chown -R appuser:appuser /app

USER appuser

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--threads", "2", "--timeout", "60", "app:app"]