module Wescontrol
	class SocketDevice < Device
		attr_accessor :uri
		
		configure do
			uri :type => :uri
			baud :type => :integer, :default => 9600
			data_bits 8
			stop_bits 1
			parity 0
			message_end "\r\n"
		end
	end						
end
