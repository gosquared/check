ENV['REDIS_URI'] = "unix:///tmp/redis-check-test.sock"

PWD = File.expand_path('../', __FILE__)

def start_test_redis_server
  stop_test_redis_server
  %x{redis-server #{PWD}/redis-test.conf}
end

def stop_test_redis_server
  %x{
    pid=/tmp/redis-check-test.pid
    sock=/tmp/redis-check-test.sock
    if [ -e $pid ]; then
      cat $pid | xargs kill -QUIT
      rm -f $pid
      rm -f $sock
    fi
  }
end

start_test_redis_server
