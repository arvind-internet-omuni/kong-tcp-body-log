# kong-tcp-body-log
Log request and response data along with body to a TCP server. This plugin provides an extension to Kong's TCP Log plugin which logs everything but the request and response body. This plugin logs the request and response body along with other information which TCP log plugin writes. 

# How to install

1. Create a directory with name "tcp-body-log" in Kong's plugin directory. e.g. /usr/local/share/lua/5.1/kong/plugins/tcp-body-log
2. Copy the lua files into tcp-body-log directory -> handler.lua, log.lua, schema.lua
3. Load tcp-body-log plugin into Kong. You need to add this into kong config file. configure: custom_plugins=tcp-body-log. See this link if you need help - https://getkong.org/docs/0.10.x/plugin-development/distribution/#load-the-plugin
4. Restart Kong. (kong reload would suffice)
5. Plugin is installed, we now need to enable the tcp-body-log plugin in kong:
 curl -X POST http://localhost:8001/plugins/ --data "name=tcp-body-log" --data "config.host=127.0.0.1" --data "config.port=9563"
 Host and port are TCP server host and port number.

 
 
