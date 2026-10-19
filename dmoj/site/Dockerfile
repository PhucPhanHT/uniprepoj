FROM ndoj/ndoj-base

ARG PANDOC_VERSION=3.1.13
RUN ARCH=$([ $(uname -m) = "x86_64" ] && echo "amd64" || echo "arm64") && \
    curl -fsSL -o pandoc.deb "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-${ARCH}.deb" && \
    dpkg -i pandoc.deb && \
    rm -f pandoc.deb

EXPOSE 8000

ENTRYPOINT uwsgi --ini uwsgi.ini
