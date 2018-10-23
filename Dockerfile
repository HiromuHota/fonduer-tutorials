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
RUN conda install -y -c conda-forge ipywidgets

RUN apt-get install -y libmagickwand-dev
RUN apt-get install -y ghostscript
RUN rm /etc/ImageMagick-6/policy.xml

USER $NB_UID

COPY --chown=jovyan:users hardware hardware
COPY --chown=jovyan:users hardware_image hardware_image
COPY --chown=jovyan:users intro intro
