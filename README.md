# Docker-Fluentd-Logentries: Forward logs to LogEntries

## What

This container accepts logs using the [secure forwarding plugin](http://docs.fluentd.org/articles/in_secure_forward) and forwards to a logentries account based on the tag of the log, using a modifed version of [fluent-plugin-logentries](https://github.com/Woorank/fluent-plugin-logentries)

```
docker run --name fluentd_logentries -d -v /var/lib/docker/containers:/var/lib/docker/containers -p 24284 nathanpower/fluentd-logentries
``` 

Logentries tokens can be defined in logentries-token.conf (yaml) file.

```
--- 
application: 
  log: LOGENTRIES_TOKEN
  access: ANOTHER-LOGENTRIES-TOKEN (*)
  error: ANOTHER-LOGENTRIES-TOKEN-1 (*)
system: 
  log: LOGENTRIES_TOKEN
  access: ANOTHER-LOGENTRIES-TOKEN (*)
  error: ANOTHER-LOGENTRIES-TOKEN-1 (*)
```
(*) access and error are optional, if you don't use multiple log per host just provide an app token.

This file is read on changes, it allows on fly modifications.

## Usage

```
		<source>
			type secure_forward
			shared_key         secret_string
			self_hostname      server.fqdn.local  # This fqdn is used as CN (Common Name) of certificates
			cert_auto_generate yes                # This parameter MUST be specified
		</source>

    <match pattern>
      type logentries
      config_path /path/to/logentries-tokens.conf
    </match>
```

## Parameters

### type (required)
The value must be `logentries`.

### config_path (required)
Path of your configuration file, e.g. `/opt/logentries/tokens.conf`

### protocol
The default is `tcp`.

### use_ssl
Enable/disable SSL for data transfers between Fluentd and Logentries. The default is `true`.

### port
Only in case you don't use SSL, the value must be `80`, `514`, or `10000`. The default is `20000` (SSL)

### max_retries
Number of retries on failure.

### tag_access_log, tag_error_log
This is use in case you tag your access/error log and want them to be push into another log.
