FROM python:alpine3.7
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
CMD cd /app && python app.py

EXPOSE 5000
