local ACF = ACF
local Notify = ACF.Utilities.Notify

do
	function ACF.EnforceBaseplateType(Entity, ...)
		local Baseplate = ACF.GetEntityBaseplate(Entity)
		if IsValid(Baseplate) then
			local Type = Baseplate:ACF_GetUserVar("BaseplateType"):GetType()
			local TypeName = ACF.Classes.GetTypeName(Type)
			local ExpectedNames = {}

			for Index = 1, select("#", ...) do
				local AllowedType = select(Index, ...)
				if AllowedType and ACF.Classes.IsAssignableTo(Type, AllowedType) then return end

				if AllowedType then
					ExpectedNames[#ExpectedNames + 1] = ACF.Classes.GetTypeName(AllowedType)
				end
			end

			if #ExpectedNames > 0 then
				Notify.WarningToPlayer(
					Entity:CPPIGetOwner(),
					string.format("%s was removed due to being on an invalid baseplate type", tostring(Entity)),
					string.format("Got %s, expected %s", TypeName, table.concat(ExpectedNames, " or "))
				)
				Entity:Remove()
				return
			end
		end
	end
end
