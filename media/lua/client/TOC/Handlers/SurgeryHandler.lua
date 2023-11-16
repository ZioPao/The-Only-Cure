local ModDataHandler = require("TOC/Handlers/ModDataHandler")

---@class SurgeryHandler
---@field type string
---@field limbName string
local SurgeryHandler = {}

function SurgeryHandler:new(type, limbName)
    local o = {}
    setmetatable(o, self)
    self.__index = self


    -- TODO use getjob for this
    o.type = type
    o.limbName = limbName

    return o
end


-- TODO Should we consider stitching as "operating?"

function SurgeryHandler:execute()
    if self.type == "needle" then
        -- TODO 
    end


    if self.type == "oven" then
        ModDataHandler.GetInstance():setIsCauterized(self.limbName, true)
    end
end


-- Cauterize


-- Needle and stitching (scrap surgery kits and crap like that)




return SurgeryHandler