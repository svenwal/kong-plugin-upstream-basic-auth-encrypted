local plugin = {
    PRIORITY = 987,
    VERSION = "0.2",
  }

function plugin:access(plugin_conf)
    local aes = require "resty.aes"
    
    local username = plugin_conf.username
    local password = plugin_conf.password or ''
    kong.log("********************** password: " .. password)
    
    if plugin_conf.encrypt_password == true then
      kong.log("********************** About to decrypt: " .. password)
      local aes_256_cbc_sha512x5 = aes:new("AKeyForAES-256-CBC",
        "MySalt!!", aes.cipher(256,"cbc"), aes.hash.sha512, 5)
        password=aes_256_cbc_sha512x5:decrypt(ngx.decode_base64(plugin_conf.password))
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