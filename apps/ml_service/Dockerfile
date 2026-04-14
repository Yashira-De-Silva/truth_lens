# Use Python 3.10 slim for smaller image size
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install system dependencies for pandas/sklearn if needed
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
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

# Expose the port
EXPOSE 5001

# Command to run the application
CMD ["python", "app.py"]
