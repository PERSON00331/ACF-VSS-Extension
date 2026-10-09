local ACF         	= ACF
local Classes     	= ACF.Classes
local Utilities   	= ACF.Utilities
local Notify      	= Utilities.Notify

local ENTITY  = FindMetaTable("Entity")

local CannonType  = Classes.GetTypeByName("ACF.Guns.Cannon")
local NavalBaseplateType = Classes.GetTypeByName("ACF.Baseplates.NavalVehicle")
local MAX_GROUND_CANNON_CALIBER = 170
local NAVAL_CANNON_CALIBER_TIERS = {
	{ Length = 480, Width = 240, Caliber = 300 },
	{ Length = 360, Width = 180, Caliber = 265 },
	{ Length = 240, Width = 120, Caliber = 230 },
	{ Length = 120, Width = 72, Caliber = 200 },
}

local function GetUpvalue(Func, Name)
	for Index = 1, math.huge do
		local UpName, Value = debug.getupvalue(Func, Index)

		if UpName == nil then break end
		if UpName == Name then return Value end
	end

	error("Couldn't find upvalue " .. Name)
end

hook.Add("PreRegisterSENT", "ACF_VSS_Gun", function(ENT, Class)
	if Class ~= "acf_gun" then return end

	local ACF_PostUpdateEntityData = ENT.ACF_PostUpdateEntityData
	local ACF_PostSpawn            = ENT.ACF_PostSpawn
	local CanFire                  = ENT.CanFire
	local UpdateWeapon             = GetUpvalue(ACF_PostUpdateEntityData, "UpdateWeapon")

	local function GetMaxCannonCaliber(Baseplate)
		local TypeValue = Baseplate:ACF_GetUserVar("BaseplateType")
		local BaseplateType = TypeValue and TypeValue:GetType()

		if BaseplateType ~= NavalBaseplateType then
			return MAX_GROUND_CANNON_CALIBER
		end

		local Size = Baseplate.BaseplateSize
		local Length = tonumber(Size and Size.x or Baseplate:ACF_GetUserVar("Length")) or 0
		local Width = tonumber(Size and Size.y or Baseplate:ACF_GetUserVar("Width")) or 0

		for _, Tier in ipairs(NAVAL_CANNON_CALIBER_TIERS) do
			if Length >= Tier.Length and Width >= Tier.Width then
				return Tier.Caliber
			end
		end

		return MAX_GROUND_CANNON_CALIBER
	end

	local function CheckCannonCaliberLimit(Entity)
		if not IsValid(Entity) then return true end

		local Weapon = Entity:GetWeapon()

		if not Weapon or not Classes.IsAssignableTo(Weapon:GetType(), CannonType) then
			return true
		end

		local Baseplate = ACF.GetEntityBaseplate(Entity)

		if not IsValid(Baseplate) then return false end

		local MaxCaliber = GetMaxCannonCaliber(Baseplate)

		if (Weapon.Caliber or 0) <= MaxCaliber then return true end

		Weapon.Caliber = MaxCaliber
		Weapon:VerifyData()

		local Caliber = Weapon.Caliber

		Entity:ACF_SetUserVar("Caliber", Caliber)
		UpdateWeapon(Entity, Entity.ACF_LiveData, Weapon:GetType())

		local Owner = Entity:CPPIGetOwner()

		if IsValid(Owner) then
			local BaseplateType = Baseplate:ACF_GetUserVar("BaseplateType"):GetType()
			local Message

			if BaseplateType == NavalBaseplateType then
				Message = string.format(
					"This naval baseplate's size supports cannons up to %d mm. The cannon was reduced to that caliber.",
					Caliber
				)
			else
				Message = "You must use a Naval baseplate to go past 170 mm caliber."
			end

			Notify.WarningToPlayer(Owner, "Cannon caliber restricted", Message)
		end

		return true
	end

	local function ScheduleCannonCaliberCheck(Entity)
		if Entity.CannonCaliberCheckPending then return end

		Entity.CannonCaliberCheckPending = true

		local function CheckBaseplate()
			if not IsValid(Entity) then return end
			if not Entity.CannonCaliberCheckPending then return end

			local Weapon = Entity:GetWeapon()
			if not Weapon or not Classes.IsAssignableTo(Weapon:GetType(), CannonType)
				or (Weapon.Caliber or 0) <= MAX_GROUND_CANNON_CALIBER then
				Entity.CannonCaliberCheckPending = nil
				return
			end

			if not CheckCannonCaliberLimit(Entity) then
				timer.Simple(0.25, CheckBaseplate)
				return
			end

			Entity.CannonCaliberCheckPending = nil
		end

		timer.Simple(0, CheckBaseplate)
	end

	function ENT:ACF_PostUpdateEntityData(...)
		self.CannonCaliberCheckPending = nil

		ACF_PostUpdateEntityData(self, ...)

		local Weapon  = self:GetWeapon()

		if Classes.IsAssignableTo(Weapon:GetType(), CannonType)
			and (Weapon.Caliber or 0) > MAX_GROUND_CANNON_CALIBER then
			ScheduleCannonCaliberCheck(self)
		end
	end

	function ENT:ACF_PostSpawn(...)
		ACF_PostSpawn(self, ...)

		if Classes.IsAssignableTo(self:GetWeapon():GetType(), CannonType) then
			ACF.AugmentedTimer(function() CheckCannonCaliberLimit(self) end, function() return IsValid(self) end, nil, {MinTime = 1, MaxTime = 2})
		end
	end

	function ENT:CanFire(...)
		local SelfTbl = ENTITY.GetTable(self)

		if SelfTbl.CannonCaliberCheckPending then return false end

		return CanFire(self, ...)
	end
end)
