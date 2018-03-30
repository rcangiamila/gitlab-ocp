FROM centos:centos7

#SHELL ["/bin/sh", "-c"],

ENV NAME=gitlab-ce \
    GITLAB_VERSION=10.60 \
    GITLAB_SHORT_VER=106 \
    VERSION=0 \
    PACKAGECLOUD_REPO=gitlab-ce \
    RELEASE_PACKAGE=gitlab-ce \
    RELEASE_VERSION=10.61-ce

ENV APP_HOME=/opt/gitlab
ENV HOME=/var/opt/gitlab
#ENV HOME=${APP_HOME}

# Resolve error: TERM environment variable not set.
ENV TERM xterm

# Install required packages
ENV INSTALL_PACKAGES="ca-certificates openssh-server wget vim tzdata nano varnish gettext nss_wrapper curl sed"
ENV GITLAB_REPOSIROTY_SCRIPT_URL="https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh"

RUN yum install -y epel-release

RUN INSTALL_PACKAGES="ca-certificates openssh-server wget tzdata nano varnish gettext nss_wrapper curl sed" && \ 
    yum install -y --setopt=tsflags=nodocs $INSTALL_PACKAGES && \
    rpm -V $INSTALL_PACKAGES && \
    curl ${GITLAB_REPOSIROTY_SCRIPT_URL} | bash && \
    yum install -y gitlab-ce && \
    yum clean all

RUN mkdir -p ${APP_HOME} && \
    mkdir -p /etc/gitlab && \
    mkdir -p /var/opt/gitlab && \
    mkdir -p /var/log/gitlab && \
    mkdir -p /var/opt/gitlab/git-data && \
    mkdir -p /var/opt/gitlab/git-data/repositories && \
    mkdir -p /var/opt/gitlab/gitlab-rails/shared && \
    mkdir -p /var/opt/gitlab/gitlab-rails/shared/artifacts && \
    mkdir -p /var/opt/gitlab/gitlab-rails/shared/lfs-objects && \
    mkdir -p /var/opt/gitlab/gitlab-rails/uploads && \
    mkdir -p /var/opt/gitlab/gitlab-rails/shared/pages && \
    mkdir -p /var/opt/gitlab/gitlab-ci/builds && \
    mkdir -p /var/opt/gitlab/.ssh

RUN sed 's/session\s*required\s*pam_loginuid.so/session optional pam_loginuid.so/g' -i /etc/pam.d/sshd

# Remove MOTD
RUN rm -rf /etc/update-motd.d /etc/motd /etc/motd.dynamic
RUN ln -fs /dev/null /run/motd.dynamic

COPY RELEASE /

# Copy assets
COPY assets/ /assets/

RUN rm -rf ${APP_HOME}/embedded/bin/runsvdir-start && \
    cp /assets/runsvdir-start ${APP_HOME}/embedded/bin/ && \
    chmod a+x ${APP_HOME}/embedded/bin/runsvdir-start

RUN /assets/setup

ENV PATH=${APP_HOME}/embedded/bin:${APP_HOME}/bin:/assets:$PATH
# Resolve error: TERM environment variable not set.
ENV TERM xterm

####TEST
RUN cp /assets/gitlab.rb /etc/gitlab/gitlab.rb

RUN cp /assets/default.rb /opt/gitlab/embedded/cookbooks/gitlab/recipes/

RUN chmod -R a+rwx ${APP_HOME} && \
    chown -R 1001:0 ${APP_HOME} && \
    chmod -R a+rwx /var/opt/gitlab && \
    chown -R 1001:0 /var/opt/gitlab && \
    chmod -R a+rwx /etc/gitlab && \
    chown -R 1001:0 /etc/gitlab && \
    chmod -R a+rwx /var/log/gitlab && \
    chown -R 1001:0 /var/log/gitlab && \
    chmod -R g=u /etc/passwd && \
    chmod -R g=u /etc/security/limits.conf && \
    chmod -R a+rwx /assets && \
    chown -R 1001:0 /assets

# Expose web & ssh
EXPOSE 8443 8080 2222

# Define data volumes
VOLUME ["/etc/gitlab", "/var/opt/gitlab", "/var/log/gitlab"]

USER 1001

WORKDIR ${APP_HOME}

ENTRYPOINT [ "uid_entrypoint" ]

# Wrapper to handle signal, trigger runit and reconfigure GitLab
CMD ["/assets/wrapper"]

HEALTHCHECK --interval=60s --timeout=30s --retries=5 \
CMD /opt/gitlab/bin/gitlab-healthcheck --fail
