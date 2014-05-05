#!/bin/bash

set -e

PROJECT_ROOT="/srv/dogmazic"
BRANCH='dg-next'
USER=mediagoblin

sudo apt-get install -y git python python-dev \
    python-setuptools libxml2-dev libxslt-dev zlib1g-dev \
    postgresql postgresql-client python-psycopg2 \
    python-gst0.10 gstreamer0.10-plugins-base \
    gstreamer0.10-plugins-bad gstreamer0.10-plugins-good \
    gstreamer0.10-plugins-ugly gstreamer0.10-ffmpeg \
    libsndfile1-dev libasound2-dev libblas-dev liblapack-dev \
    build-essential python-all gfortran

sudo apt-get install -y python-numpy

sudo easy_install pip
sudo pip install virtualenv -U

sudo adduser  --system --group --shell /bin/bash $USER

sudo mkdir -p $PROJECT_ROOT
sudo chown mediagoblin:mediagoblin $PROJECT_ROOT
cd $PROJECT_ROOT
sudo -u $USER git clone https://github.com/MusiqueLibre/DogmaGoblin.git
sudo chown -hR mediagoblin:mediagoblin DogmaGoblin

cd $PROJECT_ROOT/DogmaGoblin
sudo -u $USER git checkout $BRANCH

sudo -u postgres createuser -R -S -D $USER
sudo -u postgres createdb -E UNICODE -O mediagoblin mediagoblin

if [ ! -f mediagoblin_local.ini ]; then
    sudo -u $USER cp mediagoblin.ini mediagoblin_local.ini
fi

sudo -u $USER virtualenv --system-site-packages .
sudo -u $USER ./bin/pip install setuptools -U
sudo -u $USER ./bin/pip install scipy -U
sudo -u $USER ./bin/python setup.py develop
