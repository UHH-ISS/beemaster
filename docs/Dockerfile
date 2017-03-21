FROM alpine

RUN apk update
RUN apk add python3

WORKDIR /srv/docs

ADD _build/html /srv/docs/

EXPOSE 8000
CMD ["python3", "-m", "http.server", "8000"] 
