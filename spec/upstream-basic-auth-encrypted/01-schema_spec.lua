local PLUGIN_NAME = "upstream-basic-auth-encrypted"


-- helper function to validate data against a schema
local validate do
  local validate_entity = require("spec.helpers").validate_plugin_config_schema
  local plugin_schema = require("kong.plugins."..PLUGIN_NAME..".schema")

  function validate(data)
    return validate_entity(data, plugin_schema)
  end
end


describe(PLUGIN_NAME .. ": (schema)", function()


  it("accepts values for both username and password", function()
    local ok, err = validate({
        username = "My-Username",
        password = "my-password",
      })
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

  it("does not double encrypt", function()
    local ok, err = validate({
        username = "My-Username",
        password = "SHA512,MmY3OWQwYWUtMzM2Zi00YjU3LWIyMjktNTY1YWYyNjQ3NWY0,8J9DClTO+6diOF/h97g/Sw==",
        encrypt_password = true
      })
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)


end)