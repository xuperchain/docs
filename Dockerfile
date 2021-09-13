FROM ubuntu:18.04
WORKDIR /root

RUN apt-get update && apt-get install -y python3-pip  git  libssl-dev  python3 


#  seperate clone and install to reduce networking problems by docker build cache 
RUN git clone https://github.com/chenfengjin/sphinx-versions.git 

COPY . .
COPY ./requirements.txt requirements.txt
RUN python3 -m pip install requests
RUN python3 -m pip install --upgrade setuptools==44.1.1
RUN python3 -m pip install --no-cache-dir  -r requirements.txt
RUN cd sphinx-versions && python3 setup.py install 

COPY ./.sphinx-server.yml /opt/sphinx-server/

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

WORKDIR /web

EXPOSE 8000 35729

CMD ["sphinx-autobuild", ".", "_build/html","--host","0.0.0.0", "--watch" ,"_static/*"]
