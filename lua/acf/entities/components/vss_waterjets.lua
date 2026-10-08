local ACF        = ACF
local Classes    = ACF.Classes

function ACF.CreateNavalWaterjetMenu(_, Menu, Ctx)
    local SizeX = Menu:AddSlider("Size", 1, 4, 2)
    function SizeX:OnValueChanged(Value)
        local X = math.Round(Value, 2)

        self:SetValue(X)

        if Menu.ComponentPreview then
            Menu.ComponentPreview:SetModelScale(X, true)
        end

        Ctx:Set("NavalWaterjetSize", X)
    end
    SizeX:SetValue(math.Clamp(Ctx:Get("NavalWaterjetSize") or 2, 1, 4))
end

Classes.DefineClass("ACF.Components.NavalWaterjet", "ACF.Components.BaseComponent", function(CLASS)
    CLASS.Name         = "Naval Waterjet"
    CLASS.Description  = "A waterjet that can only operate on Naval Vehicle baseplates."
    CLASS.Model        = "models/maxofs2d/hover_propeller.mdl"
    CLASS.Entity       = "acf_naval_waterjet"
    CLASS.TutorialURL  = "docs/acf_tutorials/waterjets.html"
    CLASS.CreateMenu   = ACF.CreateNavalWaterjetMenu
end)
