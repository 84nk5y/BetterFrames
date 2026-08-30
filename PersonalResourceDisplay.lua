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
    self.PrdHealthBar.text:Show()
    self.PrdPowerBar.text:Show()
end

function PrdMixin:OnLeave()
    self.PrdHealthBar.text:Hide()
    self.PrdPowerBar.text:Hide()
end


local function SetupBorder(frame)
    frame:GetStatusBarTexture():SetHorizTile(false)
    frame.border:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 11 })
    frame.border:SetBackdropBorderColor(0.7, 0.7, 0.7, 1)
end

PrdHealthBarMixin = {}

function PrdHealthBarMixin:OnLoad()
    self.colorSet = false

    SetupBorder(self)

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("UNIT_MAXHEALTH")
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
    self.colorSet = false

    SetupBorder(self)

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UNIT_POWER_UPDATE")
    self:RegisterEvent("UNIT_MAXPOWER")
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
