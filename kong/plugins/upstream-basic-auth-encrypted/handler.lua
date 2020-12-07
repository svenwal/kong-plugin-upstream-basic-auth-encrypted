local plugin = {
    PRIORITY = 987,
    VERSION = "0.3.1",
  }

function plugin:init_worker()
  kong.log.debug("loading secret")
  local f = assert(io.open("/etc/kong/basic_auth_secret.txt", "rb"))
  local secret = f:read("*all")
  f:close()
  if secret == nil then
    kong.log.warn("Basic auth upstream plugin without a secret being specified in /etc/kong/basic_auth_secret.txt")
  end
  basic_auth_upstream_secret = secret
  kong.log.debug("Secure password: " .. basic_auth_upstream_secret)
end

function plugin:access(plugin_conf)
    local aes = require "resty.aes"
    kong.log("Secret" .. basic_auth_upstream_secret)
    local username = plugin_conf.username
    local password = plugin_conf.password or ''
    kong.log("********************** password: " .. password)
    
    if plugin_conf.encrypt_password == true then
      if basic_auth_upstream_secret == nil then
        kong.log.err("No decryption secret available")
      end
      kong.log("********************** About to decrypt: " .. password)
      local ngx_re = require "ngx.re"
      local splitted, err = ngx_re.split(password,",")
      if err then
        kong.log.err("Encoded password and salt invalid format")
      end
      kong.log("First " .. splitted[1])
      local salt = splitted[2];
      local encoded_password = splitted[3];
      salt = ngx.decode_base64(salt)
      kong.log("Decrypting Salt: " .. salt)
      print(#salt)
      kong.log("Decoded salt: " .. ngx.decode_base64(salt))
      kong.log("Encoded password: " .. encoded_password)
      local aes_256_cbc_sha512x5 = assert(aes:new("AKeyForAES-256-CBC",
      salt, aes.cipher(256,"cbc"), aes.hash.sha512, 5))
      password=aes_256_cbc_sha512x5:decrypt(ngx.decode_base64(encoded_password))
      if password == nil then
        kong.log.err("Password decryption failed")
      end
    end

    local auth_string = username .. ':' .. password;


    local auth_string_base64 = ngx.encode_base64(auth_string);
    local auth_header = "Basic " .. auth_string_base64;
    kong.service.request.set_header("Authorization", auth_header)

  
end
  
  
function plugin:header_filter(plugin_conf)
  
  -- maybe remove the authorization header?
  
end

return plugin