FROM hiromuhota/fonduer
LABEL maintainer="Hiromu Hota <hiromu.hota@hal.hitachi.com>"

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    ghostscript \
    curl \
    # gnupg2 is required by apt-key
    gnupg2 \
 # Install postgres
 && echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
 && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && apt-get update && apt-get install -y --no-install-recommends \
    postgresql-12 \
    postgresql-client-12 \
 && rm -rf /var/lib/apt/lists/*

# https://jupyter-notebook.readthedocs.io/en/stable/public_server.html#docker-cmd
# Add Tini. Tini operates as a process subreaper for jupyter. This prevents
# kernel crashes.
ENV TINI_VERSION v0.6.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

EXPOSE 8888
CMD pg_ctlcluster 12 main start; \
  jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --allow-root

USER postgres
RUN sed -i '/^host    all             all             127.0.0.1\/32            md5/ s/md5/trust/' /etc/postgresql/12/main/pg_hba.conf
# Create a role
RUN /etc/init.d/postgresql start \
 && psql -c "CREATE USER root WITH SUPERUSER;"

USER user
RUN pip install --upgrade pip \
 && pip install \
    matplotlib \
    ipywidgets \
    jupyter \
 && python -m spacy download en

# Copy notebooks and download data
COPY --chown=user:user hardware hardware
RUN cd hardware && /bin/bash download_data.sh
COPY --chown=user:user hardware_image hardware_image
RUN cd hardware_image && /bin/bash download_data.sh
COPY --chown=user:user intro intro
RUN cd intro && /bin/bash download_data.sh
COPY --chown=user:user wiki wiki
RUN cd wiki && /bin/bash download_data.sh

# Should be the cluster owner (postgres) or root to start postgres server
USER root
