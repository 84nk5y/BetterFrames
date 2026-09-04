local function ApplyFading()
    local prd = PersonalResourceDisplayFrame
    if not prd or not prd:IsShown() then return end

    local debuffs = DebuffFrame
    local cdbuffs = BuffIconCooldownViewer
    if not debuffs or not cdbuffs then return end

    if UnitAffectingCombat("player") or UnitExists("target") then
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
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        C_CVar.SetCVar("UnitNameOwn", "0")
        C_CVar.SetCVar("nameplateShowSelf", "1")
        C_CVar.SetCVar("NameplatePersonalShowAlways", "1")
        C_CVar.SetCVar("cooldownViewerEnabled", "1")
        C_CVar.SetCVar("externalDefensivesEnabled", "1")
        C_CVar.SetCVar("damageMeterEnabled", "1")
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Small delay to ensure all frames are initialized before fading
        C_Timer.After(3, ApplyFading)

        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    else
        ApplyFading()
    end
end)