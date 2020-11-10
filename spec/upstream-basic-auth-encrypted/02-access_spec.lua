local helpers = require "spec.helpers"


local PLUGIN_NAME = "upstream-basic-auth-encrypted"


for _, strategy in helpers.each_strategy() do
  describe(PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
    local client

    lazy_setup(function()

      local bp = helpers.get_db_utils(strategy, nil, { PLUGIN_NAME })

      -- Inject a test route. No need to create a service, there is a default
      -- service which will echo the request.
      local route1 = bp.routes:insert({
        hosts = { "test1.com" },
      })
      -- add the plugin to test to the route we created
      bp.plugins:insert {
        name = PLUGIN_NAME,
        route = { id = route1.id },
        config = {
            username = "my-username",
            password = "my-password"
        },
      }

      local route2 = bp.routes:insert({
        hosts = { "test2.com" },
      })
      -- add the plugin to test to the route we created
      bp.plugins:insert {
        name = PLUGIN_NAME,
        route = { id = route2.id },
        config = {
            username = "my-username",
            password = "my-password",
            encrypt_password = true
        },
      }

      -- start kong
      assert(helpers.start_kong({
        -- set the strategy
        database   = strategy,
        -- use the custom test template to create a local mock server
        nginx_conf = "spec/fixtures/custom_nginx.template",
        -- make sure our plugin gets loaded
        plugins = "bundled," .. PLUGIN_NAME,
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
      it("gets a 'authorization' header with expected base64 encoded string", function()
        local r = client:get("/request", {
          headers = {
            host = "test1.com"
          }
        })
        -- validate that the request succeeded, response status 200
        assert.response(r).has.status(200)
        -- now check the request (as echoed by mockbin) to have the header
        local header_value = assert.request(r).has.header("authorization")
        -- validate the value of that header
        assert.equal("Basic bXktdXNlcm5hbWU6bXktcGFzc3dvcmQ=", header_value)
      end)
    end)

    describe("request", function()
        it("gets a 'authorization' header with expected base64 encoded string when password is encrypted", function()
          local r = client:get("/request", {
            headers = {
              host = "test1.com"
            }
          })
          -- validate that the request succeeded, response status 200
          assert.response(r).has.status(200)
          -- now check the request (as echoed by mockbin) to have the header
          local header_value = assert.request(r).has.header("authorization")
          -- validate the value of that header
          assert.equal("Basic bXktdXNlcm5hbWU6bXktcGFzc3dvcmQ=", header_value)
        end)
      end)



   -- describe("response", function()
   --   it("gets no authorization header on response", function()
   --     local r = client:get("/request", {
   --       headers = {
   --         host = "test1.com"
   --       }
   --     })
   --     -- validate that the request succeeded, response status 200
   --     assert.response(r).has.status(200)
   --     -- now check the response to have the header
   --     local header_value = assert.response(r).has.header("authorization")
   --     -- validate the value of that header
   --     assert.equal(nil, header_value)
   --   end)
   -- end)

  end)
end