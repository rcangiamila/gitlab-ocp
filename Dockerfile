FROM centos:centos7

SHELL ["/bin/sh", "-c"],

ENV NAME=gitlab-ce \
    GITLAB_VERSION=10.60 \
    GITLAB_SHORT_VER=106 \
    VERSION=0

ENV APP_HOME=/opt/gitlab
ENV HOME=${APP_HOME}
ENV PATH=$PATH:${APP_HOME}/bin
# Allow to access embedded tools
ENV PATH ${APP_HOME}/embedded/bin:${APP_HOME}/bin:$PATH
# Resolve error: TERM environment variable not set.
ENV TERM xterm
# Expose web & ssh
EXPOSE 8443 8080 2222

# Install required packages
ENV INSTALL_PACKAGES="ca-certificates openssh-server wget vim tzdata nano varnish gettext nss_wrapper curl sed"
ENV GITLAB_REPOSIROTY_SCRIPT_URL="https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh"

RUN yum install -y epel-release

RUN yum install -y --setopt=tsflags=nodocs ${INSTALL_PACKAGES} && \
    rpm -V ${INSTALL_PACKAGES} && \
    yum clean all

RUN curl ${GITLAB_REPOSIROTY_SCRIPT_URL} | bash

RUN yum install -y gitlab-ce

# Remove MOTD
RUN rm -rf /etc/update-motd.d /etc/motd /etc/motd.dynamic
RUN ln -fs /dev/null /run/motd.dynamic

RUN mkdir -p ${APP_HOME} && \
    mkdir -p ${APP_HOME}/etc/gitlab && \
    mkdir -p ${APP_HOME}/var/opt/gitlab && \
    mkdir -p ${APP_HOME}/var/log/gitlab && \
    mkdir -p ${APP_HOME}/bin

# Copy assets
COPY RELEASE ${APP_HOME}/
COPY assets/ ${APP_HOME}/bin

RUN chmod -R a+rwx ${APP_HOME} && \
    chown -R 1001:0 ${APP_HOME} && \
    chmod -R g=u /etc/passwd && \
    chmod -R g=u /etc/pam.d/sshd

USER 1001

# Define data volumes
VOLUME ["/opt/gitlab"]

WORKDIR ${APP_HOME}

ENTRYPOINT [ "uid_entrypoint" ]

# Wrapper to handle signal, trigger runit and reconfigure GitLab
CMD wrapper

HEALTHCHECK --interval=60s --timeout=30s --retries=5 \
CMD gitlab-healthcheck --fail
