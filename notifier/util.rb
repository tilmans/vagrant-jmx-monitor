def update_send_time()
	timestamp = Time.now.to_i
	File.write('last_update',timestamp)
end

def error_sent_recently?(threshold)
	return false unless File.exists? 'last_update'
	old_timestamp = File.read('last_update').to_i
	timestamp = Time.now.to_i
	timestamp < ( old_timestamp + threshold * 60 )
end

