FROM yoshi3/centos
MAINTAINER Yoshihide Shimada <y_shimada@pal-style.co.jp>

# initialize
RUN yum -y update

# supervisor
RUN yum install -y python-setuptools
RUN easy_install supervisor
COPY docker.d/supervisord.sh /etc/init.d/supervisord
RUN chmod 755 /etc/init.d/supervisord

# basics
RUN yum install -y --enablerepo=centosplus openssl-devel
RUN yum install -y which tar wget git

# install libyaml-devel
RUN wget http://ftp-srv2.kddilabs.jp/Linux/distributions/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN rpm -ivh epel-release-6-8.noarch.rpm
RUN yum --enablerepo=epel install -y libyaml-devel

# install ssh
RUN yum -y install openssh-server openssh-clients sudo
RUN sed -ri 's/^#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

# create ssh user ID:admin PW:admin
RUN useradd -d /home/admin -m -s /bin/bash admin
RUN echo admin:admin | chpasswd
RUN echo 'admin ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN sed -i -e 's/^\(Defaults    secure_path.*\)/#\1/' /etc/sudoers
RUN echo 'Defaults env_keep += "PATH"' >> /etc/sudoers
RUN /usr/bin/ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -C '' -N ''
RUN /usr/bin/ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -C '' -N ''

# install RVM with ruby 1.9.3
# if you want other version of ruby, replace `rvm install {version}`.
RUN \curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm list known"
RUN /bin/bash -l -c "rvm install 1.9.3"
RUN /bin/bash -l -c "rvm list"
RUN /bin/bash -l -c "gem install --no-ri --no-rdoc bundler"

# Init SSHD
EXPOSE 22

# copy Dockerfile into this image for just in case.
COPY Dockerfile /home/admin/Dockerfle

COPY docker.d/supervisord.conf /etc/supervisord.conf
CMD ["/usr/bin/supervisord"]