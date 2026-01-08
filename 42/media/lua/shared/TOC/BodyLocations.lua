--Based on RabenRabo's bodylocation solution from their mod "Fantasy Bodyparts" and "Fantasy Legs" sub-mod.
--Modified by GanydeBielovzki with permission for batch use for the Frockin' Splendor franchise and spin-offs.
--To copy, further modify or otherwise use this code the original creator and the modifier must be credited.

local function copyBodyLocationProperties(oldGroup, oldLocID, newGroup)
	for k = 0, oldGroup:size()-1 do
		local otherLocID = oldGroup:getLocationByIndex(k):getId()
		if oldGroup:isExclusive(oldLocID, otherLocID)
		then
			newGroup:setExclusive(oldLocID, otherLocID)
		end
		if oldGroup:isHideModel(oldLocID, otherLocID)
		then
			newGroup:setHideModel(oldLocID, otherLocID)
		end
		if oldGroup:isAltModel(oldLocID, otherLocID)
		then
			newGroup:setAltModel(oldLocID, otherLocID)
		end
	end
end

local function addBodyLocationsAt(groupName, locationList)
	local results = {}

	-- get list (!!actually a view!!) of all groups and copy to array (BodyLocations.reset() will also clear the view)
	local allGroupsList = BodyLocations.getAllGroups()
	local allGroups = {}
	for i = 0, allGroupsList:size()-1 do
		allGroups[i + 1] = allGroupsList:get(i)
	end

	BodyLocations.reset()

	-- recreate all groups/bodylocations and insert new bodylocations
	for i = 1, #allGroups do
		local oldGroup = allGroups[i]
		local newGroup = BodyLocations.getGroup(oldGroup:getId())

		-- FIRST: Process all original locations AND insert new ones at correct positions
		for j = 0, oldGroup:size()-1 do
			local oldLoc = oldGroup:getLocationByIndex(j)
			local oldLocID = oldLoc:getId()

			-- For each location definition, check if it should be inserted here
			for _, locDef in ipairs(locationList) do
				if oldGroup:getId() == groupName then
					local newLocID = type(locDef.name) ~= "string" and locDef.name or 
								   ItemBodyLocation.get(ResourceLocation.of(locDef.name))

					local refLocID = type(locDef.reference) ~= "string" and locDef.reference or 
								   ResourceLocation.of(locDef.reference)

					local isTargetGroupAndLoc = refLocID == oldLocID

					if isTargetGroupAndLoc and locDef.before then
						results[locDef.name] = newGroup:getOrCreateLocation(newLocID)
					end
				end
			end

			-- Add the original location
			newGroup:getOrCreateLocation(oldLocID)

			-- Check for "after" insertions
			for _, locDef in ipairs(locationList) do
				if oldGroup:getId() == groupName then
					local newLocID = type(locDef.name) ~= "string" and locDef.name or 
								   ItemBodyLocation.get(ResourceLocation.of(locDef.name))

					local refLocID = type(locDef.reference) ~= "string" and locDef.reference or 
								   ResourceLocation.of(locDef.reference)

					local isTargetGroupAndLoc = refLocID == oldLocID

					if isTargetGroupAndLoc and not locDef.before then
						results[locDef.name] = newGroup:getOrCreateLocation(newLocID)
					end
				end
			end
		end

		-- SECOND: copy bodylocation properties from old groups to new groups
		for j = 0, oldGroup:size()-1 do
			local oldLocID = oldGroup:getLocationByIndex(j):getId()
			newGroup:setMultiItem(oldLocID, oldGroup:isMultiItem(oldLocID))
			copyBodyLocationProperties(oldGroup, oldLocID, newGroup)
		end
	end

	return results
end

local results = addBodyLocationsAt("Human", {
    {name = "toc:Arm_L", reference = ItemBodyLocation.FULL_TOP, before = false},
    {name = "toc:Arm_R", reference = ItemBodyLocation.FULL_TOP, before = false},
    {name = "toc:ArmProst_L", reference = ItemBodyLocation.FULL_TOP, before = false},
    {name = "toc:ArmProst_R", reference = ItemBodyLocation.FULL_TOP, before = false},
    {name = "toc:ArmAccessory_L", reference = ItemBodyLocation.FULL_TOP, before = false},
    {name = "toc:ArmAccessory_R", reference = ItemBodyLocation.FULL_TOP, before = false},
})


results['toc:Arm_L']:setMultiItem(true)
results['toc:Arm_R']:setMultiItem(true)
results['toc:ArmProst_L']:setMultiItem(true)
results['toc:ArmProst_R']:setMultiItem(true)
results['toc:ArmAccessory_L']:setMultiItem(true)
results['toc:ArmAccessory_R']:setMultiItem(true)
