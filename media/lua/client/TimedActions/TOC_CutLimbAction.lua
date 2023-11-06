require "TimedActions/ISBaseTimedAction"

local CutLimbAction = ISBaseTimedAction:derive("CutLimbAction")

function CutLimbAction:new(patient, surgeon, partName)
    print("CUTLIMBACTION")
end

return CutLimbAction