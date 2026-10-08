local ACF         	= ACF
local Classes     	= ACF.Classes
local Utilities   	= ACF.Utilities
local Notify      	= Utilities.Notify

local ENTITY  = FindMetaTable("Entity")

local CannonType  = Classes.GetTypeByName("ACF.Guns.Cannon")
local NavalBaseplateType = Classes.GetTypeByName("ACF.Baseplates.NavalVehicle")
local MAX_GROUND_CANNON_CALIBER = 170

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
	local CanFire                  = ENT.CanFire
	local UpdateWeapon             = GetUpvalue(ACF_PostUpdateEntityData, "UpdateWeapon")

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

			local Baseplate = ACF.GetEntityBaseplate(Entity)
			if not IsValid(Baseplate) then
				timer.Simple(0.25, CheckBaseplate)
				return
			end

			local BaseplateType = Baseplate:ACF_GetUserVar("BaseplateType"):GetType()
			if BaseplateType == NavalBaseplateType then
				Entity.CannonCaliberCheckPending = nil
				return
			end

			Weapon.Caliber = MAX_GROUND_CANNON_CALIBER
			Entity:ACF_SetUserVar("Caliber", MAX_GROUND_CANNON_CALIBER)
			Entity.CannonCaliberCheckPending = nil

			local Class = Weapon:GetType()
			UpdateWeapon(Entity, Entity.ACF_LiveData, Class)

			local Owner = Entity:CPPIGetOwner()
			if IsValid(Owner) then
				Notify.WarningToPlayer(
					Owner,
					"Cannon caliber restricted",
					"You must use a Naval baseplate to go past 170 mm caliber."
				)
			end
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

	function ENT:CanFire(...)
		local SelfTbl = ENTITY.GetTable(self)

		if SelfTbl.CannonCaliberCheckPending then return false end

		return CanFire(self, ...)
	end
end)
