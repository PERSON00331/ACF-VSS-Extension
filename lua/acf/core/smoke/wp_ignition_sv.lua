local ACF = ACF

timer.Create("ACF WP Player Ignition", 0.1, 0, function()
	local Time = CurTime()

	for _, Cloud in pairs(ACF.SmokeClouds) do
		if Cloud.Type ~= "WP" or Time > Cloud.Start + Cloud.Life then continue end

		local Center, Radius = ACF.GetSmokeCloudState(Cloud, Time)
		local RadiusSqr = Radius * Radius

		for _, Player in ipairs(player.GetAll()) do
			if not Player:Alive() or Player:IsOnFire() then continue end

			local Mins, Maxs = Player:WorldSpaceAABB()
			local DX = math.max(Mins.x - Center.x, 0, Center.x - Maxs.x)
			local DY = math.max(Mins.y - Center.y, 0, Center.y - Maxs.y)
			local DZ = math.max(Mins.z - Center.z, 0, Center.z - Maxs.z)

			if DX * DX + DY * DY + DZ * DZ > RadiusSqr then continue end

			Player:Ignite(5)
		end
	end
end)
