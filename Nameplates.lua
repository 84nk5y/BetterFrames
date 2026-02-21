hooksecurefunc(NamePlateAuraItemMixin, "SetAura", function(self, aura)
    --if not aura or issecretvalue(aura.expirationTime) then return end

    if self.Cooldown then
        self.Cooldown:SetHideCountdownNumbers(true)
    end
end)