Notes about ISO8601 Migration:

Old syslog datetime format:
ex: Sep  8 10:09:33

New syslog datetime (ISO8601) format:
ex: 2010-09-08T10:20:15.009922+02:00

* Configuration:
rsyslog.conf:
#$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat

* Source Modifications:
 octo_dispatcher
 octo_parser
 octo_uparser
 octo_pusher *
 New type DATE_TIME_ISO in types.xml
 DATE_TIME_SYSLOG -> DATE_TIME_ISO in all Services