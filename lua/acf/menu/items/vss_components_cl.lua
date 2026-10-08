local ACF  = ACF
local Page = ACF.Menu.GetPage("acf_component")

local function GetUpvalue(Func, Name)
	for Index = 1, math.huge do
		local UpName, Value = debug.getupvalue(Func, Index)

		if UpName == nil then break end
		if UpName == Name then return Value end
	end

	error("Couldn't find upvalue " .. Name)
end

local CTX_NAMES = GetUpvalue(GetUpvalue(Page.Build, "ContextFor"), "CTX_NAMES")
local Contexts  = {
	NavalWaterjet = "acf_naval_waterjet",
}

local Position = table.KeyFromValue(CTX_NAMES, "Waterjet")

for _, Name in ipairs({ "NavalWaterjet" }) do
	Position = table.KeyFromValue(CTX_NAMES, Name) or Position + 1

	if CTX_NAMES[Position] ~= Name then
		table.insert(CTX_NAMES, Position, Name)
	end

	Page.Contexts[Name] = Contexts[Name]
end
