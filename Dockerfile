FROM python:3.11-slim

COPY requirements.txt .
RUN pip install --upgrade --no-cache-dir -r requirements.txt

WORKDIR /app

COPY src .

EXPOSE 8080

CMD [ "python3", "-m", "flask", "--app=main", "run", "--host=0.0.0.0", "--port=8080" ]
