# Manage accounts with docker
#node['gitlab']['gitlab-ci']['user'] = 'git'

manage_accounts['enable'] = false
manage_storage_directories['enable'] = false
postgresql['enable'] = false
redis['enable'] = false

nginx['listen_port'] = 8080

gitlab_shell['auth_file'] = '/gitlab-data/ssh/authorized_keys'
git_data_dirs({ 'default' => { 'path' => '/gitlab-data/git-data' } }) 
gitlab_rails['shared_path'] = '/gitlab-data/shared'
gitlab_rails['uploads_directory'] = '/gitlab-data/uploads'
gitlab_rails['auto_migrate'] = false
gitlab_ci['builds_directory'] = '/gitlab-data/builds'

# GitLab
user['username'] = 'git'
user['group'] = 'root'
user['gid'] = 0
#user['home'] = "/var/opt/gitlab"

# Web server
web_server['username'] = 'git'
web_server['gid'] = 0
web_server['listen_port'] = 8080

gitlab_rails['gitlab_shell_ssh_port'] = 2222
gitlab_rails['port'] = 8080

## Prevent Postgres from trying to allocate 25% of total memory
postgresql['shared_buffers'] = '1MB'

unicorn['port'] = 8080
unicorn['username'] = 'git'
unicorn['gid'] = 0

# Get hostname from shell
#host = `hostname`.strip
#external_url "http://#{host}"

# Load custom config from environment variable: GITLAB_OMNIBUS_CONFIG
# Disabling the cop since rubocop considers using eval to be security risk but
# we don't have an easy way out, atleast yet.
eval ENV["GITLAB_OMNIBUS_CONFIG"].to_s # rubocop:disable Security/Eval

# Load configuration stored in /etc/gitlab/gitlab.rb
from_file("/etc/gitlab/gitlab.rb")
