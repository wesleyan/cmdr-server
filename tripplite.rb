# Copyright (C) 2014 Wesleyan University
#
# This file is part of cmdr-devices.
#
# cmdr-devices is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# cmdr-devices is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with cmdr-devices. If not, see <http://www.gnu.org/licenses/>.

#---
#{
# "name": "TrippLite",
# "depends_on": "Device",
# "description": "Monitors current charge level of TrippLite PowerAlert PDU over the web interface",
# "author": "Max Dietz",
# "email": "mdietz@wesleyan.edu",
# "type": "Network PDU/Battery"
#}
#---

require 'net/http'

class TrippLite < Cmdr::Device

  configure do
    ip_address :type => :string
  end
  
  state_var :battery_percent,     :type => :integer,  :editable => false
  
  def initialize(name, options)
    DaemonKit.logger.info "Initializing TrippLite on #{self.ip_address}"
    options = options.symbolize_keys
    Thread.abort_on_exception = true
    super(name, :ip_address => options[:ip_address])   
  end
  
  def run
    Thread.new {
      uri = URI('http://' + self.ip_address + '/summary/summary_battery.htm')
      while true
        begin
          req = Net::HTTP::Get.new(uri)
          req.basic_auth 'guest', 'guest'
          res = Net::HTTP.start(uri.hostname, uri.port) { |http| 
            http.request(req)
          }
          @battery_percent = res.body.match(/Charge Remaining","(...)/)[0][0...-1].strip().to_i
          sleep 60
        rescue
        end
      end
    }
    super
  end
end
