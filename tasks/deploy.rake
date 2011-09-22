require 'json'
require 'pty'
require 'expect'

MAC_VALUE = "REPLACE_WITH_REAL_MAC_THIS_SHOULD_BE_UNIQUE_e1599512ea6"

WORKING = File.dirname(__FILE__) + '/..'
TARGETS = ['/wescontrol_web']

# load server addresses from servers.json
servers_file = File.open(WORKING + "/servers.json")
exit "No servers.json file found" unless servers_file
servers = JSON.parse(servers_file.read)
SERVERS = servers['servers']

OPTS = {}

desc "Builds sc apps for deployment"
task :build do
	Dir.chdir WORKING + '/wescontrol_web'
	puts `sc-build #{TARGETS * ' '} -rv`
end

desc "cleans the build output"
task :clean do
	path = WORKING + '/wescontrol_web/tmp/'
	puts "Removing #{path}"
	puts `rm -r #{path}`
end

desc "installs gems needed for this Rakefile to run"
task :install_gems do
	puts "sudo gem install highline net-ssh net-scp sproutcore git"
	puts `sudo gem install highline net-ssh net-scp sproutcore git`
end

desc "setup controller databases"
task :setup_db do
	begin
		require 'net/ssh'
		require 'net/scp'
		require 'couchrest'
	rescue LoadError => e
		puts "\n ~ FATAL: net-scp gem is required.\n          Try: rake install_gems"
		exit(1)
	end
	
	password = OPTS[:password]
	targets  = OPTS[:targets]
    
	SERVERS.each do |server|
    Net::SCP.start(server, 'roomtrol', :password => password) do |scp|
      puts " ~ uploading database script"
      local_path = WORKING + '/lib/server/database.rb'
      scp.upload! local_path, "/tmp/database.rb"
    end
		Net::SSH.start(server, 'roomtrol', :password => password) do |ssh|
      puts " ~ running database script"
      commands = ["source /usr/local/rvm/environments/default",
                  "ruby -r couchrest -r '/tmp/database.rb' -e 'Database.setup_database'"]
		  puts ssh.exec!(commands.join(" && "))
		end
	end
end

desc "finds all targets in the system and computes their build numbers" 
task :prepare_targets do
	begin
		require 'sproutcore'  
	rescue LoadError => e
		puts "\n ~ FATAL: sproutcore gem is required.\n          Try: rake install_gems"
		exit(1)
	end

	puts "discovering all installed targets"
	SC.build_mode = :production
	project = SC.load_project(WORKING + '/wescontrol_web') 

	# get all targets and prepare them so that build numbers work
	targets = TARGETS.map do |name| 
		target = project.target_for(name)
		[target] + target.expand_required_targets
	end
	targets = targets.flatten.compact.uniq

	puts "preparing build numbers"
	targets.each { |t| t.prepare!.compute_build_number }

	OPTS[:targets] = targets
	OPTS[:project] = project
end


desc "copies the files to the controllers"
task :deploy_assets, [] => [:build, :prepare_targets] do
	begin
		require 'net/ssh'
		require 'net/scp'
	rescue LoadError => e
		puts "\n ~ FATAL: net-scp gem is required.\n          Try: rake install_gems"
		exit(1)
	end
	
	password = OPTS[:password]
	targets  = OPTS[:targets]

	SERVERS.each do |server|
		installed = {}
		puts "building directory structure on #{server}"
		Net::SSH.start(server, 'roomtrol', :password => password) do |ssh|
			targets.each do |target|
				remote_path = "/var/www/static#{target.index_root}/en"
				puts ssh.exec!(%[mkdir -p "#{remote_path}"]) || "%: mkdir -p #{remote_path}"
				
				remote_path = "#{remote_path}/#{target.build_number}"
				installed[remote_path] = !(ssh.exec!("ls #{remote_path}") =~ /No such file or directory/)
			end
		end
		
		puts "Copying static resources onto #{server}"
		Net::SCP.start(server, 'roomtrol', :password => password) do |scp|
			targets.each do |target|
				local_path = target.build_root + '/en/' + target.build_number
				remote_path = "/var/www/static#{target.index_root}/en"
				short_path = local_path.gsub /^#{Regexp.escape(target.build_root)}/,''
				if installed["#{remote_path}/#{target.build_number}"]
					puts " ~ #{target.target_name}#{short_path} already installed"
				elsif File.directory?(local_path)
					puts " ~ uploading #{target.target_name}#{short_path}"
					scp.upload! local_path, remote_path, :recursive => true
					Net::SSH.start(server, 'roomtrol', :password => password) do |ssh|
						# replace the mac address placeholder in the javascript file on the controller
						# with the controller's actual mac address
						output = ssh.exec!("ifconfig")
						re = %r/[^:\-](?:[0-9A-F][0-9A-F][:\-]){5}[0-9A-F][0-9A-F][^:\-]/io
						mac = output[re].strip
						ssh.exec!("sed -i 's/#{MAC_VALUE}/#{mac}/g' #{remote_path}/#{target.build_number}/javascript.js")
					end
				else
					puts "\n\n ~ WARN: cannot install #{target.target_name} - local path #{local_path} does not exist\n\n"
				end
			end
		end
	end
end

desc "creates symlinks to the latest versions of all pages and apps on the controllers."
task :link_current, [] => [:prepare_targets] do
	# don't require unless this task runs to avoid dependency problems
	begin
		require 'net/ssh'
	rescue LoadError => e
		puts "\n ~ FATAL: net-ssh gem is required.\n          Try: rake install_gems"
		exit(1)
	end
    
	# now filter out only app targets living in the current project
	targets = OPTS[:targets]
	project = OPTS[:project]
	targets = targets.select { |t| t.target_type == :app }
	targets = targets.select do |t| 
		t.source_root =~ /^#{Regexp.escape(project.project_root)}/
	end

	puts "linking targets:\n  #{targets.map {|t| t.target_name} * "\n  " }"

	# SSH in and do the symlink
	password = OPTS[:password]
	SERVERS.each do |server|
		Net::SSH.start(server, "roomtrol", :password => password) do |ssh|
			targets.each do |target|
			# find the local build number
				build_number = target.prepare!.compute_build_number

				puts "Installing #{target.target_name} to #{server}..."

				# first, link index.html
				from_path = "/var/www/static#{target.index_root}/en/#{build_number}/index.html"
				to_path   = "/var/www#{target.target_name}"

				puts ssh.exec!("mkdir -p #{to_path}") || "% mkdir -p #{to_path}"
				to_path = "#{to_path}/index.html"
				unless ssh.exec!("ls #{to_path}").empty? # check for existance
					puts ssh.exec!("rm #{to_path}") || " ~ Removed link at #{to_path}"
				end
				puts ssh.exec!("ln -s #{from_path} #{to_path}") || " ~ Linked #{from_path} => #{to_path}"

				# link each language
				from_path = "/var/www/static#{target.index_root}/en/#{build_number}"
				to_path   = "/var/www#{target.target_name}/en"

				unless ssh.exec!("ls #{to_path}").empty? # check for existance
					puts ssh.exec!("rm #{to_path}") || " ~ Removed link at #{to_path}"
				end
				puts ssh.exec!("ln -s #{from_path} #{to_path}") || " ~ Linked #{from_path} => #{to_path}"
			end
		end
	end
end

desc "deploy server code"
task :deploy_roomtrol_server do
	begin
		require 'net/ssh'
	rescue LoadError => e
		puts "\n ~ FATAL: net-scp gem is required.\n          Try: rake install_gems"
		exit(1)
	end
	
	SERVERS.each do |server|
    cmd = "rsync -arvz -e ssh #{WORKING} roomtrol@#{server}:/var/roomtrol-server --exclude '.git'"
    PTY.spawn(cmd){|read,write,pid|
      write.sync = true
      $expect_verbose = false
      read.expect(/total size/) do
      end
    }
		# Net::SSH.start(server, "roomtrol", :password => OPTS[:password]) do |ssh|
		# 	puts "\tInstalling gems on server"
		# 	path = "/var/roomtrol-server"
		# 	commands = [
		# 		"rvm 1.9.2",
		# 		"bundle install"
		# 	]
		# 	puts ssh.exec!(commands.join("; "))
		# end
		puts "\tInstallation finished on #{server}"
	end
end

desc "builds and then deploys the files onto every server in servers.json.  This will not clean the build first, which will be faster.  If you have trouble try deploy_clean"
task :deploy_servers, [] => [ :build, :deploy_assets, :link_current, :setup_db]

desc "first cleans, then deploys the files"
task :deploy_clean => [:clean, :deploy]
