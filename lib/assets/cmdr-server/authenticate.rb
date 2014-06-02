require 'yaml'
require 'openssl'

module Authenticate
  def self.get_credentials(path="#{File.dirname(__FILE__)}")

    credentials = YAML::load_file "#{path}/credentials.yml"
    key = YAML::load_file "#{path}/key.yml"

    decipher = OpenSSL::Cipher::AES.new(128, :CBC)
    decipher.decrypt
    decipher.key = key[:key]
    decipher.iv = key[:iv]

    pw = decipher.update(credentials[:password]) + decipher.final
    return {"user" => credentials[:user], "password" => pw}
  end
end
