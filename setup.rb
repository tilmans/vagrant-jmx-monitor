#!/home/vagrant/.rvm/rubies/ruby-1.9.3-p448/bin/ruby

require 'yaml'
require 'json'
require 'net/smtp'
require_relative 'util.rb'

SETTINGS_FILE = '/vagrant/settings.yml'

unless File.exists? SETTINGS_FILE
	puts 'Expected settings.yml file not provided.'
	puts 'Create a copy of settings.yml.template and adjuste the values'
	exit -1
end

settings = YAML.load(File.read(SETTINGS_FILE))
puts JSON.pretty_generate(settings)

unless settings.has_key?('server') && settings.has_key?('port')
	puts 'You have to set server and port for JMX connections'
	exit -1
end

SERVER = settings['server']
PORT = settings['port']

unless is_port_open? SERVER, PORT
	puts "Unable to connect to #{SERVER}:#{PORT}"
	puts 'Make sure JMX is running on that machine'
	exit -1
end

jmxfile = '/vagrant/jmxtrans/heapmemory.json'
json = JSON.parse(File.read(jmxfile))
json['servers'][0]['host'] = SERVER
json['servers'][0]['port'] = PORT
File.write(jmxfile, JSON.pretty_generate(json))

MAIL_KEYS = ['mail_server', 'mail_server_port', 'email_from', 'email_from_name',
	'email_to', 'email_to_name']
unless has_all_keys? settings, MAIL_KEYS
	puts 'Not all settings for email configured'
	puts "Expeced: #{MAIL_KEYS}"
	exit -1
end

MAIL_SERVER = settings['mail_server']
EMAIL_PORT = settings['mail_server_port']
EMAIL_FROM = settings['email_from']
EMAIL_FROM_NAME = settings['email_from_name']
EMAIL_TO = settings['email_to']
EMAIL_TO_NAME = settings['email_to_name']

message = <<-MESSAGE_END
From: #{EMAIL_FROM_NAME} <#{EMAIL_FROM}>
To: #{EMAIL_TO_NAME} <#{EMAIL_TO}>
Subject: Avid Monitor test email

Success!
MESSAGE_END

Net::SMTP.start(MAIL_SERVER) do |smtp|
  smtp.send_message message, EMAIL_FROM, 
                             EMAIL_TO
end

Dir.chdir('/vagrant/jmxtrans')
`./stop.sh`
if `ps -A | grep java` != ''
	`killall -9 java`
end
`rm pid.txt` if File.exists? 'pid.txt'
`./start.sh`

Dir.chdir('/vagrant/notifier')
`crontab crontab`
