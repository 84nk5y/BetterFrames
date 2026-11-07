local ADDON_NAME = ...
local ADDON_MSG = "|cffB0C4DE["..ADDON_NAME.."]|r"

BF_SavedVars = BF_SavedVars or { CinematicsSkip = {} }
local SavedVars = BF_SavedVars.CinematicsSkip

local RETRY_STEP = 0.1
local RETRY_MAX = 10


-- In-engine cinematics carry no ID, so build a context key from where the player is
-- and which quest event (if any) happened just before. This is a heuristic.
local function BuildCinematicKey()
    local parts = {}

    local instanceID = select(8, GetInstanceInfo())
    parts[#parts + 1] = "i".. tostring(instanceID or 0)

    local mapID = C_Map.GetBestMapForUnit("player")
    parts[#parts + 1] = "m".. tostring(mapID or 0)

    parts[#parts + 1] = GetSubZoneText() or ""

    return "cinematic:".. table.concat(parts, ":")
end

local function IsMoviePlaying()
    return MovieFrame ~= nil and MovieFrame:IsShown()
end

local function SkipMovie()
    MovieFrame:Hide()
end

local function IsCinematicPlaying()
    return CinematicFrame ~= nil and CinematicFrame:IsShown()
end

local function SkipCinematic()
    if CinematicFrame_CancelCinematic then
        CinematicFrame_CancelCinematic()
    elseif StopCinematic then
        StopCinematic()
    end
end

local function TrySkip(isPlaying, doSkip, label, attemptsLeft)
    if isPlaying() then
        doSkip()
        print(ADDON_MSG.." Skipped "..label)
        return
    end
    if attemptsLeft > 0 then
        C_Timer.After(RETRY_STEP, function()
            TrySkip(isPlaying, doSkip, label, attemptsLeft - 1)
        end)
    end
end

local function Handle(key, isPlaying, doSkip, cancellable)
    if SavedVars[key] then
        TrySkip(isPlaying, doSkip, key, RETRY_MAX)
    else
        SavedVars[key] = { true }
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("VARIABLES_LOADED")
f:RegisterEvent("PLAY_MOVIE")
f:RegisterEvent("CINEMATIC_START")
f:SetScript("OnEvent", function(self, event, ...)
    if event == "VARIABLES_LOADED" then
        SavedVars = BF_SavedVars.CinematicsSkip
    elseif event == "PLAY_MOVIE" then
        local movieID = ...
        Handle("movie:".. tostring(movieID), IsMoviePlaying, SkipMovie)
    elseif event == "CINEMATIC_START" then
        local canBeCancelled = ...
        Handle(BuildCinematicKey(), IsCinematicPlaying, SkipCinematic, canBeCancelled)
    end
end)
