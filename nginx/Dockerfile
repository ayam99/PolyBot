# Use the official Nginx base image
FROM ubuntu:latest

RUN apt-get update
RUN apt-get install nginx -y

# Copy the static files to the Nginx document root
COPY index.html /var/www/html/

# Expose port 80 for Nginx
EXPOSE 80

# Start Nginx when the container launches
CMD ["nginx", "-g", "daemon off;"]
