local helpers = require "spec.helpers"
local version = require("version").version


local PLUGIN_NAME = "route-on-header"
local KONG_VERSION = version(select(3, assert(helpers.kong_exec("version"))))


for _, strategy in helpers.each_strategy() do
  describe(PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
    local client
    local upstream_host = helpers.mock_upstream_host .. ':' .. helpers.mock_upstream_port

    lazy_setup(function()
      local bp, route1
      local bp = helpers.get_db_utils(strategy, nil, { PLUGIN_NAME })

      local route1 = bp.routes:insert({
        hosts = { "test1.com" },
      })

      local route2 = bp.routes:insert({
        hosts = { "test2.com" },
      })

      bp.plugins:insert {
        name = PLUGIN_NAME,
        route = { id = route1.id },
        config = {
          upstream = "0.0.0.0",
          headers = {"x-header1:value1","x-header2:value2","x-header3:value3"}
        },
      }

      bp.plugins:insert {
        name = PLUGIN_NAME,
        route = { id = route2.id },
        config = {
          upstream = "should.not.be.hit",
          headers = {"x-header1:value1","x-header2:value2","x-header3:value3"}
        },
      }

      -- start kong
      assert(helpers.start_kong({
        -- set the strategy
        database   = strategy,
        -- use the custom test template to create a local mock server
        nginx_conf = "spec/fixtures/custom_nginx.template",
        -- set the config item to make sure our plugin gets loaded
        plugins = "bundled," .. PLUGIN_NAME,  -- since Kong CE 0.14
        custom_plugins = PLUGIN_NAME,         -- pre Kong CE 0.14
      }))
    end)

    lazy_teardown(function()
      helpers.stop_kong(nil, true)
    end)

    before_each(function()
      client = helpers.proxy_client()
    end)

    after_each(function()
      if client then client:close() end
    end)

    describe("request", function()
      it("Header values are present and valid", function()
        local r = assert(client:send {
          method = "GET",
          path = "/get", 
          headers = {
            ["Content-Type"] = "application/json",
            host = "test1.com",
            ["x-header1"]= "value1",
            ["x-header2"]= "value2",
            ["x-header3"]= "value3"
          }
        })

        assert.response(r).has.status(200)
        local json = assert.response(r).has.jsonbody()
        local value = assert.has.header("host", json)
        assert.are_not.equals(upstream_host, value)


      end)
      it("Header values not valid", function()
        local r = assert(client:send {
          method = "GET",
          path = "/get",  
          headers = {
            ["Content-Type"] = "application/json",
            host = "test2.com",
          }
        })

        assert.response(r).has.status(200)
        local json = assert.response(r).has.jsonbody()
        local value = assert.has.header("host", json)
        assert.equals(upstream_host, value)

      end)
    end)

  

  end)
end
