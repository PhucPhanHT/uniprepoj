FROM python:3.11-slim-bookworm

# Ngăn chặn prompt tương tác từ apt
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PORT=8000 \
    STATIC_ROOT=/assets/static/ \
    MEDIA_ROOT=/media/ \
    DMOJ_PROBLEM_DATA_ROOT=/problems/ \
    SECRET_KEY="ndoj-uniprep-oj-secret-key-thpt-nguyen-du-ha-tinh-c892bf34e56a7d8" \
    USE_PISTON_JUDGE=1 \
    PISTON_FALLBACK_LOCAL=1

# 1. Cài đặt các gói hệ thống, compilers và Pandoc
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git gcc g++ make curl gettext wget \
        libxml2-dev libxslt1-dev zlib1g-dev \
        mariadb-client libmariadb-dev libpq-dev \
        libjpeg-dev debconf-utils pkg-config ca-certificates && \
    curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    ARCH=$([ $(uname -m) = "x86_64" ] && echo "amd64" || echo "arm64") && \
    curl -fsSL -o pandoc.deb "https://github.com/jgm/pandoc/releases/download/3.1.13/pandoc-3.1.13-1-${ARCH}.deb" && \
    dpkg -i pandoc.deb && \
    rm -f pandoc.deb && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 2. Copy toàn bộ mã nguồn vào container
COPY . /app

# 3. Đảm bảo submodule VNOI-Admin/OJ tồn tại (tự clone nếu chưa có)
RUN if [ ! -f "dmoj/repo/package.json" ]; then \
        echo "Submodule dmoj/repo chua co, dang clone VNOI-Admin/OJ..." && \
        rm -rf dmoj/repo && \
        git clone --depth=1 https://github.com/VNOI-Admin/OJ.git dmoj/repo; \
    fi

# 4. Cài đặt Node.js packages
WORKDIR /app/dmoj/repo
RUN npm install

# 5. Cài đặt Python packages
WORKDIR /app
RUN cp -f dmoj/additional_requirements.txt dmoj/repo/additional_requirements.txt 2>/dev/null || true

WORKDIR /app/dmoj/repo
RUN pip3 install --no-cache-dir "setuptools<70" "wheel<0.44" && \
    pip3 install --no-cache-dir "Django>=3.2.25,<4.0" && \
    pip3 install --no-cache-dir -r requirements.txt && \
    pip3 install --no-cache-dir -r additional_requirements.txt && \
    pip3 install --no-cache-dir requests pyyaml whitenoise gunicorn psycopg2-binary dj-database-url lxml_html_clean "Django>=3.2.25,<4.0"

# 6. Sao chép các cấu hình, fixtures, Piston judge, migrations và bài tập mẫu
WORKDIR /app
RUN mkdir -p dmoj/repo/judge/fixtures dmoj/repo/judge/migrations dmoj/repo/resources /problems /media /assets/static /data && \
    cp -f dmoj/config/config.js dmoj/repo/websocket/config.js 2>/dev/null || true && \
    cp -f dmoj/config/local_settings.py dmoj/repo/dmoj/local_settings.py 2>/dev/null || true && \
    cp -f dmoj/config/local_urls.py dmoj/repo/dmoj/local_urls.py 2>/dev/null || true && \
    cp -f dmoj/config/uwsgi.ini dmoj/repo/uwsgi.ini 2>/dev/null || true && \
    cp -f dmoj/manage.py dmoj/repo/manage.py 2>/dev/null || true && \
    cp -f dmoj/wsgi.py dmoj/repo/dmoj/wsgi.py 2>/dev/null || true && \
    cp -f dmoj/judge/piston_judge.py dmoj/repo/judge/piston_judge.py 2>/dev/null || true && \
    cp -f dmoj/judge/judgeapi.py dmoj/repo/judge/judgeapi.py 2>/dev/null || true && \
    cp -f dmoj/judge/template_context.py dmoj/repo/judge/template_context.py 2>/dev/null || true && \
    cp -rf dmoj/migrations/* dmoj/repo/judge/migrations/ 2>/dev/null || true && \
    cp -rf dmoj/fixtures/* dmoj/repo/judge/fixtures/ 2>/dev/null || true && \
    cp -rf dmoj/resources/* dmoj/repo/resources/ 2>/dev/null || true && \
    cp -rf dmoj/sample_problems/* /problems/ 2>/dev/null || true && \
    cp -rf dmoj/problems/* /problems/ 2>/dev/null || true

# 7. Biên dịch i18n và thu thập static files
WORKDIR /app/dmoj/repo
RUN python3 manage.py compilejsi18n || true && \
    python3 manage.py collectstatic --noinput || true

WORKDIR /app
RUN chmod +x scripts/render_entrypoint.sh 2>/dev/null || true

EXPOSE 8000

ENTRYPOINT ["/bin/bash", "scripts/render_entrypoint.sh"]
