hook.Add("PreRegisterSWEP", "ACF_VSS_Torch", function(SWEP, Class)
	if Class ~= "acf_torch" then return end

	local SetupDataTables = SWEP.SetupDataTables
	local Initialize      = SWEP.Initialize
	local Deploy          = SWEP.Deploy
	local Think           = SWEP.Think
	local PrimaryAttack   = SWEP.PrimaryAttack
	local SecondaryAttack = SWEP.SecondaryAttack

	function SWEP:SetupDataTables()
		SetupDataTables(self)

		self:NetworkVar("Int", 2, "ActionMode")
	end

	function SWEP:Initialize()
		Initialize(self)

		self:SetActionMode(0)
	end

	function SWEP:Deploy()
		self:SetActionMode(0)

		return Deploy(self)
	end

	function SWEP:Think()
		Think(self)

		local Owner = self:GetOwner()

		if not IsValid(Owner) then return end

		if CLIENT then return end

		local ActionMode = 0

		if Owner:KeyDown(IN_ATTACK) then
			ActionMode = 1
		elseif Owner:KeyDown(IN_ATTACK2) then
			ActionMode = 2
		end

		self:SetActionMode(ActionMode)
	end

	function SWEP:PrimaryAttack()
		self:SetActionMode(1)

		return PrimaryAttack(self)
	end

	function SWEP:SecondaryAttack()
		self:SetActionMode(2)

		return SecondaryAttack(self)
	end
end)
