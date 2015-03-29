# Module: rsyslog
#
# Class: rsyslog
#
# Description: 
#	This class configures rsyslog from a file included in the templates
#	directory and ensures appropriate log files are present.
#
# Defines:
#	None
#
# Variables:
#	None
#
# Facts:
#	None
#
# Files:
#	rsyslog.conf.erb
#
# LinuxGuide:
#	2.6.1.2
#
# CCERef#:
#	CCE-3382-9
#	CCE-3679-8
#	CCE-3701-0
#	CCE-4233-3
#	CCE-4260-6
#	CCE-4366-1
#
class rsyslog {

	# GuideSection 2.6.1.2.1
	package {
		"rsyslog":
			ensure => installed,
	}

	# GuideSection 2.6.1.2.2
	# CCE-3679-8	
	service {
		"rsyslog":
			ensure    => true,
			enable    => true,
			hasstatus => true,
			require   => Package["rsyslog"];
		"syslog":
			ensure    => false,
			enable    => false,
			hasstatus => true;
	}

	# GuideSection 2.6.1.2
	# CCE-4260-6
	# Configure rsyslog	
	file {
		# GuideSection 2.6.1.2.4
		"/etc/rsyslog.conf":
			owner   => "root",
			group   => "root",
			mode    => 644,
			content => template("rsyslog/rsyslog.conf.erb"),
			require => Package["rsyslog"],
			notify  => Service["rsyslog"];

	}
}
