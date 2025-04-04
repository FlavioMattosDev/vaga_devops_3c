FROM ubuntu:latest

WORKDIR /app

RUN apt update && apt upgrade -y && \
    apt install -y wget unzip curl python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \ 
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
RUN apt-get update && apt-get -y install google-chrome-stable

RUN wget https://chromedriver.storage.googleapis.com/114.0.5735.90/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip

RUN pip3 install --break-system-packages --no-cache-dir selenium webdriver-manager

COPY selenium_script.py /app/