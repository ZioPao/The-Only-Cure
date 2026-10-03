-- Unit-test entry point. Run from the repo root:
--   luajit dev_stuff/tests/run_unit.lua
--
-- Loads the PZ mock harness, all specs, then exits non-zero on failure.

package.path = "dev_stuff/tests/?.lua;dev_stuff/tests/?/init.lua;" .. package.path

local t = require("harness.testkit")

require("spec.common_methods_spec")
require("spec.static_data_spec")
require("spec.data_controller_spec")
require("spec.cached_data_handler_spec")
require("spec.tourniquet_spec")
require("spec.local_player_controller_spec")

os.exit(t.run())
