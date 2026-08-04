# --- Base image ---
FROM python:3.12-slim AS base

# Prevent Python from writing .pyc files and buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install dependencies first (better layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Run as a non-root user
RUN useradd --create-home --uid 1000 appuser
USER appuser

ENV PORT=5000
EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request,os; urllib.request.urlopen(f'http://127.0.0.1:{os.environ.get(\"PORT\",5000)}/health')" || exit 1

# Use gunicorn in production instead of Flask's dev server
CMD ["sh", "-c", "gunicorn --bind 0.0.0.0:${PORT} --workers 2 app:app"]
