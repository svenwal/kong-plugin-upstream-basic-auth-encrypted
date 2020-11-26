local typedefs = require "kong.db.schema.typedefs"
local aes = require "resty.aes"

-- Grab pluginname from module name
local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")


local function encrypt_password(config, bla)
  kong.log("********************** In encrypt function")
  if config.encrypt_password == true then
    print "*******"
    print("Encrypted password two parameters")
    print(config.password)
    print(config.encrypt_password)
    print(bla)
    print("encryption on")
    local aes_256_cbc_sha512x5 = aes:new("AKeyForAES-256-CBC",
        "MySalt!!", aes.cipher(256,"cbc"), aes.hash.sha512, 5)
        -- AES 256 CBC with 5 rounds of SHA-512 for the key
        -- and a salt of "MySalt!!"
        -- Note: salt can be either nil or exactly 8 characters long
    local encrypted = aes_256_cbc_sha512x5:encrypt(config.password)
    config.password=ngx.encode_base64(encrypted)
    print("Encrypted: " .. config.password)
    local decrypted=aes_256_cbc_sha512x5:decrypt(ngx.decode_base64(config.password))
    print("Decrypted: " .. decrypted)
    print(config.password)
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