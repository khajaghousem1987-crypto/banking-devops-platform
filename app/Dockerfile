# ============================================================
# Banking DevOps Platform - Application Dockerfile
# ============================================================

FROM python:3.12-slim

# ------------------------------------------------------------
# Environment settings
# ------------------------------------------------------------
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# ------------------------------------------------------------
# Apply Debian security updates
# Fixes OS-level vulnerabilities reported by Trivy
# ------------------------------------------------------------
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Application directory
# ------------------------------------------------------------
WORKDIR /app

# ------------------------------------------------------------
# Upgrade Python packaging/security dependencies
#
# Trivy findings:
# msgpack 1.1.2   -> fixed in 1.2.1
# setuptools 70.3 -> fixed in 78.1.1
# ------------------------------------------------------------
RUN python -m pip install --no-cache-dir --upgrade \
    pip \
    "setuptools>=78.1.1" \
    "msgpack>=1.2.1"

# ------------------------------------------------------------
# Copy dependency file first
# This improves Docker layer caching
# ------------------------------------------------------------
COPY requirements.txt .

# ------------------------------------------------------------
# Install application dependencies
# ------------------------------------------------------------
RUN python -m pip install --no-cache-dir -r requirements.txt

# ------------------------------------------------------------
# Re-apply security package versions.
#
# This protects against a dependency in requirements.txt
# pulling an older vulnerable version.
# ------------------------------------------------------------
RUN python -m pip install --no-cache-dir --upgrade \
    "setuptools>=78.1.1" \
    "msgpack>=1.2.1"

# ------------------------------------------------------------
# Copy application source code
# ------------------------------------------------------------
COPY . .

# ------------------------------------------------------------
# Create non-root application user
# Security best practice for ECS/container workloads
# ------------------------------------------------------------
RUN useradd --create-home --shell /usr/sbin/nologin appuser \
    && chown -R appuser:appuser /app

USER appuser

# ------------------------------------------------------------
# Application port
# ------------------------------------------------------------
EXPOSE 5000

# ------------------------------------------------------------
# Container health check
# Change /health if your Flask health endpoint is different
# ------------------------------------------------------------
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# ------------------------------------------------------------
# Start Flask application using Gunicorn
#
# Assumption:
# app.py contains:
# app = Flask(__name__)
# ------------------------------------------------------------
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--threads", "2", "--timeout", "60", "app:app"]