local ACF           = ACF
local ENTITY        = FindMetaTable("Entity")
local IsEntityValid = ACF.Optimizations.IsEntityValid

hook.Add("PreRegisterSENT", "ACF_VSS_Crew", function(ENT, Class)
	if Class ~= "acf_crew" then return end

	local ENT_UpdateUltraLowFreq = ENT.UpdateUltraLowFreq
	local ENT_UpdateMedFreq      = ENT.UpdateMedFreq
	local ENT_UpdateHighFreq     = ENT.UpdateHighFreq
	local ENT_EnforceLimits      = ENT.EnforceLimits

	local function ENT_UpdateLowFreq(self, cfg)
		local SelfTbl = ENTITY.GetTable(self)

		if SelfTbl.Disabled then return end

		local DeltaTime = cfg.DeltaTime

		-- Update health ergonomics
		SelfTbl.HealthEff = SelfTbl.ACF.Health / SelfTbl.ACF.MaxHealth
		WireLib.TriggerOutput(self, "HealthEff", SelfTbl.HealthEff * 100)

		-- Update oxygen levels and apply drowning if necessary
		local MouthPos = ENTITY.LocalToWorld(self, SelfTbl.CrewModel.MouthOffsetL) -- Probably well underwater at this point
		-- Debug.Cross(MouthPos, 4, 1, Red, true)
		local LiquidMask = bit.bor(CONTENTS_WATER, CONTENTS_SLIME)
		local IsUnderwater = bit.band(util.PointContents(MouthPos), LiquidMask) ~= 0
		local HasTankOxygen

		if IsUnderwater then
			for Tank in pairs(SelfTbl.TargetsByType.acf_o2tank or {}) do
				if not IsValid(Tank) or not Tank.ConsumeOxygen then continue end
				if not Tank:ConsumeOxygen(DeltaTime * ACF.CrewOxygenLossRate) then continue end

				HasTankOxygen = true
				break
			end
		end

		if HasTankOxygen then
			SelfTbl.Oxygen = ACF.CrewOxygen
		elseif IsUnderwater then
			SelfTbl.Oxygen = SelfTbl.Oxygen - DeltaTime * ACF.CrewOxygenLossRate
		else
			SelfTbl.Oxygen = SelfTbl.Oxygen + DeltaTime * ACF.CrewOxygenGainRate
		end
		SelfTbl.Oxygen = math.Clamp(SelfTbl.Oxygen, 0, ACF.CrewOxygen)
		if SelfTbl.Oxygen <= 0 and SelfTbl.IsAlive then
			self:KillCrew("player/pl_drown1.wav")
		end
		WireLib.TriggerOutput(self, "Oxygen", SelfTbl.Oxygen)

		-- Update crew focus
		if SelfTbl.IsAlive then SelfTbl.CrewType.UpdateFocus(self, SelfTbl.IsAlive)
		else SelfTbl.Focus = ACF.CrewFallbackCoef end

		if SelfTbl.CrewType.UpdateLowFreq then SelfTbl.CrewType.UpdateLowFreq(self, cfg) end
	end
	ENT.UpdateLowFreq = ENT_UpdateLowFreq

	function ENT:ACF_PostSpawn(Player)
		local CrewType = self:GetCrewType()

		if IsValid(Player) and CrewType.LimitConVar then
			Player:AddCount(CrewType.LimitConVar.Name, self)
		end

		-- Registered here so self.CrewType always exists by the time this is visible
		ACF.ActiveCrews[self] = true
		self:StartRegenTimer()

		-- Run randomized timers
		ACF.AugmentedTimer(function(cfg) ENT_UpdateUltraLowFreq(self, cfg) end, function() return IsEntityValid(self) end, nil, {MinTime = 3, MaxTime = 5, Delay = 0.1})
		ACF.AugmentedTimer(function(cfg) ENT_UpdateLowFreq(self, cfg) end, function() return IsEntityValid(self) end, nil, {MinTime = 1, MaxTime = 2, Delay = 0.1})
		ACF.AugmentedTimer(function(cfg) ENT_UpdateMedFreq(self, cfg) end, function() return IsEntityValid(self) end, nil, {MinTime = 0.5, MaxTime = 1, Delay = 0.1})
		ACF.AugmentedTimer(function(cfg) ENT_UpdateHighFreq(self, cfg) end, function() return IsEntityValid(self) end, nil, {MinTime = 0.1, MaxTime = 0.5, Delay = 0.1})
		ACF.AugmentedTimer(function(cfg) ENT_EnforceLimits(self, cfg) end, function() return IsEntityValid(self) end, nil, {MinTime = 1, MaxTime = 2, Delay = 0.1})

		hook.Add("Tick", "GForceCalculation" .. self:EntIndex(), function()
			self:EnforceGForces()
		end)

		self:CallOnRemove("GForceCalculation" .. self:EntIndex(), function()
			hook.Remove("Tick", "GForceCalculation" .. self:EntIndex())
		end)

		WireLib.TriggerOutput(self, "ModelEff", self.ModelEff * 100)

		if CrewType.OnSpawn then CrewType.OnSpawn(self) end
	end
end)
