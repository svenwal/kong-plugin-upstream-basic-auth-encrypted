local typedefs = require "kong.db.schema.typedefs"
local aes = require "resty.aes"

-- Grab pluginname from module name
local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")

local function encrypt_password(given_config)
  if given_config.encrypt_password == true then
    given_config.password="SHA512." .. given_config.password
  end
  return true
end 

local schema = {
  name = plugin_name,
  fields = {
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { username = {
              type = "string",
              required = true
            }
          },
          
          { password = {
              type = "string",
              required = false,
              custom_validator = encrypt_password
            }
          },

          { encrypt_password = {
            type = "boolean",
            default = false       
            }
          }
        },
        entity_checks = {
        },
      },
    },
  },
}

return schema