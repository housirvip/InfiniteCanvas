FROM python:3.10-slim

# 替换 apt 源为阿里云镜像
RUN sed -i 's|deb.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources && \
    sed -i 's|security.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources

# 安装系统依赖：ffmpeg 用于视频预览截帧
RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 先复制依赖文件，利用 Docker 层缓存
COPY requirements.txt .
RUN pip install --no-cache-dir -i https://mirrors.aliyun.com/pypi/simple/ \
    --trusted-host mirrors.aliyun.com \
    -r requirements.txt

# 复制应用代码
COPY main.py VERSION ./
COPY static/ static/
COPY workflows/ workflows/
COPY API/ API/
COPY CLI/ CLI/

# 创建运行时数据目录
RUN mkdir -p data output assets/input assets/output assets/library assets/uploads

EXPOSE 3000

CMD ["python", "main.py"]
