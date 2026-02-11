local ORIGINAL_ONBUTTON1 = nil

local function InstallGuard()
    if ORIGINAL_ONBUTTON1 then return false end

    local deathDialog = StaticPopupDialogs["DEATH"]
    if not deathDialog then return false end

    ORIGINAL_ONBUTTON1 = deathDialog.OnButton1

    deathDialog.OnButton1 = function(dialog, data)
        if IsInRaid() and not IsShiftKeyDown() then
            print("|cff00ccff[BeterFrames]|r Press Shift+click to release in a raid.")
            return -- block: do NOT call RepopMe()
        end
        return ORIGINAL_ONBUTTON1(dialog, data)
    end

    return true
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event, ...)
    if InstallGuard() then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)