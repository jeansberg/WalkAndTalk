luaunit = require("testing.luaunit")
require ("testing.animation_tests")
require ("testing.collisions_tests")

os.exit( luaunit.LuaUnit.run() )