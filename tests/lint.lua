-- Static checks for The Only Cure Lua sources.
--
-- Two zero-dependency checks (works with luajit / lua5.1):
--   1. Syntax-check every file passed on stdin (one path per line).
--   2. Verify that every `require("TOC/...")` resolves to a real file in
--      media/lua/{shared,client,server}.
--
-- Usage: find ... -name '*.lua' | luajit tests/lint.lua
--
-- Exits non-zero if any problem is found.

local ROOTS = {
    "42/media/lua/shared/",
    "42/media/lua/client/",
    "42/media/lua/server/",
    "common/media/lua/shared/",
    "common/media/lua/client/",
    "common/media/lua/server/",
}

local function fileExists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

---@param target string e.g. "TOC/CommonMethods"
---@return boolean
local function resolves(target)
    for _, root in ipairs(ROOTS) do
        if fileExists(root .. target .. ".lua") or fileExists(root .. target .. "/init.lua") then
            return true
        end
    end
    return false
end

local syntaxErrors = {}
local missingRequires = {}
local checked = 0

for line in io.lines() do
    local path = line:gsub("%s+$", "")
    if path ~= "" then
        checked = checked + 1

        local chunk, err = loadfile(path)
        if not chunk then
            table.insert(syntaxErrors, err)
        else
            -- Scan raw source for static TOC requires.
            local f = io.open(path, "r")
            if f then
                local src = f:read("*a")
                f:close()
                for target in src:gmatch('require%s*%(?%s*"([^"]+)"') do
                    if target:sub(1, 4) == "TOC/" and not resolves(target) then
                        table.insert(missingRequires, path .. " requires unresolved \"" .. target .. "\"")
                    end
                end
            end
        end
    end
end

local failed = false

if #syntaxErrors > 0 then
    failed = true
    io.stderr:write("Syntax errors:\n")
    for _, e in ipairs(syntaxErrors) do
        io.stderr:write("  " .. e .. "\n")
    end
end

if #missingRequires > 0 then
    failed = true
    io.stderr:write("Unresolved requires:\n")
    for _, e in ipairs(missingRequires) do
        io.stderr:write("  " .. e .. "\n")
    end
end

print(string.format("lint: checked %d files, %d syntax error(s), %d unresolved require(s)",
    checked, #syntaxErrors, #missingRequires))

os.exit(failed and 1 or 0)
