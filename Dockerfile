FROM python:3.10-slim

# ========== 第1层：系统依赖（极少变动）==========
RUN sed -i 's|deb.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources && \
    sed -i 's|security.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources

RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ========== 第2层：Python 依赖（偶尔变动）==========
COPY requirements.txt .
RUN pip install --no-cache-dir -i https://mirrors.aliyun.com/pypi/simple/ \
    --trusted-host mirrors.aliyun.com \
    -r requirements.txt

# ========== 第3层：后端配置目录和 CLI（偶尔变动）==========
RUN mkdir -p API && touch API/.env
COPY CLI/ CLI/

# ========== 第4层：前端静态资源（频繁变动）==========
COPY static/ static/

# ========== 第5层：主程序和版本（频繁变动）==========
COPY main.py VERSION ./

# ========== 第6层：运行时目录（每次构建都创建）==========
RUN mkdir -p data output assets/input assets/output assets/library assets/uploads

EXPOSE 3000

CMD ["sh", "-c", "mkdir -p API && if [ -d API/.env ]; then rmdir API/.env; fi && touch API/.env && exec python main.py"]
