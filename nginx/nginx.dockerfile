FROM ubuntu:latest

RUN apt-get update && apt-get install -y nginx

#copy /nginx.html /usr/share/nginx/html/index.html

#RUN rm /var/www/html/index.nginx-debian.html

COPY /index.html /var/www/html

CMD ["nginx", "-g", "daemon off;"]
