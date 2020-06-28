FROM python:alpine3.7
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
ENTRYPOINT [ "python" ]
CMD [ "app.py" ]
HEALTHCHECK   CMD curl --fail http://127.0.0.1:5000/ || exit 1

EXPOSE 5000
