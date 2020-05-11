#!/bin/bash

pg_ctlcluster 12 main start
jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --allow-root
