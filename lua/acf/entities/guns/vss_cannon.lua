hook.Add("ACF_OnLoadAddon", "ACF_VSS_Cannon", function()
	ACF.Classes.GetTypeByName("ACF.Guns.Cannon").CaliberLimits.Max = 300
end)
