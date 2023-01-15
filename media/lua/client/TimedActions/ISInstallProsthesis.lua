require "TimedActions/ISBaseTimedAction"

ISInstallProsthesis = ISBaseTimedAction:derive("ISInstallProsthesis");

function ISInstallProsthesis:isValid()
    return true
end

function ISInstallProsthesis:update()
    self.item:setJobDelta(self:getJobDelta())
end

function ISInstallProsthesis:start()
    self.item:setJobType("Install prosthesis")
    self.item:setJobDelta(0.0)
    self:setActionAnim("WearClothing")
    self:setAnimVariable("WearClothingLocation", "Jacket")
end

function ISInstallProsthesis:stop()
    ISBaseTimedAction.stop(self)
    self.item:setJobDelta(0.0)
end

function ISInstallProsthesis:perform()
    self.item:setJobDelta(0.0)

    local modData = self.character:getModData() 
    --local toc_data = self.character:getModData().TOC
    local lor = 0       -- LEFT OR RIGHT
    local foh = 0       -- FOREARM OR HAND

    
    -- Check if can be performed. This shouldn't be necessary, but just to be sure
    if self.bodyPart:getType() == BodyPartType.UpperArm_L or self.bodyPart:getType() == BodyPartType.UpperArm_R then
        print("Can't equip prosthesis")
        return
    end


    local prosthesis_table = {
        WoodenHook = {
            material_id = 1
        },
        MetalHook = {
            material_id = 2
        },
        MetalHand = {
            material_id = 3
        }
    }


    -- print(self.item)


    -- TODO there is something wrong with how I'm managing prosthesis. they don't apply
    -- TODO cheatMenu are fucked up, admin access is wrong

    -- TODO make a parser or something I dont care
    -- Check Item before doing any of this shit maybe
    -- Assemble the correct name for the object
    --local prosthesis_name = self.item:getname() .. "_" .. Right .. "_" .. Forearm
    -- for _, v in ipairs(GetLimbsBodyPartTypes()) do
    --     if v ~= BodyPartType.UpperArm_L or v ~= BodyPartType.UpperArm_R then
        
    --         if self.bodyPart:getType() == v then
    --             --local item_name = "TOC."
    --             --local weight = math.floor(self.item:getWeight() * 10 + 0.5) / 10        
    
    
    -- TODO why do we need this?

    --         end

    --     end
    -- end



    if     self.bodyPart:getType() == BodyPartType.Hand_R then lor = 1; foh = 1
    elseif self.bodyPart:getType() == BodyPartType.ForeArm_R then lor = 1; foh = 2
    elseif self.bodyPart:getType() == BodyPartType.Hand_L then lor = 0; foh = 1
    elseif self.bodyPart:getType() == BodyPartType.ForeArm_L then lor = 0; foh = 2
    end

    local mat_id = 0
    local weight = math.floor(self.item:getWeight() * 10 + 0.5) / 10

    if weight == 1 and foh == 1 then
        if lor == 1 then
            self.cloth = self.character:getInventory():AddItem("TOC.WoodenHook_right_noHand");
            mat_id = 1;
        else
            self.cloth = self.character:getInventory():AddItem("TOC.WoodenHook_left_noHand");
            mat_id = 1;
        end
    elseif weight == 0.5 and foh == 1 then
        if lor == 1 then
            self.cloth = self.character:getInventory():AddItem("TOC.MetalHook_right_noHand");
            mat_id = 2;
        else
            self.cloth = self.character:getInventory():AddItem("TOC.MetalHook_left_noHand");
            mat_id = 2;
        end
    elseif weight == 0.3 and foh == 1 then
        if lor == 1 then
            self.cloth = self.character:getInventory():AddItem("TOC.MetalHand_right_noHand");
            mat_id = 3;
        else
            self.cloth = self.character:getInventory():AddItem("TOC.MetalHand_left_noHand");
            mat_id = 3;
        end
    elseif weight == 1 and foh == 2 then
        if lor == 1 then
            self.cloth = self.character:getInventory():AddItem("TOC.WoodenHook_right_noForearm");
            mat_id = 1;
        else
            self.cloth = self.character:getInventory():AddItem("TOC.WoodenHook_left_noForearm");
            mat_id = 1;
        end
    elseif weight == 0.5 and foh == 2  then
        if lor == 1 then
            self.cloth = self.character:getInventory():AddItem("TOC.MetalHook_right_noForearm");
            mat_id = 2;
        else
            self.cloth = self.character:getInventory():AddItem("TOC.MetalHook_left_noForearm");
            mat_id = 2;
        end
    elseif weight == 0.3 and foh == 2 then
        if lor == 1 then
            self.cloth = self.character:getInventory():AddItem("TOC.MetalHand_right_noForearm");
            mat_id = 3;
        else
            self.cloth = self.character:getInventory():AddItem("TOC.MetalHand_left_noForearm");
            mat_id = 3;
        end
    end

    if self.cloth ~= nil then
        if self.bodyPart:getType() == BodyPartType.Hand_R then
            modData.TOC.RightHand.is_prosthesis_equipped = true;
            modData.TOC.RightHand.prosthesis_factor = find_protheseFact_TOC(self.cloth);
        elseif self.bodyPart:getType() == BodyPartType.ForeArm_R then
            modData.TOC.RightForearm.is_prosthesis_equipped = true;
            modData.TOC.RightForearm.prosthesis_factor = find_protheseFact_TOC(self.cloth);
        elseif self.bodyPart:getType() == BodyPartType.Hand_L then
            modData.TOC.LeftHand.is_prosthesis_equipped = true;
            modData.TOC.LeftHand.prosthesis_factor = find_protheseFact_TOC(self.cloth);
        elseif self.bodyPart:getType() == BodyPartType.ForeArm_L then
            modData.TOC.LeftForearm.is_prosthesis_equipped = true;
            modData.TOC.LeftForearm.prosthesis_factor = find_protheseFact_TOC(self.cloth);
        end

        self.character:getInventory():Remove(self.item);
        self.character:setWornItem(self.cloth:getBodyLocation(), self.cloth);
    end

    self.character:transmitModData()

    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self)
end

function ISInstallProsthesis:new(character, item, bodyPart)
    local o = ISBaseTimedAction.new(self, character)
    o.item = item
    o.bodyPart = bodyPart
    o.maxTime = 100
    o.stopOnWalk = true
    o.stopOnRun = true
    o.cloth = nil
    o.ignoreHandsWounds = false
    o.fromHotbar = true -- just to disable hotbar:update() during the wearing
    if o.character:isTimedActionInstant() then o.maxTime = 1 end
    return o
end
