#Grab the latest alpine image
FROM alpine:latest

# Install python and pip
ADD ./webapp/requirements.txt /requirements.txt
RUN apk add --no-cache --update python3 py3-pip bash

# Install dependencies
RUN pip3 install -r requirements.txt

# Add our code
ADD ./webapp /opt/webapp/
WORKDIR /opt/webapp

# Expose is NOT supported by Heroku
# EXPOSE 5000 		

# Run the image as a non-root user
RUN adduser -D myuser
USER myuser

# Run the app.  CMD is required to run on Heroku
# $PORT is set by Heroku			
CMD gunicorn --bind 0.0.0.0:$PORT wsgi 

