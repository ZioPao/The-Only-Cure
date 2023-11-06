require "TimedActions/ISBaseTimedAction"

local CutLimbAction = ISBaseTimedAction:derive("CutLimbAction")

function CutLimbAction:new(patient, surgeon, partName)

end
return CutLimbAction