
FROM nginx:alpine

RUN apk update && \
    apk upgrade --no-cache
COPY index.html products.html payment.html /usr/share/nginx/html/
COPY style.css products.css payment.css /usr/share/nginx/html/
COPY script.js payment.js logo.png /usr/share/nginx/html/

EXPOSE 80

