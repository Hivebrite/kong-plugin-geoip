local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")

local plugin = require("kong.plugins.base_plugin"):extend()
local inspect = require 'inspect'
local geoip_module = require 'geoip'
local geoip_country = require 'geoip.country'
local geoip_country_filename = '/usr/share/GeoIP/GeoIP.dat'
local responses = require "kong.tools.responses"
local singletons = require "kong.singletons"


local current_ip = '212.120.189.11'

function plugin:new()
  plugin.super.new(self, plugin_name)
end

function plugin:access(plugin_conf)
  plugin.super.access(self)
end

function plugin:header_filter(plugin_conf)
  plugin.super.access(self)
  -- local current_ip = ngx.var.remote_addr;
  local country_code = geoip_country.open(geoip_country_filename):query_by_addr(current_ip).code

  for i,line in ipairs(plugin_conf.blacklist_countries) do
    if line == country_code then
      block = 1
    end
  end

  -- Unblocking ips in whitelist
  for i,line in ipairs(plugin_conf.whitelist_ips) do
    if line == current_ip then
      block = 0
    end
  end

  if block == 1 then 
    -- return ngx.exit(ngx.HTTP_ILLEGAL) 
    return responses.send_HTTP_FORBIDDEN()
  end
end

plugin.PRIORITY = 991

return plugin
