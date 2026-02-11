PersonalResourceDisplayFrame.HealthBarsContainer:SetHeight(25)
PersonalResourceDisplayFrame:SetScale(0.75)

local function StyleBar(bar, border)
    bar:SetStatusBarTexture("UI-HUD-CoolDownManager-Bar")
    if not bar.bg then
        bar.bg = bar:CreateTexture(nil, "BACKGROUND", nil, -8)
        bar.bg:SetAtlas("UI-HUD-CoolDownManager-Bar-BG")
        bar.bg:SetPoint("TOPLEFT", bar, "TOPLEFT", -3, 3)
        bar.bg:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 7, -7)
    end
    border:Hide()
end

local function StyleAbsorbs(bar)
    if bar.totalAbsorb then
        bar.totalAbsorb:SetAtlas("raidframe-shield-fill")
    end
    if bar.totalAbsorbOverlay then
        bar.totalAbsorbOverlay:SetAtlas("RaidFrame-Shield-Overlay", true)
        bar.totalAbsorbOverlay:SetHorizTile(true)
        bar.totalAbsorbOverlay:SetVertTile(true)
    end
    if bar.overAbsorbGlow then
        bar.overAbsorbGlow:SetAtlas("RaidFrame-Shield-Overshield", true)
    end
end

local function StyleHeals(bar)
    local bars = {
        bar.myHealPrediction,
        bar.otherHealPrediction
    }

    for _, bar in ipairs(bars) do
        if bar then
            bar:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status")
        end
    end
end

hooksecurefunc(PersonalResourceDisplayFrame, "SetupAlternatePowerBar", function(self)
    local prdHealthBar = self.HealthBarsContainer.healthBar
    local prdPowerBar = self.PowerBar

    StyleBar(prdHealthBar, self.HealthBarsContainer.border)
    StyleBar(prdPowerBar, prdPowerBar.Border)

    StyleAbsorbs(prdHealthBar)
    StyleHeals(prdHealthBar)

    local _, englishClass = UnitClass("player")
    local classColor = RAID_CLASS_COLORS[englishClass]
    prdHealthBar:SetStatusBarColor(classColor.r, classColor.g, classColor.b)
end)

local function ApplyFading()
    local prd = PersonalResourceDisplayFrame
    local debuffs = DebuffFrame
    local cdbuffs = BuffIconCooldownViewer

    if not prd or not prd:IsShown() then
        return
    end
    if not debuffs then
        return
    end
    if not cdbuffs then
        return
    end

    if UnitAffectingCombat("player") then
        UIFrameFadeIn(prd, 0.2, prd:GetAlpha(), 1)
        UIFrameFadeIn(debuffs, 0.2, debuffs:GetAlpha(), 1)
        UIFrameFadeIn(cdbuffs, 0.2, cdbuffs:GetAlpha(), 1)
    else
        UIFrameFadeOut(prd, 2, prd:GetAlpha(), 0.1)
        UIFrameFadeOut(debuffs, 2, debuffs:GetAlpha(), 0.1)
        UIFrameFadeOut(cdbuffs, 2, cdbuffs:GetAlpha(), 0.1)
    end
end


local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        C_CVar.SetCVar("UnitNameOwn", "0")
        C_CVar.SetCVar("nameplateShowSelf", "1")
        C_CVar.SetCVar("NameplatePersonalShowAlways", "1")
        C_CVar.SetCVar("cooldownViewerEnabled", "1")
        C_CVar.SetCVar("externalDefensivesEnabled", "1")
        C_CVar.SetCVar("damageMeterEnabled", "1")
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Small delay to ensure all is initialized
        C_Timer.After(3, ApplyFading)

        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    else
        ApplyFading()
    end
end)
