# need :tcp_nopush => false 	# for streaming
# see https://gist.github.com/nathany/5058140 for more info
# nb backlog has a minimum size of 16 iirc
listen ENV['PORT'], :backlog => Integer(ENV['UNICORN_BACKLOG'] || 32), :tcp_nopush => false

worker_processes (ENV["unicorn_workers"] || 3).to_i     # number of unicorn workers to spin up

timeout (ENV["unicorn_timeout"] || 60).to_i         	# restarts workers that don't return after X seconds

timeout 30

# combine Ruby 2.0.0dev or REE with "preload_app true" for memory savings
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
    GC.copy_on_write_friendly = true


before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  # the following is *required* for Rails + "preload_app true",
  # more details added from https://devcenter.heroku.com/articles/concurrency-and-database-connections
  if defined?(ActiveRecord::Base)
    config = Rails.application.config.database_configuration[Rails.env]
    config['reaping_frequency'] = ENV['DB_REAP_FREQ'] || 10 # seconds
    config[:reaping_frequency]  = ENV['DB_REAP_FREQ'] || 10 # seconds
    config['pool']              = ENV['DB_POOL'] || 5
    config[:pool]               = ENV['DB_POOL'] || 5
    info = ActiveRecord::Base.establish_connection(config)
  end
end