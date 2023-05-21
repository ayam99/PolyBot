FROM python:3.8-slim-buster
 
# Creating Application Source Code Directory
RUN mkdir -p /PolyBot/src

# Setting Home Directory for containers
WORKDIR /PolyBot/src

# Installing python dependencies
COPY requirements.txt /PolyBot/src
RUN pip install — no-cache-dir -r requirements.txt

# Copying src code to Container
COPY . /PolyBot/src/app

# Application Environment variables
ENV APP_ENV development

# Exposing Ports
EXPOSE 4025

# Setting Persistent data
VOLUME [“/app-data”]

# Running Python Application
CMD [“python”, “app.py”]
