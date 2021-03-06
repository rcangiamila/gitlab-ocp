 Manage accounts with docker

manage_accounts['enable'] = false
manage_storage_directories['enable'] = false
manage_storage_directories['manage_etc'] = false
postgresql['enable'] = false
redis['enable'] = false

#nginx['listen_port'] = 8080

#gitlab_rails['gitlab_default_can_create_group'] = false
#gitlab_rails['gitlab_username_changing_enabled'] = false

gitlab_shell['auth_file'] = '/gitlab-data/ssh/authorized_keys'
git_data_dirs({ 'default' => { 'path' => '/gitlab-data/git-data' } })
gitlab_rails['shared_path'] = '/gitlab-data/shared'
gitlab_rails['uploads_directory'] = '/gitlab-data/uploads'
#gitlab_rails['auto_migrate'] = false
gitlab_ci['builds_directory'] = '/gitlab-data/builds'

# GitLab
user['username'] = 'git'
#user['group'] = 'root'
user['uid'] = 1000070000
user['gid'] = 0
#user['home'] = "/var/opt/gitlab"

# Web server
web_server['username'] = 'git'
#web_server['group'] = 'root'
web_server['uid'] = 1000070000
web_server['gid'] = 0
#web_server['listen_port'] = 8080

gitlab_rails['gitlab_shell_ssh_port'] = 2222
#gitlab_rails['port'] = 8080

## Prevent Postgres from trying to allocate 25% of total memory
postgresql['shared_buffers'] = '1MB'

unicorn['port'] = 8080
unicorn['username'] = 'git'
#unicorn['group'] = 'root'
unicorn['uid'] = 1000070000
unicorn['gid'] = 0

# Get hostname from shell
host = `hostname`.strip
external_url "http://#{host}"

# Load custom config from environment variable: GITLAB_OMNIBUS_CONFIG
# Disabling the cop since rubocop considers using eval to be security risk but
# we don't have an easy way out, atleast yet.
eval ENV["GITLAB_OMNIBUS_CONFIG"].to_s # rubocop:disable Security/Eval

# Load configuration stored in /etc/gitlab/gitlab.rb
from_file("/etc/gitlab/gitlab.rb")

