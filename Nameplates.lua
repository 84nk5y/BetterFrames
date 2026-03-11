hooksecurefunc(NamePlateAuraItemMixin, "SetAura", function(self, aura)
    if not aura then return end

    local cooldown = self.Cooldown
    if cooldown then
        pcall(function() cooldown:SetHideCountdownNumbers(true) end)
    end
end)