local ACF = ACF

hook.Add("PreRegisterSENT", "ACF_VSS_Waterjet", function(ENT, Class)
	if Class ~= "acf_waterjet" then return end

	local ACF_PostUpdateEntityData = ENT.ACF_PostUpdateEntityData

	function ENT:ACF_PostUpdateEntityData(...)
		ACF_PostUpdateEntityData(self, ...)

		self.ThrustMultiplier = 4
	end

	function ENT:Act(Torque, _, MassRatio, FlyRPM)
		local SelfTbl = self:GetTable()
		self:SetNW2Float("ACF_WaterjetRPM", FlyRPM)

		if not SelfTbl.InWater then return end
		if not IsValid(SelfTbl.Ancestor) then return end
		if ACF.IsDestroyed(self, SelfTbl) then return end

		local HealthRatio = SelfTbl.ACF.Health / SelfTbl.ACF.MaxHealth
		local N = FlyRPM / (2 * math.pi)
		local CT, Rho, D = SelfTbl.CT, SelfTbl.Rho, SelfTbl.Diameter

		local T =
			CT *
			Rho *
			N *
			N *
			D *
			D *
			D *
			D *
			SelfTbl.ThrustMultiplier

		local Phys = SelfTbl.AncestorPhys
		local Sign = Torque >= 0 and 1 or -1
		local Ang = Angle(
			SelfTbl.Pitch * SelfTbl.ArcPitch,
			0,
			SelfTbl.Yaw * SelfTbl.ArcYaw
		)

		local Dir = -self:LocalToWorldAngles(Ang):Up()

		Phys:ApplyForceOffset(
			Dir * T * Sign * MassRatio * HealthRatio,
			self:GetPos()
		)

		self:UpdateSound(SelfTbl)
	end
end)
