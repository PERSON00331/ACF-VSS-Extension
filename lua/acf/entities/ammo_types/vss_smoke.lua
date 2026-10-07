local ACF       = ACF
local Classes   = ACF.Classes

if SERVER then
	local CLASS = Classes.GetTypeByName("ACF.Ammunition.SM")
	local WPClouds = {}

	local function CreateWPCloud(Bullet, Position)
		if not Bullet or not isnumber(Bullet.WPMass) or Bullet.WPMass <= 0 then return end
		if not isvector(Position) then return end

		local WPFiller = math.min(math.log(1 + Bullet.WPMass * 8 * ACF.MeterToInch) * 43.4216, 350)
		local WPLife = math.Round(5 + WPFiller * 0.1, 2)
		local WPRadius = WPFiller * 1.25 * 2

		if WPLife <= 0 or WPRadius <= 0 then return end

		WPClouds[#WPClouds + 1] = {
			Position = Position,
			Radius = WPRadius,
			RadiusSqr = WPRadius * WPRadius,
			EndTime = CurTime() + WPLife
		}
	end

	hook.Add("Think", "ACF_SM_WPClouds", function()
		local Time = CurTime()

		for I = #WPClouds, 1, -1 do
			local Cloud = WPClouds[I]

			if Time >= Cloud.EndTime then
				WPClouds[I] = WPClouds[#WPClouds]
				WPClouds[#WPClouds] = nil
				continue
			end

			for _, Ply in ipairs(player.GetAll()) do
				if IsValid(Ply) and Ply:Alive() then
					local DistSqr = Ply:GetPos():DistToSqr(Cloud.Position)

					if DistSqr <= Cloud.RadiusSqr then
						if not Ply:IsOnFire() then
							Ply:Ignite(1)
						end
					end
				end
			end
		end
	end)

	local PropImpact = CLASS.PropImpact

	function CLASS:PropImpact(Bullet, Trace)
		if Bullet.WPMass > 0 then
			CreateWPCloud(Bullet, Trace.HitPos)
		end

		return PropImpact(self, Bullet, Trace)
	end

	local WorldImpact = CLASS.WorldImpact

	function CLASS:WorldImpact(Bullet, Trace)
		if Bullet.WPMass > 0 then
			CreateWPCloud(Bullet, Trace.HitPos)
		end

		return WorldImpact(self, Bullet, Trace)
	end
end
