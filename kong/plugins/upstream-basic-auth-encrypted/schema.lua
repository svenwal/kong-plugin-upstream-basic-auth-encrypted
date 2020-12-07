local typedefs = require "kong.db.schema.typedefs"

kong.log.debug("loading secret")
local f = assert(io.open("/etc/kong/basic_auth_secret.txt", "rb"))
local secret = f:read("*all")
f:close()
if secret == nil then
  kong.log.warn("Basic auth upstream plugin without a secret being specified in /etc/kong/basic_auth_secret.txt")
end
basic_auth_upstream_secret = secret
kong.log.debug("Secure password: " .. basic_auth_upstream_secret)

-- Grab pluginname from module name
local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")


local function encrypt_password(config, bla)
  kong.log("********************** In encrypt function")
  if config.encrypt_password == true then
    print("Start encrypt function" .. config.password)
    if config.password:sub(1, 7) == "SHA512," then
      print("Already encrypted, not touching it")
      return true
    end

    if basic_auth_upstream_secret == nil then
      print("!!! No Encryption secret available")
      kong.log.err("No Encryption secret available")
    end

    --kong.log("Secret " .. basic_auth_upstream_secret)
    
    local aes = require "resty.aes"
    print "*******"
    print(config.password)
    print(config.encrypt_password)
    print(bla)
    print("encryption on")

    local uuid = require "kong.tools.utils".uuid


    local salt = uuid()
    
    eight_chars_salt = salt:sub(1, 8)
    print("Salt " .. eight_chars_salt)
    print(#eight_chars_salt)
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
            default = false       
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