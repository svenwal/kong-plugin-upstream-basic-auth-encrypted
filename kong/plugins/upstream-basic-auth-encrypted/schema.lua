local typedefs = require "kong.db.schema.typedefs"

kong.log.debug("loading secret")
local f = assert(io.open("/etc/kong/basic_auth_secret.txt", "rb"))
local secret = f:read("*all")
f:close()
if secret == nil then
  kong.log.warn("Basic auth upstream plugin without a secret being specified in /etc/kong/basic_auth_secret.txt")
end
basic_auth_upstream_secret = secret

-- Grab pluginname from module name
local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")


local function encrypt_password(config, bla)
  if config.encrypt_password == true then
    if config.password:sub(1, 7) == "SHA512," then
      kong.log.debug("Password already encrypted, not touching it")
      return true
    end

    if basic_auth_upstream_secret == nil then
      kong.log.err("No Encryption secret available")
    end
    
    local aes = require "resty.aes"
    local uuid = require "kong.tools.utils".uuid
    local salt = uuid()
    local eight_chars_salt = salt:sub(1, 8)
    local aes_256_cbc_sha512x5 = assert(aes:new(basic_auth_upstream_secret,
    eight_chars_salt, aes.cipher(256,"cbc"), aes.hash.sha512, 5))
    local encrypted = aes_256_cbc_sha512x5:encrypt(config.password)
    config.password="SHA512," .. ngx.encode_base64(eight_chars_salt) .. "," .. ngx.encode_base64(encrypted)
  end
  return true, nil, {password = "test"}
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
              required = false
            }
          },

          { encrypt_password = {
            type = "boolean",
            default = true       
            }
          }
        },
        entity_checks = {
        },
        custom_validator = encrypt_password
      },
    },
  },
}

return schema