FROM pmallozzi/devenvs:base-gui-gymphysics-310

WORKDIR /root

RUN mkdir host ide

COPY . /root/host
WORKDIR /root/host

RUN pip3 install -r requirements.txt
RUN pip3 install -r requirements-extra.txt