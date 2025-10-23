# Gunakan base image Python
FROM python:3.10.3-slim-bullseye

# Install dependencies sistem
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    gfortran \
    git \
    wget \
    curl \
    graphicsmagick \
    libgraphicsmagick1-dev \
    libatlas-base-dev \
    libavcodec-dev \
    libavformat-dev \
    libgtk2.0-dev \
    libjpeg-dev \
    liblapack-dev \
    libswscale-dev \
    pkg-config \
    python3-dev \
    python3-numpy \
    software-properties-common \
    zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install dlib library
RUN mkdir -p /opt/dlib && \
    git clone -b 'v19.9' --single-branch https://github.com/davisking/dlib.git /opt/dlib && \
    cd /opt/dlib && \
    python3 setup.py install --yes USE_AVX_INSTRUCTIONS

# Salin source code aplikasi ke direktori yang bisa diakses non-root
COPY . /opt/face_recognition

# Install Python requirements dan setup aplikasi
RUN cd /opt/face_recognition && \
    pip3 install --no-cache-dir -r requirements.txt && \
    python3 setup.py install

# Set working directory untuk container
WORKDIR /opt/face_recognition/examples

# Jalankan aplikasi secara default
CMD ["python3", "recognize_faces_in_pictures.py"]
