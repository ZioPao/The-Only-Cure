-- instead of relying on local to save og methods, we save them in a table here that we can use later.

---@class OverridenMethodsArchive
local OverridenMethodsArchive = {}
OverridenMethodsArchive.methods = {}

-- Save an original method, if it wasn't already saved and returns it to be used in common
function OverridenMethodsArchive.Save(methodName, method)
    if not OverridenMethodsArchive.methods[methodName] then
        OverridenMethodsArchive.methods[methodName] = method
        TOC_DEBUG.print("Saved method " .. methodName)
    end


    return method

end

-- Get the original method
function OverridenMethodsArchive.Get(methodName)
    --TOC_DEBUG.print("Getting og method " .. methodName)

    --TOC_DEBUG.print("OverridenMethodsArchive.list[methodName] = " .. tostring(OverridenMethodsArchive.methods[methodName]))
    --TOC_DEBUG.print(methodName)
    --TOC_DEBUG.print(OverridenMethodsArchive.methods[methodName])
    return OverridenMethodsArchive.methods[methodName]

end


return OverridenMethodsArchive
