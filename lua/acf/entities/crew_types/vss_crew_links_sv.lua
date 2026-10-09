local ACF           = ACF
local Classes       = ACF.Classes
local IsEntityValid = ACF.Optimizations.IsEntityValid

local function UpdateOxygenTankLink(Crew, Tank)
	if IsEntityValid(Tank) and Tank.RefreshOxygenTank and not Tank:IsMarkedForDeletion() then
		Tank:RefreshOxygenTank()
	end

	if IsEntityValid(Tank) and Tank.UpdateOxygenOutputs then
		Tank:UpdateOxygenOutputs()
	end

	if IsEntityValid(Tank) and Tank.UpdateOverlay then
		Tank:UpdateOverlay()
	end

	if Crew.UpdateOxygenTankGForceBonus then
		Crew:UpdateOxygenTankGForceBonus()
	end
end

for _, CrewTypeClass in ipairs(Classes.GetSubtypesAsList("ACF.CrewTypes.BaseCrewType")) do
	local LinkHandlers = table.Copy(CrewTypeClass.LinkHandlers or {})

	LinkHandlers.acf_o2tank = {
		OnLink = UpdateOxygenTankLink,
		OnUnLink = UpdateOxygenTankLink,
	}
	CrewTypeClass.LinkHandlers = LinkHandlers
end
