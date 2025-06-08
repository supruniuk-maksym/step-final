FROM python:3.11-slim
WORKDIR /app
COPY app/main.py .
EXPOSE 5000
CMD ["python", "main.py"]
