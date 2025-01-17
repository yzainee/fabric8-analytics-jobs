FROM registry.centos.org/centos/centos:7

ENV LANG=en_US.UTF-8 \
    PV_DIR='/pv' \
    MAVEN_INDEX_CHECKER_PATH='/opt/maven-index-checker' \
    MAVEN_INDEX_CHECKER_DATA_PATH='/pv/index-checker' \
    F8A_WORKER_VERSION=5c383a7 \
    F8A_UTILS_VERSION=33df0cc

RUN useradd coreapi

# https://copr.fedorainfracloud.org/coprs/fche/pcp/
COPY hack/_copr_fche_pcp.repo /etc/yum.repos.d/

RUN yum install -y epel-release && \
    yum install -y python36-devel python36-pip postgresql-devel gcc git maven zip unzip pcp && \
    yum clean all

# Install maven-index-checker
COPY hack/install_maven-index-checker.sh /tmp/install_deps/
RUN /tmp/install_deps/install_maven-index-checker.sh

# Create pcp dirs and make them accessible to all users. (see USER below)
RUN mkdir -p /etc/pcp /var/run/pcp /var/lib/pcp /var/log/pcp  && \
    chmod -R a+rwX /etc/pcp /var/run/pcp /var/lib/pcp /var/log/pcp

RUN pip3 install git+https://github.com/fabric8-analytics/fabric8-analytics-worker.git@${F8A_WORKER_VERSION} &&\
    mkdir ${PV_DIR} &&\
    chmod 777 ${PV_DIR}
RUN pip3 install git+https://github.com/fabric8-analytics/fabric8-analytics-utils.git@${F8A_UTILS_VERSION}

COPY ./ /tmp/jobs_install/
RUN cd /tmp/jobs_install &&\
    pip3 install --upgrade pip>=10.0.0 && pip3 install . &&\
    rm -rf /tmp/jobs_install

COPY hack/run_jobs.sh hack/jobs+pmcd.sh /usr/bin/

EXPOSE 44321

# Even this tells docker to run the container as coreapi:coreapi
# Openshift runs it as randomID:root anyway.
USER coreapi

CMD ["/usr/bin/jobs+pmcd.sh"]
