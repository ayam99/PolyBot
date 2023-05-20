# Use the official Nginx base image
FROM nginx:latest

# Copy the static files to the Nginx document root
COPY ./static-html /usr/share/nginx/html

# Expose port 80 for Nginx
EXPOSE 80

# Start Nginx when the container launches
CMD ["nginx", "-g", "daemon off;"]
