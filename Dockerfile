FROM ubuntu:16.04

RUN  sed -i s/archive.ubuntu.com/mirrors.163.com/g /etc/apt/sources.list
RUN  sed -i s/archive.ubuntu.com/mirrors.163.com/g /etc/apt/sources.list
RUN apt-get update && apt-get install -y python3-pip  git  libssl-dev
COPY ./requirements.txt requirements.txt
RUN pip3 install requests  -i https://mirrors.aliyun.com/pypi/simple/ 
RUN pip3 install --upgrade setuptools==44.1.1 -i https://mirrors.aliyun.com/pypi/simple/ 
RUN pip3 install --no-cache-dir  -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/ 
RUN pip3 freeze
RUN git clone https://github.com/chenfengjin/sphinx-versions.git && cd sphinx-versions && python3 setup.py install 

COPY bin/server.py /opt/sphinx-server/
COPY ./.sphinx-server.yml /opt/sphinx-server/

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
WORKDIR /web

EXPOSE 8000 35729

CMD ["python3", "/opt/sphinx-server/server.py"]
