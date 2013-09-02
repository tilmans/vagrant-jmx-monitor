#!/home/vagrant/.rvm/rubies/ruby-1.9.3-p448/bin/ruby

require 'yaml'
require 'json'
require 'net/smtp'

settings = YAML.load(File.read('/vagrant/settings.yml'))
puts settings

jmxfile = '/vagrant/jmxtrans/heapmemory.json'
json = JSON.parse(File.read(jmxfile))
json['servers'][0]['host'] = settings['server']
json['servers'][0]['port'] = settings['port']
File.write(jmxfile, JSON.pretty_generate(json))

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
`killall -9 java`
`rm pid.txt`
`./start.sh`

Dir.chdir('/vagrant/notifier')
`crontab crontab`
