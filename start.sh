#!/bin/bash

pg_ctlcluster 12 main start
jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --allow-root \
  --NotebookApp.token='' \
  --NotebookApp.password='' \
  --NotebookApp.allow_origin='*' \
  --NotebookApp.base_url=${NB_PREFIX}
