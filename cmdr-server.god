CMDR_ROOT = "/var/cmdr-server"
#RVM_ENV = '\. "/usr/local/rvm/environments/ruby-1.9.2-p0"'
RVM_ENV = "rvm 1.9.2"

God.watch do |w|
	w.name = "cmdr-proxy-server"
	w.interval = 30.seconds # default      
	w.start = "#{RVM_ENV}; cd #{CMDR_ROOT}; bin/cmdr-server start"
	w.stop = "#{RVM_ENV}; cd #{CMDR_ROOT}; bin/cmdr-server stop"
	w.restart = "#{RVM_ENV}; cd #{CMDR_ROOT}; bin/cmdr-server restart"
	w.start_grace = 10.seconds
	w.restart_grace = 10.seconds
	w.pid_file = "#{CMDR_ROOT}/log/cmdr-server.pid"
	w.uid = "cmdr"
	w.behavior(:clean_pid_file)

	w.start_if do |start|
		start.condition(:process_running) do |c|
			c.interval = 5.seconds
			c.running = false
		end
	end

	# lifecycle
	w.lifecycle do |on|
		on.condition(:flapping) do |c|
			c.to_state = [:start, :restart]
			c.times = 5
			c.within = 5.minute
			c.transition = :unmonitored
			c.retry_in = 10.minutes
			c.retry_times = 5
			c.retry_within = 2.hours
		end
	end
end

God.watch do |w|
	w.name = "unicorn"
	w.interval = 30.seconds # default

	# unicorn needs to be run from the rails root
	w.start = "#{RVM_ENV}; unicorn -s 2 -C #{CMDR_ROOT}/config/server.yml #{CMDR_ROOT}/lib/config.ru start"

	# QUIT gracefully shuts down workers
	w.stop = "kill -QUIT `cat #{CMDR_ROOT}/tmp/unicorn.pid`"

	# USR2 causes the master to re-create itself and spawn a new worker pool
	w.restart = "kill -USR2 `cat #{CMDR_ROOT}/tmp/unicorn.pid`"

	w.start_grace = 10.seconds
	w.restart_grace = 10.seconds
	w.pid_file = "#{CMDR_ROOT}/tmp/unicorn.pid"
	
	w.behavior(:clean_pid_file)

	w.start_if do |start|
		start.condition(:process_running) do |c|
			c.interval = 5.seconds
			c.running = false
		end
	end

	# lifecycle
	w.lifecycle do |on|
		on.condition(:flapping) do |c|
			c.to_state = [:start, :restart]
			c.times = 5
			c.within = 5.minute
			c.transition = :unmonitored
			c.retry_in = 10.minutes
			c.retry_times = 5
			c.retry_within = 2.hours
		end
	end
end
