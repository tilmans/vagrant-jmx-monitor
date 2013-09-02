os = require('os-utils');
var SDC = require('statsd-client'),
    sdc = new SDC({host: 'localhost', port: 8125, prefix: require('os').hostname(), debug: true});

var regular_update = function () {
	console.log("Update...");
	os.cpuUsage(function(v){
	    sdc.gauge('cpu.usage', v*100);
	});
	os.cpuFree( function(v) {
	    sdc.gauge('cpu.free', v*100);
	} );
	sdc.gauge('mem.free', os.freemem() * 1000 * 1000);
	sdc.gauge('mem.total', os.totalmem() * 1000 * 1000);
};

setInterval(regular_update, 10000);
