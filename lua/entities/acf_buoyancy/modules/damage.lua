local ACF = ACF
local Damage = ACF.Damage
local Clamp = math.Clamp
local Floor = math.floor

local COMPARTMENT_PROTECTION = 0.5

function ENT:ACF_OnDamage(DmgResult, DmgInfo)
	local Count = Clamp(Floor(tonumber(self.CompartmentCount) or 0), 0, 20)
	local ConvexHits = DmgInfo and DmgInfo:GetConvexHits()

	if Count > 0 then
		local OriginalDamage = DmgResult:Compute().Damage
		local Protection = 1 + Count * COMPARTMENT_PROTECTION

		DmgResult:SetDamage(OriginalDamage / Protection)

		if ConvexHits then
			local ProtectedHits = {}

			for Index, Hit in ipairs(ConvexHits) do
				ProtectedHits[Index] = table.Copy(Hit)
				ProtectedHits[Index].Volume = Hit.Volume / Protection
			end

			DmgInfo:SetConvexHits(ProtectedHits)
		end
	end

	local HitResult = Damage.doPropDamage(self, DmgResult, DmgInfo)

	if ConvexHits then
		DmgInfo:SetConvexHits(ConvexHits)
	end

	if self.ACF.Health <= 0 then
		HitResult.Kill = false
		self.ACF.Health = 1

		if Damage.Network then
			Damage.Network(self, nil, self.ACF.Health, self.ACF.MaxHealth)
		end
	end

	if self.UpdateBuoyancyRatio then
		self:UpdateBuoyancyRatio()
	end

	if self.UpdateOverlay then
		self:UpdateOverlay()
	end

	return HitResult
end
