local ACF     = ACF
local Classes = ACF.Classes

for _, CrewTypeClass in ipairs(Classes.GetSubtypesAsList("ACF.CrewTypes.BaseCrewType")) do
	local LinkHandlers = table.Copy(CrewTypeClass.LinkHandlers or {})

	LinkHandlers.acf_o2tank = LinkHandlers.acf_o2tank or {}
	CrewTypeClass.LinkHandlers = LinkHandlers
end
