FROM python:3.10.3-slim-bullseye

RUN apt-get -y update && apt-get install -y --fix-missing \
    build-essential cmake gfortran git wget curl graphicsmagick \
    libgraphicsmagick1-dev libatlas-base-dev libavcodec-dev libavformat-dev \
    libgtk2.0-dev libjpeg-dev liblapack-dev libswscale-dev pkg-config \
    python3-dev python3-numpy software-properties-common zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
    git clone -b 'v19.9' --single-branch https://github.com/davisking/dlib.git && \
    cd dlib && python3 setup.py install --yes USE_AVX_INSTRUCTIONS

WORKDIR /app
COPY . /app

RUN pip3 install --no-cache-dir -r requirements.txt && \
    python3 setup.py install

EXPOSE 8000

CMD ["python3", "examples/web_service_example.py"]
