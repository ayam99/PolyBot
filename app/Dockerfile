python:3.8-slim-buster
 
# Creating Application Source Code Directory
RUN mkdir -p /k8s_python_demo_code/src

# Setting Home Directory for containers
WORKDIR /k8s_python_demo_code/src

# Installing python dependencies
COPY requirements.txt /k8s_python_demo_code/src
RUN pip install — no-cache-dir -r requirements.txt

# Copying src code to Container
COPY . /k8s_python_demo_code/src/app

# Application Environment variables
ENV APP_ENV development

# Exposing Ports
EXPOSE 4025

# Setting Persistent data
VOLUME [“/app-data”]

# Running Python Application
CMD [“python”, “app.py”]
