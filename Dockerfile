FROM centos:centos7

#SHELL ["/bin/sh", "-c"],

ENV NAME=gitlab-ce \
    GITLAB_VERSION=10.60 \
    GITLAB_SHORT_VER=106 \
    VERSION=0

ENV APP_HOME=/var/opt/gitlab
ENV HOME=${APP_HOME}
ENV PATH=/opt/gitlab/embedded/bin:/opt/gitlab/bin:/assets:${APP_HOME}/bin:$PATH

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

RUN sed 's/session\s*required\s*pam_loginuid.so/session optional pam_loginuid.so/g' -i /etc/pam.d/sshd

# Remove MOTD
RUN rm -rf /etc/update-motd.d /etc/motd /etc/motd.dynamic
RUN ln -fs /dev/null /run/motd.dynamic

RUN mkdir -p ${APP_HOME} && \
    mkdir -p ${APP_HOME}/bin

# Copy assets
COPY bin/ ${APP_HOME}/bin
COPY assets/ /assets/

#RUN rm -rf /opt/gitlab/embedded/bin/runsvdir-start && \
#    cp ${APP_HOME}/bin/runsvdir-start /opt/gitlab/embedded/bin/ && \
#    chmod a+x /opt/gitlab/embedded/bin/runsvdir-start

RUN /assets/setup
# Resolve error: TERM environment variable not set.
ENV TERM xterm

RUN chmod -R a+rwx ${APP_HOME} && \
    chown -R 1001:0 ${APP_HOME} && \
    chmod -R a+rwx /opt/gitlab && \
    chown -R 1001:0 /opt/gitlab && \
    chmod -R a+rwx /etc/gitlab && \
    chown -R 1001:0 /etc/gitlab && \
    chmod -R a+rwx /var/log/gitlab && \
    chown -R 1001:0 /var/log/gitlab && \
    chmod -R g=u /etc/passwd

# Expose web & ssh
EXPOSE 8443 8080 2222

# Define data volumes
VOLUME ["/etc/gitlab", "/var/opt/gitlab", "/var/log/gitlab"]

#USER 1001

#WORKDIR ${APP_HOME}

ENTRYPOINT [ "uid_entrypoint" ]

# Wrapper to handle signal, trigger runit and reconfigure GitLab
CMD ["/assets/wrapper"]

HEALTHCHECK --interval=60s --timeout=30s --retries=5 \
CMD /opt/gitlab/bin/gitlab-healthcheck --fail
