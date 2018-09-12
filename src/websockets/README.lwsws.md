Notes about lwsws
=================

@section lwsws Libwebsockets Web Server

lwsws is an implementation of a very lightweight, ws-capable generic web
server, which uses libwebsockets to implement everything underneath.

If you are basically implementing a standalone server with lws, you can avoid
reinventing the wheel and use a debugged server including lws.


@section lwswsb Build

Just enable -DLWS_WITH_LWSWS=1 at cmake-time.

It enables libuv and plugin support automatically.

NOTICE on Ubuntu, the default libuv package is called "libuv-0.10".  This is ancient.

You should replace this with libuv1 and libuv1-dev before proceeding.

@section lwswsc Lwsws Configuration

lwsws uses JSON config files, they're pure JSON except:

 - '#' may be used to turn the rest of the line into a comment.

 - There's also a single substitution, if a string contains "_lws_ddir_", then that is
replaced with the LWS install data directory path, eg, "/usr/share" or whatever was
set when LWS was built + installed.  That lets you refer to installed paths without
having to change the config if your install path was different.

There is a single file intended for global settings

/etc/lwsws/conf
```
	# these are the server global settings
	# stuff related to vhosts should go in one
	# file per vhost in ../conf.d/

	{
	  "global": {
	   "uid": "48",  # apache user
	   "gid": "48",  # apache user
	   "count-threads": "1",
	   "server-string": "myserver v1", # returned in http headers
	   "ws-pingpong-secs": "200", # confirm idle established ws connections this often
	   "init-ssl": "yes"
	 }
	}
```
and a config directory intended to take one file per vhost

/etc/lwsws/conf.d/warmcat.com
```
	{
		"vhosts": [{
			"name": "warmcat.com",
			"port": "443",
			"interface": "eth0",  # optional
			"host-ssl-key": "/etc/pki/tls/private/warmcat.com.key",  # if given enable ssl
			"host-ssl-cert": "/etc/pki/tls/certs/warmcat.com.crt",
			"host-ssl-ca": "/etc/pki/tls/certs/warmcat.com.cer",
			"mounts": [{  # autoserve
				"mountpoint": "/",
				"origin": "file:///var/www/warmcat.com",
				"default": "index.html"
			}]
		}]
	}
```
To get started quickly, an example config reproducing the old test server
on port 7681, non-SSL is provided.  To set it up
```
	# mkdir -p /etc/lwsws/conf.d /var/log/lwsws
	# cp ./lwsws/etc-lwsws-conf-EXAMPLE /etc/lwsws/conf
	# cp ./lwsws/etc-lwsws-conf.d-localhost-EXAMPLE /etc/lwsws/conf.d/test-server
	# sudo lwsws
```

@section lwswsv Lwsws Vhosts

One server can run many vhosts, where SSL is in use SNI is used to match
the connection to a vhost and its vhost-specific SSL keys during SSL
negotiation.

Listing multiple vhosts looks something like this
```
	{
	 "vhosts": [ {
	     "name": "localhost",
	     "port": "443",
	     "host-ssl-key":  "/etc/pki/tls/private/libwebsockets.org.key",
	     "host-ssl-cert": "/etc/pki/tls/certs/libwebsockets.org.crt",
	     "host-ssl-ca":   "/etc/pki/tls/certs/libwebsockets.org.cer",
	     "mounts": [{
	       "mountpoint": "/",
	       "origin": "file:///var/www/libwebsockets.org",
	       "default": "index.html"
	       }, {
	        "mountpoint": "/testserver",
	        "origin": "file:///usr/local/share/libwebsockets-test-server",
	        "default": "test.html"
	       }],
	     # which protocols are enabled for this vhost, and optional
	     # vhost-specific config options for the protocol
	     #
	     "ws-protocols": [{
	       "warmcat,timezoom": {
	         "status": "ok"
	       }
	     }]
	    },
	    {
	    "name": "localhost",
	    "port": "7681",
	     "host-ssl-key":  "/etc/pki/tls/private/libwebsockets.org.key",
	     "host-ssl-cert": "/etc/pki/tls/certs/libwebsockets.org.crt",
	     "host-ssl-ca":   "/etc/pki/tls/certs/libwebsockets.org.cer",
	     "mounts": [{
	       "mountpoint": "/",
	       "origin": ">https://localhost"
	     }]
	   },
	    {
	    "name": "localhost",
	    "port": "80",
	     "mounts": [{
	       "mountpoint": "/",
	       "origin": ">https://localhost"
	     }]
	   }
	
	  ]
	}
```

That sets up three vhosts all called "localhost" on ports 443 and 7681 with SSL, and port 80 without SSL but with a forced redirect to https://localhost


@section lwswsvn Lwsws Vhost name and port sharing

The vhost name field is used to match on incoming SNI or Host: header, so it
must always be the host name used to reach the vhost externally.

 - Vhosts may have the same name and different ports, these will each create a
listening socket on the appropriate port.

 - Vhosts may also have the same port and different name: these will be treated as
true vhosts on one listening socket and the active vhost decided at SSL
negotiation time (via SNI) or if no SSL, then after the Host: header from
the client has been parsed.


@section lwswspr Lwsws Protocols

Vhosts by default have available the union of any initial protocols from context creation time, and
any protocols exposed by plugins.

Vhosts can select which plugins they want to offer and give them per-vhost settings using this syntax
```
	     "ws-protocols": [{
	       "warmcat-timezoom": {
	         "status": "ok"
	       }
	     }]
```

The "x":"y" parameters like "status":"ok" are made available to the protocol during its per-vhost
LWS_CALLBACK_PROTOCOL_INIT (@in is a pointer to a linked list of struct lws_protocol_vhost_options
containing the name and value pointers).

To indicate that a protocol should be used when no Protocol: header is sent
by the client, you can use "default": "1"
```
	     "ws-protocols": [{
	       "warmcat-timezoom": {
	         "status": "ok",
	         "default": "1"
	       }
	     }]
```


@section lwswsovo Lwsws Other vhost options

 - If the three options `host-ssl-cert`, `host-ssl-ca` and `host-ssl-key` are given, then the vhost supports SSL.

 Each vhost may have its own certs, SNI is used during the initial connection negotiation to figure out which certs to use by the server name it's asking for from the request DNS name.

 - `keeplive-timeout` (in secs) defaults to 60 for lwsws, it may be set as a vhost option

 - `interface` lets you specify which network interface to listen on, if not given listens on all

 - "`unix-socket`": "1" causes the unix socket specified in the interface option to be used instead of an INET socket

 - "`sts`": "1" causes lwsws to send a Strict Transport Security header with responses that informs the client he should never accept to connect to this address using http.  This is needed to get the A+ security rating from SSL Labs for your server.

 - "`access-log`": "filepath"   sets where apache-compatible access logs will be written

 - `"enable-client-ssl"`: `"1"` enables the vhost's client SSL context, you will need this if you plan to create client conections on the vhost that will use SSL.  You don't need it if you only want http / ws client connections.

 - "`ciphers`": "<cipher list>"   sets the allowed list of ciphers and key exchange protocols for the vhost.  The default list is restricted to only those providing PFS (Perfect Forward Secrecy) on the author's Fedora system.
 
 If you need to allow weaker ciphers,you can provide an alternative list here per-vhost.
 
 - "`ecdh-curve`": "<curve name>"   The default ecdh curve is "prime256v1", but you can override it here, per-vhost

 - "`noipv6`": "on"  Disable ipv6 completely for this vhost

 - "`ipv6only`": "on"  Only allow ipv6 on this vhost / "off" only allow ipv4 on this vhost

 - "`ssl-option-set`": "<decimal>"  Sets the SSL option flag value for the vhost.
 It may be used multiple times and OR's the flags together.
 
 The values are derived from /usr/include/openssl/ssl.h
```
	 # define SSL_OP_NO_TLSv1_1                               0x10000000L
```
 
 would equate to
 
```
	 "`ssl-option-set`": "268435456"
 ```
 - "`ssl-option-clear'": "<decimal>"   Clears the SSL option flag value for the vhost.
 It may be used multiple times and OR's the flags together.

 - "`headers':: [{ "header1": "h1value", "header2": "h2value" }] 

allows you to set arbitrary headers on every file served by the vhost

recommended vhost headers for good client security are

```
                   "headers": [{
                        "Content-Security-Policy": "script-src 'self'",
                        "X-Content-Type-Options": "nosniff",
                        "X-XSS-Protection": "1; mode=block",
                        "X-Frame-Options": "SAMEORIGIN"
                 }]

```

@section lwswsm Lwsws Mounts

Where mounts are given in the vhost definition, then directory contents may
be auto-served if it matches the mountpoint.

Mount protocols are used to control what kind of translation happens

 - file://  serve the uri using the remainder of the url past the mountpoint based on the origin directory.

 Eg, with this mountpoint
```
	       {
	        "mountpoint": "/",
	        "origin": "file:///var/www/mysite.com",
	        "default": "/"
	       }
```
 The uri /file.jpg would serve /var/www/mysite.com/file.jpg, since / matched.

 - ^http:// or ^https://  these cause any url matching the mountpoint to issue a redirect to the origin url

 - cgi://   this causes any matching url to be given to the named cgi, eg
```
	       {
	        "mountpoint": "/git",
	        "origin": "cgi:///var/www/cgi-bin/cgit",
	        "default": "/"
	       }, {
	        "mountpoint": "/cgit-data",
	        "origin": "file:///usr/share/cgit",
	        "default": "/"
	       },
```
 would cause the url /git/myrepo to pass "myrepo" to the cgi /var/www/cgi-bin/cgit and send the results to the client.



@section lwswsomo Lwsws Other mount options

1) Some protocols may want "per-mount options" in name:value format.  You can
provide them using "pmo"

	       {
	        "mountpoint": "/stuff",
	        "origin": "callback://myprotocol",
	        "pmo": [{
	                "myname": "myvalue"
	        }]
	       }

2) When using a cgi:// protcol origin at a mountpoint, you may also give cgi environment variables specific to the mountpoint like this
```
	       {
	        "mountpoint": "/git",
	        "origin": "cgi:///var/www/cgi-bin/cgit",
	        "default": "/",
	        "cgi-env": [{
	                "CGIT_CONFIG": "/etc/cgitrc/libwebsockets.org"
	        }]
	       }
```
 This allows you to customize one cgi depending on the mountpoint (and / or vhost).

3) It's also possible to set the cgi timeout (in secs) per cgi:// mount, like this
```
	"cgi-timeout": "30"
```
4) `callback://` protocol may be used when defining a mount to associate a
named protocol callback with the URL namespace area.  For example
```
	       {
	        "mountpoint": "/formtest",
	        "origin": "callback://protocol-post-demo"
	       }
```
All handling of client access to /formtest[anything] will be passed to the
callback registered to the protocol "protocol-post-demo".

This is useful for handling POST http body content or general non-cgi http
payload generation inside a plugin.

See the related notes in README.coding.md

5) Cache policy of the files in the mount can also be set.  If no
options are given, the content is marked uncacheable.
```
	       {
	        "mountpoint": "/",
	        "origin": "file:///var/www/mysite.com",
	        "cache-max-age": "60",      # seconds
	        "cache-reuse": "1",         # allow reuse at client at all
	        "cache-revalidate": "1",    # check it with server each time
	        "cache-intermediaries": "1" # allow intermediary caches to hold
	       }
```

6) You can also define a list of additional mimetypes per-mount
```
	        "extra-mimetypes": {
	                 ".zip": "application/zip",
	                 ".doc": "text/evil"
	         }
```

Normally a file suffix MUST match one of the canned mimetypes or one of the extra
mimetypes, or the file is not served.  This adds a little bit of security because
even if there is a bug somewhere and the mount dirs are circumvented, lws will not
serve, eg, /etc/passwd.

If you provide an extra mimetype entry

			"*": ""

Then any file is served, if the mimetype was not known then it is served without a
Content-Type: header.

@section lwswspl Lwsws Plugins

Protcols and extensions may also be provided from "plugins", these are
lightweight dynamic libraries.  They are scanned for at init time, and
any protocols and extensions found are added to the list given at context
creation time.

Protocols receive init (LWS_CALLBACK_PROTOCOL_INIT) and destruction
(LWS_CALLBACK_PROTOCOL_DESTROY) callbacks per-vhost, and there are arrangements
they can make per-vhost allocations and get hold of the correct pointer from
the wsi at the callback.

This allows a protocol to choose to strictly segregate data on a per-vhost
basis, and also allows the plugin to handle its own initialization and
context storage.

To help that happen conveniently, there are some new apis

 - lws_vhost_get(wsi)
 - lws_protocol_get(wsi)
 - lws_callback_on_writable_all_protocol_vhost(vhost, protocol)
 - lws_protocol_vh_priv_zalloc(vhost, protocol, size)
 - lws_protocol_vh_priv_get(vhost, protocol)
 
dumb increment, mirror and status protocol plugins are provided as examples.


@section lwswsplaplp Additional plugin search paths

Packages that have their own lws plugins can install them in their own
preferred dir and ask lwsws to scan there by using a config fragment
like this, in its own conf.d/ file managed by the other package
```
	{
	  "global": {
	   "plugin-dir": "/usr/local/share/coherent-timeline/plugins"
	  }
	}
```

@section lwswsssp lws-server-status plugin

One provided protocol can be used to monitor the server status.

Enable the protocol like this on a vhost's ws-protocols section
```
	       "lws-server-status": {
	         "status": "ok",
	         "update-ms": "5000"
	       }
```
"update-ms" is used to control how often updated JSON is sent on a ws link.

And map the provided HTML into the vhost in the mounts section
```
	       {
	        "mountpoint": "/server-status",
	        "origin": "file:///usr/local/share/libwebsockets-test-server/server-status",
	        "default": "server-status.html"
	       }
```
You might choose to put it on its own vhost which has "interface": "lo", so it's not
externally visible.


@section lwswssysd Lwsws Integration with Systemd

lwsws needs a service file like this as `/usr/lib/systemd/system/lwsws.service`
```
	[Unit]
	Description=Libwebsockets Web Server
	After=syslog.target
	
	[Service]
	ExecStart=/usr/local/bin/lwsws
	StandardError=null
	
	[Install]
	WantedBy=multi-user.target
```

You can find this prepared in `./lwsws/usr-lib-systemd-system-lwsws.service`


@section lwswslr Lwsws Integration with logrotate

For correct operation with logrotate, `/etc/logrotate.d/lwsws` (if that's
where we're putting the logs) should contain
```
	/var/log/lwsws/*log {
	    copytruncate
	    missingok
	    notifempty
	    delaycompress
	}
```
You can find this prepared in `/lwsws/etc-logrotate.d-lwsws`

Prepare the log directory like this

```
	sudo mkdir /var/log/lwsws
	sudo chmod 700 /var/log/lwsws
```
