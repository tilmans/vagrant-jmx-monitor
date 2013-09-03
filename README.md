vagrant-jmx-monitor
===================

Vagrant box with graphite, statsd and jmxtrans to monitor a VM

Configure and run the box
--------------------

* Copy and modify the settings template
	* Create a copy of `settings.yml.template` and save as `settings.yml`
	* Change the contents of settings.yml to match your system
* Startup the box
	* In the console run `vagrant up`

If you make changes or restart the box you can run `vagrant provision` at any time to make sure all processes are still running.

View stats of the running system
--------------------
Once the system is up and running you can view the stats at [http://localhost:8080/dashboard/](http://localhost:8080/dashboard/)

JMXTrans
--------------------
JMXTrans takes care of sending JMX data to statsd. It is configured via the `heapmemory.json` file in the jmxtrans directory. It is currently preconfigured to expose heap memory and CPU information. 

If you are not seeing new values in graphite then make sure that there are no errors in the following files:

    jmxtrans/jmxtrans.log
    jmxtrans/errors.txt
    jmxtrans/log.txt

Email notifications
-------------------
Based on the data in graphite, a regulartly scheduled script checks for high loads on the server and sends out an email if it hits the limits configured in `settings.yml`. The heap limit corresponds to > 80% usage of the max heap.

Simple System monitoring client
-------------------
To get basic system data into graphite quickly the project includes a minimal node client that reads CPU and memory values and that should work across all OS that support node.

* Install node
* cd into `node`
* `npm install`
* Change the STATSD_SERVER to the IP or name of the machine running the VM
* `node stat.js`