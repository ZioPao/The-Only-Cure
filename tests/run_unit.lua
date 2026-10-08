-- Unit-test entry point. Run from the repo root:
--   luajit tests/run_unit.lua
--
-- Loads the PZ mock harness, all specs, then exits non-zero on failure.

package.path = "tests/?.lua;tests/?/init.lua;" .. package.path

local t = require("harness.testkit")

require("unit.common_methods_spec")
require("unit.static_data_spec")
require("unit.data_controller_spec")
require("unit.cached_data_handler_spec")
require("unit.tourniquet_spec")
require("unit.local_player_controller_spec")
require("unit.local_player_controller_poll_spec")
require("unit.prosthesis_handler_spec")
require("unit.exp_actions_spec")
require("unit.items_controller_spec")
require("unit.commands_data_spec")
require("unit.data_lifecycle_spec")
require("unit.ignored_actions_spec")
require("unit.equip_amputation_spec")

os.exit(t.run())
