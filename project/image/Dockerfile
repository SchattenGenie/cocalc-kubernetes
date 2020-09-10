FROM nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04
MAINTAINER Vladislav Belavin <belavin@phystech.edu>

# not sure if we need this for k8s version 
# USER root

# cuda
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib
ENV NUMBAPRO_NVVM=/usr/local/cuda/nvvm/lib64/libnvvm.so

# So we can source (http://goo.gl/oBPi5G), which we will do in build.sh.
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN chmod 1777 /tmp

# Useful code to get stuff done -- move up to the top when stable.
RUN \
     apt-get update \
     && DEBIAN_FRONTEND=noninteractive apt-get install -y  \
       gnupg2 \
       openssh-server \
       vim \
       apt-utils \
       wget \
       curl \
       software-properties-common \
       texlive \
       texlive-latex-extra \
       texlive-extra-utils \
       texlive-xetex \
       texlive-luatex \
       texlive-bibtex-extra \
       liblog-log4perl-perl \
       tmux \
       flex \
       bison \
       libreadline-dev \
       htop \
       screen \
       pandoc \
       aspell \
       poppler-utils \
       net-tools \
       python \
       python-pip \
       python3-pip \
       make \
       g++ \
       psmisc \
       haproxy \
       nginx \
       rsync \
       tidy \
       bup \
       inetutils-ping \
       lynx \
       telnet \
       emacs \
       subversion \
       ssh \
       m4 \
       latexmk \
       libpq5 \
       libpq-dev \
       build-essential \
       automake \
       gfortran \
       dpkg-dev \
       libssl-dev \
       imagemagick \
       libcairo2-dev \
       libcurl4-openssl-dev \
       graphviz \
       smem \
       octave \
       python3-yaml \
       python3-matplotlib \
       python3-jupyter* \
       python-matplotlib* \
       python-ipywidgets \
       python-ipywidgets-doc \
       python3-ipywidgets \
       jupyter \
       locales \
       locales-all \
       clang-format \
       golang \
       r-cran-formatr \
  && apt-get clean && apt-get -y autoremove

# Install prerequisites ubuntu packages for building the project nodejs server code.
RUN \
     apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y gnupg2 curl wget python3 python python-pip git make g++ dpkg-dev \
                        flex bison libreadline-dev libz-dev libssl-dev libpq5 libpq-dev vim telnet build-essential \
  && apt-get clean && apt-get -y autoremove

# cure prereqs 
RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-change-held-packages apt-utils curl \
    bzip2 gcc git wget g++ build-essential libc6-dev make pkg-config \
    libcudnn7 libnccl2 libnccl-dev libssl1.0.0 libssl-dev && \
    apt-get clean -y && rm -rf /var/lib/apt/lists/*
    
## Xpra backend support -- we have to use the debs from xpra.org,
## Since the official distro packages are ancient.
RUN \
     apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y xvfb websockify curl \
  && curl https://xpra.org/gpg.asc | apt-key add - \
  && echo "deb http://xpra.org/ bionic main" > /etc/apt/sources.list.d/xpra.list \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y xpra && apt-get clean && apt-get -y autoremove

## X11 apps to make x11 support useful.
## Will move this up in Dockerfile once stable.
RUN \
     apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y x11-apps dbus-x11 gnome-terminal \
     vim-gtk lyx libreoffice inkscape gimp chromium-browser texstudio evince mesa-utils \
     xdotool xclip x11-xkb-utils && apt-get clean && apt-get -y autoremove

# Jupyter widgets support
RUN pip install --no-cache-dir ipyleaflet
RUN pip3 install --no-cache-dir ipyleaflet

# scipy stuff
RUN pip3 install --no-cache-dir matplotlib bcolz paramiko \
    nose seaborn graphviz scikit-learn pip numpy scipy jupyter matplotlib \
    tqdm pandas tqdm psutil Cython mkl mkl-include numpy ninja pyyaml setuptools cmake cffi typing

# torch
RUN pip3 install --no-cache-dir pip torch torchvision

# tf
RUN pip3 install --no-cache-dir --upgrade tensorflow


# octave kernel
RUN pip install octave_kernel

# python code formatting
RUN pip install yapf

# Build and install Sage -- see https://github.com/sagemath/docker-images
# The sage build uses sudo to switch to sage user.
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y sudo
COPY scripts/ /tmp/scripts
RUN chmod -R +x /tmp/scripts

RUN    adduser --quiet --shell /bin/bash --gecos "Sage user,101,," --disabled-password sage \
    && chown -R sage:sage /home/sage/

# make source checkout target, then run the install script
# see https://github.com/docker/docker/issues/9547 for the sync
# Sage can't be built as root, for reasons...
# Here -E inherits the environment from root, however it's important to
# include -H to set HOME=/home/sage, otherwise DOT_SAGE will not be set
# correctly and the build will fail!
RUN    mkdir -p /usr/local/sage \
    && chown -R sage:sage /usr/local/sage \
    && sudo -H -E -u sage /tmp/scripts/install_sage.sh /usr/local/ master \
    && sync

RUN /tmp/scripts/post_install_sage.sh /usr/local/ && rm -rf /tmp/* && sync

# Install SageTex
RUN \
     sudo -H -E -u sage sage -p sagetex \
  && cp -rv /usr/local/sage/local/share/texmf/tex/latex/sagetex/ /usr/share/texmf/tex/latex/ \
  && texhash

# Install R Jupyter Kernel package into R itself (so R kernel works).
# I can't get this to work ?!
# RUN echo "install.packages(c('repr', 'IRdisplay', 'evaluate', 'crayon', 'pbdZMQ', 'httr', 'uuid', 'digest'), repos='http://cran.us.r-project.org'); devtools::install_github('IRkernel/IRkernel')" | sage -R --no-save
# RUN echo "install.packages(c('repr', 'IRdisplay', 'evaluate', 'crayon', 'pbdZMQ', 'httr', 'uuid', 'digest'), repos='http://cran.us.r-project.org'); devtools::install_github('IRkernel/IRkernel')" | R --no-save

# Get the source code of cocalc, putting it at /cocalc
RUN echo 19
RUN umask 022 && git clone https://github.com/SchattenGenie/cocalc.git

# tini: https://github.com/krallin/tini
# This is also included in Docker itself via the `--init` flag
COPY tini /cocalc/bin/tini
RUN chmod +x /cocalc/bin/tini

# We install our own Node 10, which is independent of the node setup of the host image
# (i.e. we can change the software stack at will without interfering with running the project)
RUN \
     umask 022 \
  && cd /cocalc \
  && mkdir /cocalc/nvm \
  && curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | NVM_DIR=/cocalc/nvm bash \
  && source /cocalc/nvm/nvm.sh \
  && nvm install --latest-npm --no-progress 10 \
  && npm install -g coffeescript

# Get our custom build script.
COPY kubernetes_build.py /cocalc/kubernetes_build.py

# Which branch to checkout and build.
ARG branch=master

# Run the build script once, so subsequent builds will be fast.
RUN umask 022 && source /cocalc/nvm/nvm.sh && /cocalc/kubernetes_build.py

# Delete some stupid big stuff from the /cocalc build; this won't be needed
# if we better refactor the smc-webapp code.  For now, we just do it.
RUN \
     cd /cocalc/src/smc-webapp/node_modules \
  && rm -rf three jquery-ui nyc react-draggable mathjax

# Create the project user's home account and home directory.
# TODO deal with .bashrc (/home/user is a volume)
COPY init /cocalc/init/

# This is our own all-in-one config file. Should be readable by the "user"
COPY kucalc-start-sshd.sh /cocalc/kucalc-start-sshd.sh

# Copy script over to start sage server.
COPY smc-sage-server /cocalc/bin/smc-sage-server

# Install support code for forking sage server
RUN umask 022 \
  && sage -pip install /cocalc/src/smc_sagews/

# The official Jupyter kernel with sage-9.0 (at least) is completely broken, due
# to calling the wrong script.  No clue what that's about. This works though:
COPY kernels/sagemath /usr/local/share/jupyter/kernels/sagemath

## Latest verison of JupyterLab and Jupyter Notebook classic
RUN umask 022 \
  && pip3 install jupyterlab jupyter

RUN umask 022 \
  && echo "install.packages('IRkernel'); IRkernel::installspec(user = FALSE)" | R --no-save

# Install the bash kernel
RUN umask 022 \
  && pip3 install bash_kernel \
  && python3 -m bash_kernel.install

# We do not use uid around 1000 since that's what the privileged
# accounts on the host are likely to use.
# ATTN some changes here (like, the user id number) should correspond to smc-build:smc-ansible/compute-k8s.yaml
RUN \
     umask 022 \
  && mkdir /home/user \
  && chown 2001:2001 -R /home/user \
  && /usr/sbin/groupadd --gid=2001 -o user \
  && /usr/sbin/useradd  --home-dir=/home/user --gid=2001 --uid=2001 --shell=/bin/bash user \
  && mkdir -p /var/run/sshd \
  && mkdir -p /usr/local/lib/python2.7/dist-packages/ \
  && echo "/cocalc/lib/python2.7/site-packages" > /usr/local/lib/python2.7/dist-packages/cocalc.pth \
  && chmod ugo=r /usr/local/lib/python2.7/dist-packages/cocalc.pth

RUN umask 022 \
  && echo "install.packages('rmarkdown');" | R --no-save

RUN umask 022 \
  && echo "install.packages('knitr');" | R --no-save

RUN pip3 install -U pip
RUN pip3 install -U matplotlib requests scipy tables requests tabulate && rm -rf ~/.cache/pip

# install xgboost
#RUN cd ~ && git clone --recursive https://github.com/dmlc/xgboost && cd xgboost && \
#    mkdir build && cd build && cmake .. -DUSE_CUDA=ON && make -j && \
#    cd ../python-package && python3 setup.py install --use-cuda --use-nccl

# install catboost
RUN pip3 install catboost xgboost lightgbm && rm -rf ~/.cache/pip

# install lightgbm not working
# RUN pip3 install lightgbm --install-option='--gpu' && rm -rf ~/.cache/pip
# RUN apt-get update && \
#    apt-get install -y git cmake opencl-headers build-essential libboost-dev libboost-system-dev libboost-filesystem-dev && \
#    mkdir -p /etc/OpenCL/vendors && echo "/usr/lib/x86_64-linux-gnu/libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd && \
#    git clone --recursive https://github.com/microsoft/LightGBM.git && \
#    cd LightGBM/python-package && \
#    python3 setup.py install --gpu --opencl-include-dir=/usr/local/cuda/include/ --opencl-library=/usr/local/cuda/lib64/libOpenCL.so && \
#    apt-get clean
    

# install catboost from source
#RUN apt-cache policy clang-6.0 && apt-get update && \
#    DEBIAN_FRONTEND=noninteractive apt-get install -y clang && \
#    git clone https://github.com/catboost/catboost.git && \
#    cd catboost/catboost/python-package/catboost && \
#    ../../../ya make -r -DUSE_ARCADIA_PYTHON=no -DUSE_SYSTEM_PYTHON=3.6 -DCUDA_ROOT=/usr/local/cuda -DCUDA_HOST_COMPILER=/usr/bin/clang-6.0 && \
#    apt-get clean

RUN pip3 install --use-feature=2020-resolver -U pyasn1 tensorboard mlxtend tensorflow transformers torchtext pynvml urllib3 comet_ml pyro-ppl numexpr pyfftw numba scikit-optimize gpytorch botorch 
RUN cd root && git clone https://github.com/ocelot-collab/ocelot.git && \
    cd ocelot && pip install -e . && cd .. && \
    git clone https://gitlab.com/lambda-hse/mlhep-2020-fel-competition.git fel && \
    cd fel && pip3 install -e . && cd .. && \
    pip3 install scikit-optimize gpytorch botorch && rm -rf ~/.cache/pip && \
    pip3 install git+https://github.com/yandexdataschool/mlhep2019.git && rm -rf ~/.cache/pip

RUN chmod 1777 /tmp
RUN apt-get update && apt-get install -y ffmpeg && apt-get clean

RUN echo 'user:$6$saltsalt$CJ//g7R/HZsF02WnJOpDQIE0a8UaHGu8tc1HD.F2TDLKbS3DoA/EmDMIBwBI6c.LZJYQedDChLPhOLrjOMzQ/0' | chpasswd -e && adduser user sudo
# Switch to being the non-privileged user.
# RUN umask 022 && NVM_DIR=/cocalc/nvm bash && source /cocalc/nvm/nvm.sh && npm install nodemon -g
# RUN sed -i '$ d' /cocalc/init/init.sh
# RUN echo "exec nodemon -V --legacy-watch /cocalc/src/smc-project/local_hub.js --tcp_port 6000 --raw_port 6001" >>   /cocalc/init/init.sh
USER user

WORKDIR /home/user

EXPOSE 2222 6000 6001

RUN touch /home/user/all_logs.log
RUN touch /home/user/logs_node.log

ENTRYPOINT ["/cocalc/bin/tini", "--"]
CMD ["sh", "-c", "env -i /cocalc/init/init.sh $COCALC_PROJECT_ID"]
