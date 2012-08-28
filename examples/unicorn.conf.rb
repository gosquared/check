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
user ENV.fetch('CHECK_API_USER') { ENV['USER'] }, ENV.fetch('CHECK_API_GROUP') { nil }

# listen on both a Unix domain socket and a TCP port,
#
# The backlog is for the listen() syscall.
# Some operating systems allow negative values here to specify the
# maximum allowable value. In most cases, this number is only
# recommendation and there are other OS-specific tunables and variables
# that can affect this number. See the listen(2) syscall documentation
# of your OS for the exact semantics of this.
# The shorter backlog ensures quicker failover when busy, and helps the
# load balancer spread requests evenly.
listen ENV.fetch('CHECK_UNICORN_TCP_PORT') { 9000 }, backlog: ENV.fetch('CHECK_UNICORN_BACKLOG') { 128 }.to_i
listen ENV.fetch('CHECK_UNICORN_UNIX_SOCKET') { '/tmp/check_api.sock' }, backlog: ENV.fetch('CHECK_UNICORN_BACKLOG') { 128 }.to_i

# Sets the timeout of worker processes to seconds. Workers handling the
# request/app.call/response cycle taking longer than this time period
# will be forcibly killed (via SIGKILL). This timeout is enforced by the
# master process itself and not subject to the scheduling limitations by
# the worker process. Due the low-complexity, low-overhead
# implementation, timeouts of less than 3.0 seconds can be considered
# inaccurate and unsafe.
# For running Unicorn behind nginx, it is recommended to set
# "fail_timeout=0" for in your nginx configuration like this to have
# nginx always retry backends that may have had workers SIGKILL-ed due
# to timeouts.
timeout ENV.fetch('CHECK_UNICORN_TIMEOUT') { 30 }

# PID of the unicorn master process
pid ENV.fetch('CHECK_UNICORN_PID') { '/tmp/check_api.pid' }

# By default, the Unicorn logger will write to stderr.
# Additionally, some applications/frameworks log to stderr or stdout,
# so prevent them from going to /dev/null when daemonized here:
stderr_path ENV.fetch('CHECK_UNICORN_STDERR') { $STDERR }
stdout_path ENV.fetch('CHECK_UNICORN_STDOUT') { $STDOUT }
