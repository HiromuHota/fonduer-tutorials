FROM jupyter/minimal-notebook
LABEL maintainer="Hiromu Hota <hiromu.hota@hal.hitachi.com>"
USER root

RUN apt-get update && apt-get install -yq \
    libxml2-dev \
    libxslt-dev \
    python-matplotlib \
    poppler-utils

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

RUN python -m spacy download en
RUN apt-get install postgresql-client -y

USER $NB_UID

COPY hardware hardware
COPY hardware_image hardware_image
COPY intro intro
