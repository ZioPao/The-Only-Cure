local ModDataHandler = require("TOC/Handlers/ModDataHandler")

---@class SurgeryHandler
---@field type string
local SurgeryHandler = {}

function SurgeryHandler:new(type)
    local o = {}
    setmetatable(o, self)
    self.__index = self


    -- TODO use getjob for this
    o.type = type

    return o
end


function SurgeryHandler:execute()
    if self.type == "needle" then
        -- TODO 
    end
end


-- Cauterize


-- Needle and stitching (scrap surgery kits and crap like that)




return SurgeryHandler