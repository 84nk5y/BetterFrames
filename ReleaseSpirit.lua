local blocked = false

hooksecurefunc("StaticPopup_OnClick", function(dialog, buttonIndex)
    if dialog.which == "DEATH" and buttonIndex == 1 then
        if IsInRaid() and GetNumGroupMembers() > 1 and not IsShiftKeyDown() then
            blocked = true
            print("|cffB0C4DE[ReleaseGuard]|r Press Shift+click to release in a raid.")
        end
    end
end)

local originalRepopMe = RepopMe
RepopMe = function()
    if blocked then
        blocked = false
        return
    end
    originalRepopMe()
end