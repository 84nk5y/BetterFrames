local function ApplyStyle(bar, border)
    bar:SetStatusBarTexture("UI-HUD-CoolDownManager-Bar")
    local bg = bar:CreateTexture(nil, "BACKGROUND", nil, -8)
    bg:SetAtlas("UI-HUD-CoolDownManager-Bar-BG")
    bg:SetPoint("TOPLEFT", bar, "TOPLEFT", -3, 3)
    bg:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 7, -7)
    border:Hide()
end

PersonalResourceDisplayFrame.HealthBarsContainer:SetHeight(25)
PersonalResourceDisplayFrame:SetScale(0.75)
hooksecurefunc(PersonalResourceDisplayFrame, "SetupAlternatePowerBar", function(self)
    local prdHealthBar = self.HealthBarsContainer.healthBar
    local prdPowerBar = self.PowerBar

    -- apply the bar style
    ApplyStyle(prdHealthBar, self.HealthBarsContainer.border)
    ApplyStyle(prdPowerBar, prdPowerBar.Border)

    -- apply the player class color
    local localizedClass, englishClass = UnitClass("player")
        local classColor = RAID_CLASS_COLORS[englishClass]
    prdHealthBar:SetStatusBarColor(classColor.r, classColor.g, classColor.b)
end)
