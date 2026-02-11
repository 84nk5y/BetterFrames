hooksecurefunc(NamePlateAuraItemMixin, "SetAura", function(self, ...)
    if self and not issecretvalue(self) then
        self.Cooldown:SetHideCountdownNumbers(true)
    end
end)