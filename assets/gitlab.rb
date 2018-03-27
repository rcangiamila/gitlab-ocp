# Manage accounts with docker
manage_accounts['enable'] = false

# GitLab
user['username'] = "gitlab"
user['home'] = "/opt/gitlab"
user['uid'] = 1001
user['gid'] = 0

# Postgresql (not needed when using external Postgresql)
postgresql['uid'] = 1001
postgresql['gid'] = 0
postgresql['home'] = "/opt/gitlab"

# Redis (not needed when using external Redis)
redis['uid'] = 1001
redis['gid'] = 0
redis['home'] = "/var/opt/redis-gitlab"

# Web server
web_server['uid'] = 1001
web_server['gid'] = 0
web_server['home'] = '/var/opt/gitlab/webserver'

## Prevent Postgres from trying to allocate 25% of total memory
postgresql['shared_buffers'] = '1MB'

# Get hostname from shell
host = `hostname`.strip
external_url "http://#{host}"

# Load custom config from environment variable: GITLAB_OMNIBUS_CONFIG
# Disabling the cop since rubocop considers using eval to be security risk but
# we don't have an easy way out, atleast yet.
eval ENV["GITLAB_OMNIBUS_CONFIG"].to_s # rubocop:disable Security/Eval

# Load configuration stored in /etc/gitlab/gitlab.rb
#from_file("/opt/gitlab/etc/gitlab/gitlab.rb")
