-- Tiny dependency-free test runner.
--
--   local t = require("harness.testkit")
--   t.describe("CommonMethods", function()
--       t.it("GetSide returns L", function()
--           t.assertEquals("L", CommonMethods.GetSide("Hand_L"))
--       end)
--   end)
--   os.exit(t.run())
--
-- Assertions raise on failure; the runner isolates each test with pcall and
-- reports a TAP-like summary. `t.run()` returns 0 when everything passed.

local kit = {}

local suites = {}
local currentSuite = nil

local totalPassed = 0
local totalFailed = 0
local failures = {}

function kit.describe(name, fn)
    currentSuite = { name = name, tests = {} }
    table.insert(suites, currentSuite)
    fn()
    currentSuite = nil
end

function kit.it(name, fn)
    assert(currentSuite, "it() called outside describe()")
    table.insert(currentSuite.tests, { name = name, fn = fn })
end

-- For async/integration specs that are not yet enabled in this runner.
function kit.pending(name)
    if currentSuite then
        table.insert(currentSuite.tests, { name = name, fn = nil, pending = true })
    end
end

local function fail(msg, level)
    error({ message = msg, level = level or 3 }, 0)
end

function kit.assertTrue(v, msg)
    if v ~= true then fail((msg or "expected true") .. ", got " .. tostring(v)) end
end

function kit.assertFalse(v, msg)
    if v ~= false then fail((msg or "expected false") .. ", got " .. tostring(v)) end
end

function kit.assertEquals(expected, actual, msg)
    if expected ~= actual then
        fail((msg and (msg .. ": ") or "") .. "expected " .. tostring(expected)
            .. ", got " .. tostring(actual))
    end
end

function kit.assertNil(v, msg)
    if v ~= nil then fail((msg or "expected nil") .. ", got " .. tostring(v)) end
end

function kit.assertNotNil(v, msg)
    if v == nil then fail(msg or "expected non-nil") end
end

local function assertType(expected, v, msg)
    if type(v) ~= expected then
        fail((msg and (msg .. ": ") or "") .. "expected " .. expected
            .. ", got " .. type(v))
    end
end

function kit.assertTable(v, msg) assertType("table", v, msg) end
function kit.assertNumber(v, msg) assertType("number", v, msg) end
function kit.assertString(v, msg) assertType("string", v, msg) end
function kit.assertBoolean(v, msg) assertType("boolean", v, msg) end

function kit.fail(msg)
    fail(msg, 4)
end

local function runTest(suiteName, test)
    if test.pending then
        print(string.format("  ok    %s > %s (pending)", suiteName, test.name))
        return true
    end

    local ok, err = pcall(test.fn)
    if ok then
        totalPassed = totalPassed + 1
        print(string.format("  ok    %s > %s", suiteName, test.name))
        return true
    else
        totalFailed = totalFailed + 1
        local msg = type(err) == "table" and err.message or tostring(err)
        table.insert(failures, string.format("%s > %s\n      %s", suiteName, test.name, msg))
        print(string.format("  FAIL  %s > %s", suiteName, test.name))
        print("      " .. msg)
        return false
    end
end

function kit.run()
    print("TOC unit tests")
    print("==================================================")
    for _, suite in ipairs(suites) do
        print("\n# " .. suite.name)
        for _, test in ipairs(suite.tests) do
            runTest(suite.name, test)
        end
    end

    print("\n==================================================")
    print(string.format("Passed: %d  Failed: %d", totalPassed, totalFailed))

    if totalFailed > 0 then
        print("\nFailures:")
        for _, f in ipairs(failures) do
            print("  - " .. f)
        end
        return 1
    end
    return 0
end

return kit
