FROM ubuntu:18.04

RUN  sed -i s/archive.ubuntu.com/mirrors.163.com/g /etc/apt/sources.list
RUN  sed -i s/security.ubuntu.com/mirrors.163.com/g /etc/apt/sources.list
RUN apt-get update && apt-get install -y python3-pip  git  libssl-dev  python3 


# RUN apt-get install software-properties-common apt-utils
# RUN add-apt-repository -y  ppa:deadsnakes/ppa && apt-get update && apt-get install -y python3.6 
# RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.6 10
# RUN python --version


COPY ./requirements.txt requirements.txt
RUN python3 -m pip install requests  -i https://mirrors.aliyun.com/pypi/simple/ 
RUN python3 -m pip install --upgrade setuptools==44.1.1 -i https://mirrors.aliyun.com/pypi/simple/ 
RUN python3 -m pip install --no-cache-dir  -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/ 
RUN git clone https://github.com/chenfengjin/sphinx-versions.git 
RUN cd sphinx-versions && python3 setup.py install 

COPY bin/server.py /opt/sphinx-server/
COPY ./.sphinx-server.yml /opt/sphinx-server/

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

WORKDIR /web

EXPOSE 8000 35729

CMD ["sphinx-autobuild", ".", "_build/html","--host","0.0.0.0"]