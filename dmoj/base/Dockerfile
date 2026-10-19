FROM python:3.11-slim-bookworm

RUN apt-get update && \
    apt-get install -y \
        git gcc g++ make curl gettext wget \
        libxml2-dev libxslt1-dev zlib1g-dev \
        mariadb-client libmariadb-dev \
        libjpeg-dev debconf-utils pkg-config && \
    curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /
COPY repo/package.json .
COPY repo/package-lock.json .
RUN npm install

COPY repo/requirements.txt .
RUN printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf 2>/dev/null || true; \
    pip3 install --no-cache-dir "setuptools<70" "wheel" && \
    pip3 install --no-cache-dir -r requirements.txt

COPY repo/additional_requirements.txt .
RUN printf "nameserver 8.8.8.8\nnameserver 1.1.1.1\n" > /etc/resolv.conf 2>/dev/null || true; \
    pip3 install --no-cache-dir -r additional_requirements.txt

ENV PATH="/node_modules/.bin:${PATH}"

