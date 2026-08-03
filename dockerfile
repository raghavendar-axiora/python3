FROM:python:3.9-slim
COPY requirements.txt .
RUN pip install -r requirements.txt
WRKDIR /app
COPY  /app .
EXPOSE 5000
CMD ["python", "app.py"]


