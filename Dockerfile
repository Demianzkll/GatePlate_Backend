# ── Base image ──────────────────────────────────────────────
FROM python:3.12-slim


# ── System deps for OpenCV, YOLOv8, Tesseract, MySQL ──────
RUN apt-get update && apt-get install -y --no-install-recommends \
    # OpenCV runtimelibs
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    # Tesseract OCR (used by pytesseract)
    tesseract-ocr \
    tesseract-ocr-ukr \
    # MySQL client libs (for mysqlclient wheel)
    default-libmysqlclient-dev \
    build-essential \
    pkg-config \
 && rm -rf /var/lib/apt/lists/*

# ── Working directory ──────────────────────────────────────
WORKDIR /app

# ── Install Python deps (cached layer) ────────────────────
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ── Copy project code ─────────────────────────────────────
COPY . .

# ── Collect static files ──────────────────────────────────
RUN python manage.py collectstatic --noinput 2>/dev/null || true

# ── Expose (Railway ignores this, but good practice) ──────
EXPOSE 8000

# ── Run with dynamic $PORT from Railway ───────────────────
CMD gunicorn core.asgi:application -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:$PORT

