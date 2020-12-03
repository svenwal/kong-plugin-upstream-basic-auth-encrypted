local typedefs = require "kong.db.schema.typedefs"



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
    
    local aes = require "resty.aes"
    print "*******"
    print("Encrypted password two parameters")
    print(config.password)
    print(config.encrypt_password)
    print(bla)
    print("encryption on")

    local uuid = require "kong.tools.utils".uuid


    local salt = uuid()
    print("Salt " .. salt)
    local aes_512 = aes:new("AKeyForAES-256-CBC",
    "MySalt!!", aes.cipher(256,"cbc"), aes.hash.sha512, 5)
    local encrypted = aes_512:encrypt(config.password)
    config.password="SHA512," .. ngx.encode_base64(salt) .. "," .. ngx.encode_base64(encrypted)
    --print("Encrypted: " .. config.password)
    --local decrypted=aes_512:decrypt(ngx.decode_base64(config.password))
    --print("Decrypted: " .. decrypted)
    --print(config.password)
    --config.password=ngx.encode_base64(encrypted)
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