local ACF = ACF

hook.Add("PreRegisterSENT", "ACF_VSS_Baseplate", function(ENT, Class)
	if Class ~= "acf_baseplate" then return end

	local PreviousENT = _G.ENT

	_G.ENT = ENT
	include("entities/acf_baseplate/modules/weight_limit.lua")
	_G.ENT = PreviousENT

	local ACF_PostSpawn = ENT.ACF_PostSpawn

	function ENT:ACF_PostSpawn(...)
		ACF_PostSpawn(self, ...)

		ACF.AugmentedTimer(function() self:UpdateWeightLimit() end, function() return IsValid(self) end, nil, {MinTime = 0.5, MaxTime = 1})
	end
end)
