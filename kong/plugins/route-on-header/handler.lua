local kong = kong
local ngx = ngx
local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")

-- load the base plugin object and create a subclass
local plugin = require("kong.plugins.base_plugin"):extend()

-- constructor
function plugin:new()
  plugin.super.new(self, plugin_name)
end

---[[ runs in the 'access_by_lua_block'
function plugin:access(plugin_conf)
  plugin.super.access(self)


  local valid = true
  if plugin_conf.headers and #plugin_conf.headers > 0 then

    local headers = table.concat(plugin_conf.headers, ",") 
    headers = headers:gsub("%s+", "")

    for pair in string.gmatch(headers, '([^,]+)') do
      local name, value = pair:match("^([^:]+):*(.-)$")
      if kong.request.get_header(name) == nil or kong.request.get_header(name) ~= value then
        valid = false
      end
    end
  end

  if valid then
    ngx.ctx.balancer_address.host = plugin_conf.upstream
  end
  end

-- set the plugin priority, which determines plugin execution order
plugin.PRIORITY = 1000

-- return our plugin object
return plugin
