require 'statsample'
require 'rest_client'
require 'json'
require 'net/smtp'
require 'yaml'
require_relative 'util.rb'

settings = YAML.load(File.read('../settings.yml'))

MAIL_SERVER = settings['mail_server']
EMAIL_PORT = settings['mail_server_port']
EMAIL_FROM = settings['email_from']
EMAIL_FROM_NAME = settings['email_from_name']
EMAIL_TO = settings['email_to']
EMAIL_TO_NAME = settings['email_to_name']

CPU_THRESHOLD = settings['cpu_threshold']
HEAP_THESHOLD = settings['heap_threshold']
puts "Limits set to: #{CPU_THRESHOLD*100}% CPU and #{HEAP_THESHOLD*100}% Heap"

SERVER = 'http://localhost:80'
TIME = '-240s'

MACHINE = "#{settings['server'].gsub(/\./,"_")}_#{settings['port']}"
puts "Monitoring server #{MACHINE}"

# Check machine memory level
HEAP_MAX = "stats.gauges.servers.#{MACHINE}.sun_management_MemoryImpl.HeapMemoryUsage_max"
HEAP_USE = "stats.gauges.servers.#{MACHINE}.sun_management_MemoryImpl.HeapMemoryUsage_used"

errors = []

max = 0
RestClient.get "#{SERVER}/render?target=#{HEAP_MAX}&format=json&from=#{TIME}" do |response, request, result|
	json = JSON.parse(response)
	max = json[0]['datapoints'][0][0]
end
puts "Max Heap is #{max}"
if max == nil
	puts "ERROR: Not getting values!"
	exit
end

percentil = 0
RestClient.get "#{SERVER}/render?target=#{HEAP_USE}&format=json&from=#{TIME}" do |response, request, result|
	json = JSON.parse(response)
	datapoints = json[0]['datapoints']
	values = datapoints.map { |p| p[0] } # Only extract the value without time
	values.delete_if {|p| p == nil }
	v = values.to_vector(:scale)
	percentil = v.percentil(90)
end
puts "Heap Use 90 Percentil is #{percentil}"

threshold = max * HEAP_THESHOLD.to_f
if percentil > (threshold)
	errors << "Memory usage too high. > #{threshold}"
end	

# Check machine cpu level
CPU_MAX = "stats.gauges.servers.#{MACHINE}.com_sun_management_UnixOperatingSystem.SystemLoadAverage"

percentil = 0
RestClient.get "#{SERVER}/render?target=#{CPU_MAX}&format=json&from=#{TIME}" do |response, request, result|
	json = JSON.parse(response)
	datapoints = json[0]['datapoints']
	values = datapoints.map { |p| p[0]} # Only extract the value without time
	v = values.to_vector(:scale)
	percentil = v.percentil(90)
end
puts "CPU 90 Percentil is #{percentil}"

threshold = 100 * CPU_THRESHOLD.to_f
if percentil > (threshold)
	errors << "CPU usage too high. > #{threshold}"
end

unless errors.size == 0
	if error_sent_recently? settings['email_send_threshold']
		puts 'Not sending email since one was recently sent.'
		exit
	end

	error_text = ""
	errors.each do |error|
		error_text += "#{error}\n"
	end

	puts "The following errors occured:\n#{error_text}\nSending mail to #{EMAIL_TO}"

 	message = <<-MESSAGE_END
From: #{EMAIL_FROM_NAME} <#{EMAIL_FROM}>
To: #{EMAIL_TO_NAME} <#{EMAIL_TO}>
Subject: Threshold hit

The following errors occured:
#{error_text}
 	MESSAGE_END

 	Net::SMTP.start(MAIL_SERVER) do |smtp|
 	  smtp.send_message message, EMAIL_FROM, EMAIL_TO
 	  update_send_time
 	end
end
