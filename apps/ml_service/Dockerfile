# Use Python 3.10 slim for smaller image size
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install system dependencies for pandas/sklearn if needed
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PORT=5001

# Expose the port (Render will override this, but 10000 is default)
EXPOSE 10000

# Command to run the application with Gunicorn
# NUCLEAR FIX: No --preload, 1 worker, 4 threads to minimize RAM and start-up peak
CMD gunicorn --bind 0.0.0.0:$PORT --workers 1 --threads 4 --worker-tmp-dir /dev/shm --timeout 120 app:app
