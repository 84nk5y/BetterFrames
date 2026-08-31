PrdMixin = {}

function PrdMixin:OnLoad()
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
end

function PrdMixin:OnEvent()
    if UnitAffectingCombat("player") or UnitExists("target") then
        UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
    else
        UIFrameFadeOut(self, 2, self:GetAlpha(), 0.1)
    end
end

function PrdMixin:OnEnter()
    self.PrdHealthBar:ShowText()
    self.PrdPowerBar:ShowText()
    self.PrdPetHealthBar:ShowText()
end

function PrdMixin:OnLeave()
    self.PrdHealthBar:HideText()
    self.PrdPowerBar:HideText()
    self.PrdPetHealthBar:HideText()
end


PrdStatusBarMixin = {}

function PrdStatusBarMixin:Setup()
    self:GetStatusBarTexture():SetHorizTile(false)
    self.border:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 11 })
    self.border:SetBackdropBorderColor(0.7, 0.7, 0.7, 1)

    self:HideText()
end

function PrdStatusBarMixin:ShowText()
    self.text:Show()
end

function PrdStatusBarMixin:HideText()
    self.text:Hide()
end


PrdHealthBarMixin = {}

function PrdHealthBarMixin:OnLoad()
    self:Setup()

    self.colorSet = false

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", "player")
    self:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
end

function PrdHealthBarMixin:OnEvent()
    if not self.colorSet then
        self.colorSet = true

        local className = select(2, UnitClass("player"))
        self:SetStatusBarColor(RAID_CLASS_COLORS[className].r, RAID_CLASS_COLORS[className].g, RAID_CLASS_COLORS[className].b)
    end

    self:SetMinMaxValues(0, UnitHealthMax("player"))
    self:SetValue(UnitHealth("player"))
    self.text:SetText(UnitHealth("player") .. "/" .. UnitHealthMax("player"))
end


PrdPowerBarMixin = {}

function PrdPowerBarMixin:OnLoad()
    self:Setup()

    self.colorSet = false

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    self:RegisterUnitEvent("UNIT_MAXPOWER", "player")
end

function PrdPowerBarMixin:OnEvent()
    if not self.colorSet then
        self.colorSet = true

        local powerToken = select(2, UnitPowerType("player"))
        self:SetStatusBarColor(PowerBarColor[powerToken].r, PowerBarColor[powerToken].g, PowerBarColor[powerToken].b)
    end

    self:SetMinMaxValues(0, UnitPowerMax("player"))
    self:SetValue(UnitPower("player"))
    self.text:SetText(UnitPower("player") .. "/" .. UnitPowerMax("player"))
end


PrdPetHealthBarMixin = {}

function PrdPetHealthBarMixin:OnLoad()
    self:Setup()

    local _, class = UnitClass("player")

    if class ~= "HUNTER" and class ~= "WARLOCK" then
        self:SetSize(150, 1)
        self:Hide()
    else
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        self:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", "pet")
        self:RegisterUnitEvent("UNIT_MAXHEALTH", "pet")
    end
end

function PrdPetHealthBarMixin:OnEvent()
    self:SetMinMaxValues(0, UnitHealthMax("pet"))
    self:SetValue(UnitHealth("pet"))
    self.text:SetText(UnitHealth("pet") .. "/" .. UnitHealthMax("pet"))
end


PrdAuraButtonMixin = {}

function PrdAuraButtonMixin:OnEnter()
    PrdTooltip:SetOwner(self, "ANCHOR_LEFT")

    if(self.spellID and not self.auraInstanceID) then
        PrdTooltip:SetSpellByID(self.spellID)
    elseif(self.auraInstanceID) then
        local setFunction = self.isBuff and PrdTooltip.SetUnitBuffByAuraInstanceID or PrdTooltip.SetUnitDebuffByAuraInstanceID
        setFunction(PrdTooltip, self.unit, self.auraInstanceID, self:GetParent():GetFilter())
    end

    self.UpdateTooltip = self.OnEnter
end

function PrdAuraButtonMixin:OnLeave()
    PrdTooltip:Hide()
end


local AURA_MAX_DISPLAY = 10

AuraContainerMixing = {}

function AuraContainerMixing:OnLoad()
    self.auraPool = CreateFramePool("FRAME", self, "PrdAuraButtonTemplate")

    self:RegisterUnitEvent("UNIT_AURA", "player")

    self:OnUnitAuraUpdate("player")
end

function AuraContainerMixing:OnEvent(event, ...)
    self:OnUnitAuraUpdate(...)
end

function AuraContainerMixing:OnUnitAuraUpdate(unit, unitAuraUpdateInfo)
    local aurasChanged = false
    if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate or self.auras == nil then
        self:ParseAllAuras(unit)
        aurasChanged = true
    else
        if unitAuraUpdateInfo.addedAuras ~= nil then
            for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
                if self:ShouldShow(aura) and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, self:GetFilter()) then
                    self.auras[aura.auraInstanceID] = aura
                    aurasChanged = true
                end
            end
        end
        if unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil then
            for _, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
                if self.auras[auraInstanceID] ~= nil then
                    local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID)
                    self.auras[auraInstanceID] = newAura
                    aurasChanged = true
                end
            end
        end
        if unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil then
            for _, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
                if self.auras[auraInstanceID] ~= nil then
                    self.auras[auraInstanceID] = nil
                    aurasChanged = true
                end
            end
        end
    end

    if not aurasChanged then return end

    self.auraPool:ReleaseAll()

    local auraIndex = 1
    self.auras:Iterate(function(auraInstanceID, aura)
        local auraButton = self.auraPool:Acquire()
        auraButton.auraInstanceID = auraInstanceID
        auraButton.isBuff = aura.isHelpful
        auraButton.layoutIndex = auraIndex
        auraButton.spellID = aura.spellId
        auraButton.unit = unit

        auraButton.Icon:SetTexture(aura.icon)
        if (aura.applications > 1) then
            auraButton.CountFrame.Count:SetText(aura.applications)
            auraButton.CountFrame.Count:Show()
        else
            auraButton.CountFrame.Count:Hide()
        end
        CooldownFrame_Set(auraButton.Cooldown, aura.expirationTime - aura.duration, aura.duration, aura.duration > 0, true)

        auraButton:Show()

        auraIndex = auraIndex + 1
        return auraIndex >= AURA_MAX_DISPLAY
    end)

    self:Layout()
end

function AuraContainerMixing:ParseAllAuras(unit)
    if self.auras == nil then
        self.auras = TableUtil.CreatePriorityTable(AuraUtil.DefaultAuraCompare, TableUtil.Constants.AssociativePriorityTable)
    else
        self.auras:Clear()
    end

    local function HandleAura(aura)
        if self:ShouldShow(aura) then
            self.auras[aura.auraInstanceID] = aura
        end

        return false
    end

    AuraUtil.ForEachAura(unit, self:GetFilter(), nil, HandleAura, true)
end

local BUFFS_TO_BE_FILTERED = {
    ["Power Word: Fortitude"] = true
}

BuffContainerMixin = CreateFromMixins(AuraContainerMixing)

function BuffContainerMixin:GetFilter()
    return "HELPFUL"
end

function BuffContainerMixin:ShouldShow(aura)
    return not BUFFS_TO_BE_FILTERED[aura.name]
end


DebuffContainerMixin = CreateFromMixins(AuraContainerMixing)

function DebuffContainerMixin:GetFilter()
    return "HARMFUL"
end

function DebuffContainerMixin:ShouldShow(aura)
    return true
end