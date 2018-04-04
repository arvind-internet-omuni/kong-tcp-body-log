local tcp_body_log_serializer = require "kong.plugins.log-serializers.runscope"
local BasePlugin = require "kong.plugins.base_plugin"
local log = require "kong.plugins.tcp-body-log.log"
local public_utils = require "kong.tools.public"

local string_find = string.find
local req_read_body = ngx.req.read_body
local req_get_headers = ngx.req.get_headers
local req_get_body_data = ngx.req.get_body_data

local TCPBodyLogHandler = BasePlugin:extend()

function TCPBodyLogHandler:new()
  TCPBodyLogHandler.super.new(self, "tcp-body-log")
end

function TCPBodyLogHandler:access(conf)
  TCPBodyLogHandler.super.access(self)

  local req_body, res_body = "", ""
  local req_post_args = {}

  req_read_body()
  req_body = req_get_body_data()

  local headers = req_get_headers()
  local content_type = headers["content-type"]
  if content_type and string_find(content_type:lower(), "application/x-www-form-urlencoded", nil, true) then
    req_post_args = public_utils.get_body_args()
  end

  -- keep in memory the bodies for this request
  ngx.ctx.runscope = {
    req_body = req_body,
    res_body = res_body,
    req_post_args = req_post_args
  }
end

function TCPBodyLogHandler:body_filter(conf)
 TCPBodyLogHandler.super.body_filter(self)

 local chunk = ngx.arg[1]
 local runscope_data = ngx.ctx.runscope or {res_body = ""} -- minimize the number of calls to ngx.ctx while fallbacking on default value
 runscope_data.res_body = runscope_data.res_body..chunk
 ngx.ctx.runscope = runscope_data

end

function TCPBodyLogHandler:log(conf)
  TCPBodyLogHandler.super.log(self)

  -- Call serializer (using runscope's serializer initialized above)
  local message = tcp_body_log_serializer.serialize(ngx)
  -- Call execute method of 'log' initialized earlier
  log.execute(conf, message)
end

TCPBodyLogHandler.PRIORITY = 1

return TCPBodyLogHandler
