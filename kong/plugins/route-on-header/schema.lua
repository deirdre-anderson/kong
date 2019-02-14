local typedefs = require "kong.db.schema.typedefs"

local colon_strings_array = {
  type = "array",
  required = true,
  elements = { type = "string", match = "^[^:]+:.*$" },
}

return {
  name = "myplugin",
  fields = {
    { run_on = typedefs.run_on_first },
    { config = {
        type = "record",
        fields = {
          { upstream = { type = "string", required = true },},
          { headers  = colon_strings_array },
        }
      },
    },
  }
}