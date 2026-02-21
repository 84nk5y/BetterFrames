hooksecurefunc("StaticPopup_Show", function(which)
    if which == "DEATH" then
        local button = StaticPopup1Button1

        button:SetScript("OnClick", function(self)
            if IsInRaid() and GetNumGroupMembers() > 1 and not IsShiftKeyDown() then
                print("|cffB0C4DE[ReleaseGuard]|r Press Shift+click to release in a raid.")
            else
                RepopMe()
                StaticPopup_Hide("DEATH")
            end
        end)
    end
end)