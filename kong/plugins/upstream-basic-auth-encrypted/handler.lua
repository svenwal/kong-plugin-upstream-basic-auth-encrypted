local plugin = {
    PRIORITY = 987,
    VERSION = "0.1",
  }

function plugin:access(plugin_conf)
    local username = plugin_conf.username
    local password = plugin_conf.password or ''
    
    local auth_string = username .. ':' .. password;
    local auth_string_base64 = ngx.encode_base64(auth_string);
    local auth_header = "Basic " .. auth_string_base64;
    kong.service.request.set_header("Authorization", auth_header)

  
end
  
  
function plugin:header_filter(plugin_conf)
  
  -- maybe remove the authorization header?
  
end

return plugin