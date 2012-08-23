BASEDIR = File.expand_path('../../../')

root = BASEDIR

# Sample verbose configuration file for Unicorn (not Rack)
#
# This configuration file documents many features of Unicorn
# that may not be needed for some applications. See
# http://unicorn.bogomips.org/examples/unicorn.conf.minimal.rb
# for a much simpler configuration file.
#
# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.

# Use at least one worker per core if you're on a dedicated server,
# more will usually help for _short_ waits on databases/caches.
worker_processes ENV.fetch('CHECK_UNICORN_WORKERS') { 1 }

# Since Unicorn is never exposed to outside clients, it does not need to
# run on the standard HTTP port (80), there is no reason to start Unicorn
# as root unless it's from system init scripts.
# If running the master process as root and the workers as an unprivileged
# user, do this to switch euid/egid in the workers (also chowns logs):
# user "unprivileged_user", "unprivileged_group"

# Help ensure your application will always spawn in the symlinked
# "current" directory that Capistrano sets up.
#working_directory "#{BASEDIR}/lib/api" # available in 0.94.0+

# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy
listen ENV.fetch('CHECK_UNICORN_TCP_PORT') { 9000 }, tcp_nopush: true

listen ENV.fetch('CHECK_UNICORN_UNIX_SOCKET') { '/tmp/check_api.sock' }, backlog: 64

# nuke workers after 30 seconds instead of 60 seconds (the default)
timeout ENV.fetch('CHECK_UNICORN_TIMEOUT') { 60 }

# feel free to point this anywhere accessible on the filesystem
pid ENV.fetch('CHECK_UNICORN_PID') { "/tmp/check_api.pid" }

# By default, the Unicorn logger will write to stderr.
# Additionally, ome applications/frameworks log to stderr or stdout,
# so prevent them from going to /dev/null when daemonized here:
# stderr_path "/path/to/app/shared/log/unicorn.stderr.log"
# stdout_path "/path/to/app/shared/log/unicorn.stdout.log"
