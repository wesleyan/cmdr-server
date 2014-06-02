require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CmdrServerRails
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += %W(#{config.root}/lib/assets/cmdr-server)

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.after_initialize do
     DNSSD.browse("_roomtrol._tcp") do |client_reply|
      #begin - zeroconf detection
      if (client_reply.flags.to_i & DNSSD::Flags::Add) != 0
        
        #DaemonKit.logger.debug("DNSSD Add: #{client_reply.inspect}".foreground(:green))
        client = Zeroconf::Client.new client_reply
        #client.setup(@db_rooms, @uberroom_id)
        #@clients << client
        #DaemonKit.logger.debug(@clients.inspect)
      else
        puts "DNSSD Remove"
        #DaemonKit.logger.debug("DNSSD Remove: #{client_reply.name}".foreground(:red))
      end
      #end - zeroconf detection
    end
   end
  end
end
