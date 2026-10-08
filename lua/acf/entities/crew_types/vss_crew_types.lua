local Classes = ACF.Classes

for _, Name in ipairs({ "ACF.CrewTypes.Loader", "ACF.CrewTypes.Gunner" }) do
	local CLASS = Classes.GetTypeByName(Name)

	CLASS.EnforceLimits = function(Crew)
		ACF.EnforceBaseplateType(
			Crew,
			ACF.Classes.GetTypeByName("ACF.Baseplates.GroundVehicle"),
			ACF.Classes.GetTypeByName("ACF.Baseplates.NavalVehicle")
		)
	end
end
