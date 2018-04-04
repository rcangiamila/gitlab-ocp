FROM centos:centos7

#SHELL ["/bin/sh", "-c"],

ENV NAME=gitlab-ce \
    GITLAB_VERSION=10.62 \
    GITLAB_SHORT_VER=106 \
    VERSION=2 \
    PACKAGECLOUD_REPO=gitlab-ce \
    RELEASE_PACKAGE=gitlab-ce \
    RELEASE_VERSION=10.62-ce

ENV APP_HOME=/opt/gitlab
ENV HOME=/var/opt/gitlab

ENV TERM xterm

# Install required packages
RUN yum install -y epel-release

RUN INSTALL_PACKAGES="deltarpm ca-certificates openssh-server wget vim-enhanced tzdata nano varnish gettext nss_wrapper curl sed which" && \ 
    yum install -y --setopt=tsflags=nodocs $INSTALL_PACKAGES && \
    rpm -V $INSTALL_PACKAGES && \
    GITLAB_REPOSIROTY_SCRIPT_URL="https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh" && \
    curl ${GITLAB_REPOSIROTY_SCRIPT_URL} | bash && \
    yum install -y gitlab-ce && \
    yum clean all && \
    rm -rf /var/cache/yum

RUN mkdir -p ${APP_HOME} && \
    mkdir -p ${APP_HOME}/LICENSES && \ 
    mkdir -p ${APP_HOME}/bin && \
    mkdir -p ${APP_HOME}/embedded && \  
    mkdir -p ${APP_HOME}/embedded/etc && \
    mkdir -p ${APP_HOME}/etc && \
    mkdir -p ${APP_HOME}/init && \  
    mkdir -p ${APP_HOME}/service && \  
    mkdir -p ${APP_HOME}/sv && \  
    mkdir -p ${APP_HOME}/sv/gitlab-workhorse && \ 
    mkdir -p ${APP_HOME}/sv/logrotate && \ 
    mkdir -p ${APP_HOME}/sv/nginx && \ 
    mkdir -p ${APP_HOME}/sv/postgresql && \  
    mkdir -p ${APP_HOME}/sv/redis && \  
    mkdir -p ${APP_HOME}/sv/sidekiq && \ 
    mkdir -p ${APP_HOME}/sv/sshd && \ 
    mkdir -p ${APP_HOME}/sv/unicorn && \
    mkdir -p ${APP_HOME}/var && \
    mkdir -p /etc/gitlab && \
    mkdir -p /var/opt/gitlab && \
    mkdir -p /var/log/gitlab && \
    mkdir -p /var/log/gitlab/sshd && \
    mkdir -p /var/log/gitlab/reconfigure && \
    mkdir -p /var/log/gitlab/gitlab-workhorse && \
    mkdir -p /var/log/gitlab/gitlab-rails && \
    mkdir -p /var/log/gitlab/gitlab-shell && \ 
    mkdir -p /var/log/gitlab/gitlab-workhorse && \ 
    mkdir -p /var/log/gitlab/logrotate && \ 
    mkdir -p /var/log/gitlab/nginx && \ 
    mkdir -p /var/log/gitlab/postgresql && \ 
    mkdir -p /var/log/gitlab/reconfigure && \  
    mkdir -p /var/log/gitlab/redis && \ 
    mkdir -p /var/log/gitlab/sidekiq && \ 
    mkdir -p /var/log/gitlab/sshd && \ 
    mkdir -p /var/log/gitlab/unicorn && \
    mkdir -p /var/opt/gitlab/git-data && \
    mkdir -p /var/opt/gitlab/git-data/repositories && \
    mkdir -p /var/opt/gitlab/gitlab-rails/etc && \
    mkdir -p /var/opt/gitlab/gitlab-rails/shared && \
    mkdir -p /var/opt/gitlab/gitlab-rails/shared/artifacts && \
    mkdir -p /var/opt/gitlab/gitlab-rails/shared/lfs-objects && \
    mkdir -p /var/opt/gitlab/gitlab-rails/shared/pages && \
    mkdir -p /var/opt/gitlab/gitlab-rails/uploads && \
    mkdir -p /var/opt/gitlab/gitlab-rails/working && \
    mkdir -p /var/opt/gitlab/gitlab-ci/builds && \
    mkdir -p /var/opt/gitlab/gitlab-workhorse && \
    mkdir -p /var/opt/gitlab/gitlab-shell && \
    mkdir -p /var/opt/gitlab/backups && \
    mkdir -p /var/opt/gitlab/logrotate && \
    mkdir -p /var/opt/gitlab/nginx && \
    mkdir -p /var/opt/gitlab/.ssh && \
    mkdir -p /var/opt/gitlab/redis && \
    mkdir -p /var/opt/gitlab/postgresql

RUN sed 's/session\s*required\s*pam_loginuid.so/session optional pam_loginuid.so/g' -i /etc/pam.d/sshd

# Remove MOTD
RUN rm -rf /etc/update-motd.d /etc/motd /etc/motd.dynamic
RUN ln -fs /dev/null /run/motd.dynamic

COPY RELEASE /

# Copy assets
COPY assets/ /assets/
RUN /assets/setup

ENV PATH=${APP_HOME}/embedded/bin:${APP_HOME}/bin:/assets:$PATH


# Expose web & ssh
EXPOSE 8443 8080 2222

RUN rm -rf ${APP_HOME}/embedded/bin/runsvdir-start && \
    cp /assets/runsvdir-start ${APP_HOME}/embedded/bin/ && \
    chmod a+x ${APP_HOME}/embedded/bin/runsvdir-start

RUN sed -i 's/mode 0755/mode 0777/g' /opt/gitlab/embedded/cookbooks/gitlab/recipes/default.rb && \
    sed -i 's/mode "0755"/mode "0777"/g' /opt/gitlab/embedded/cookbooks/gitlab/recipes/default.rb && \
    sed -i 's/mode "0775"/mode "0777"/g' /opt/gitlab/embedded/cookbooks/gitlab/recipes/default.rb && \
    sed -i 's/owner "root"/owner "git"/g' /opt/gitlab/embedded/cookbooks/gitlab/recipes/default.rb

#RUN rm -f /opt/gitlab/embedded/cookbooks/gitlab/recipes/default.rb && \
#    cp /assets/default.rb /opt/gitlab/embedded/cookbooks/gitlab/recipes/

RUN chmod -R a+rwx /opt && \
    chown -R 1001:0 /opt && \
    chmod -R a+rwx /var && \
    chown -R 1001:0 /var && \ 
    chmod -R a+rwx ${APP_HOME} && \
    chown -R 1001:0 ${APP_HOME} && \
    chmod -R a+rwx /var/opt/gitlab && \
    chown -R 1001:0 /var/opt/gitlab && \
    chmod -R a+rwx /etc/gitlab && \
    chown -R 1001:0 /etc/gitlab && \
    chmod -R a+rwx /var/log/gitlab && \
    chown -R 1001:0 /var/log/gitlab && \
    chmod -R a+rwx ${HOME} && \
    chown -R 1001:0 ${HOME} && \
    chmod -R g=u /etc/passwd && \
    chmod -R g=u /etc/security/limits.conf && \
    chmod -R a+rwx /assets && \
    chown -R 1001:0 /assets

USER 1001

ENTRYPOINT [ "/assets/uid_entrypoint" ]

# Define data volumes
VOLUME ["/etc/gitlab", "/var/opt/gitlab", "/var/log/gitlab", "/var/log/gitlab/reconfigure"]

# Wrapper to handle signal, trigger runit and reconfigure GitLab
CMD ["/assets/wrapper"]

HEALTHCHECK --interval=60s --timeout=30s --retries=5 \
CMD /opt/gitlab/bin/gitlab-healthcheck --fail
