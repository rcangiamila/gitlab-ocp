# Manage accounts with docker
manage_accounts['enable'] = false

# GitLab
#user['username'] = "git"
user['uid'] = 1001
user['gid'] = 0

# Web server
web_server['uid'] = 1001
web_server['gid'] = 0

web_server['listen_port'] = 8080

nginx['listen_port'] = 8080

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
from_file("/etc/gitlab/gitlab.rb")

