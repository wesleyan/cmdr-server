ROOMTROL_ROOT = "/var/roomtrol-server"
#RVM_ENV = '\. "/usr/local/rvm/environments/ruby-1.9.2-p0"'
RVM_ENV = "rvm 1.9.2"

God.watch do |w|
	w.name = "roomtrol-proxy-server"
	w.interval = 30.seconds # default      
	w.start = "#{RVM_ENV}; cd #{ROOMTROL_ROOT}; bin/roomtrol-server start"
	w.stop = "#{RVM_ENV}; cd #{ROOMTROL_ROOT}; bin/roomtrol-server stop"
	w.restart = "#{RVM_ENV}; cd #{ROOMTROL_ROOT}; bin/roomtrol-server restart"
	w.start_grace = 10.seconds
	w.restart_grace = 10.seconds
	w.pid_file = "#{ROOMTROL_ROOT}/log/roomtrol-server.pid"
	w.uid = "roomtrol"
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
	w.start = "#{RVM_ENV}; unicorn -P #{ROOMTROL_ROOT}/tmp/unicorn.pid #{ROOMTROL_ROOT}/lib/config.ru"

	# QUIT gracefully shuts down workers
	w.stop = "kill -QUIT `cat #{ROOMTROL_ROOT}/tmp/unicorn.pid`"

	# USR2 causes the master to re-create itself and spawn a new worker pool
	w.restart = "kill -USR2 `cat #{ROOMTROL_ROOT}/tmp/unicorn.pid`"

	w.start_grace = 10.seconds
	w.restart_grace = 10.seconds
	w.pid_file = "#{ROOMTROL_ROOT}/tmp/unicorn.pid"
	
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