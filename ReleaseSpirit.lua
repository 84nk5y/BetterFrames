-- Hook the actual Release button before it fires
local function GuardReleaseButton()
    for i = 1, 4 do
        local dialog = _G["StaticPopup" .. i]
        if dialog and dialog:IsShown() and dialog.which == "DEATH" then
            local button = _G["StaticPopup" .. i .. "Button1"]
            if button and not button.releaseGuardHooked then
                button:HookScript("OnClick", function()
                    if IsInRaid() and GetNumGroupMembers() > 1 and not IsShiftKeyDown() then
                        -- Re-hide the result of the click by re-showing the popup
                        -- We can't block, but we can immediately show a warning
                        -- and the actual block must happen in RepopMe
                        print("|cffB0C4DE[ReleaseGuard]|r Hold Shift+click to release in a raid.")
                    end
                end)
                button.releaseGuardHooked = true
            end
        end
    end
end

-- The real block: override RepopMe directly
-- Store ref BEFORE any other addon can touch it
local _RepopMe = RepopMe
RepopMe = function(...)
    if IsInRaid() and GetNumGroupMembers() > 1 and not IsShiftKeyDown() then
        print("|cffB0C4DE[ReleaseGuard]|r Hold Shift and click Release to release in a raid.")
        -- Re-show the death popup so the player still has the option
        StaticPopup_Show("DEATH")
        return
    end
    return _RepopMe(...)
end