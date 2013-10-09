module Wescontrol
	class SocketDevice < Device
		attr_accessor :uri
		
		configure do
			uri :type => :string
		end
	end						
end
