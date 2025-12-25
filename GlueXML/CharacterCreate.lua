-- ============================================================================
-- Autora: Noa
-- ============================================================================
CHARACTER_FACING_INCREMENT = 2;
MAX_RACES = 10;
MAX_CLASSES_PER_RACE = 10;
NUM_CHAR_CUSTOMIZATIONS = 5;
MIN_CHAR_NAME_LENGTH = 2;
CHARACTER_CREATE_ROTATION_START_X = nil;
CHARACTER_ROTATION_INCREMENT = 90;
CHARACTER_CREATE_INITIAL_FACING = nil;

PAID_CHARACTER_CUSTOMIZATION = 1;
PAID_RACE_CHANGE = 2;
PAID_FACTION_CHANGE = 3;
PAID_SERVICE_CHARACTER_ID = nil;
PAID_SERVICE_TYPE = nil;

FACTION_BACKDROP_COLOR_TABLE = {
	["Alliance"] = {0.5, 0.5, 0.5, 0.09, 0.09, 0.19},
	["Horde"] = {0.5, 0.2, 0.2, 0.19, 0.05, 0.05},
};
FRAMES_TO_BACKDROP_COLOR = { 
	"CharacterCreateCharacterRace",
	"CharacterCreateCharacterClass",
--	"CharacterCreateCharacterFaction",
	"CharacterCreateNameEdit",
};
RACE_ICON_TCOORDS = {
    ["HUMAN_MALE"]       = {0.000000000, 0.062500000, 0.000000000, 0.125953125},
    ["DWARF_MALE"]       = {0.063476563, 0.125976563, 0.000000000, 0.125953125},
    ["GNOME_MALE"]       = {0.191406250, 0.253906250, 0.000000000, 0.125953125},
    ["NIGHTELF_MALE"]    = {0.126953125, 0.189453125, 0.000000000, 0.125953125},
    ["DRAENEI_MALE"]     = {0.255859375, 0.318359375, 0.000000000, 0.125953125},

    ["HUMAN_FEMALE"]     = {0.000000000, 0.062500000, 0.128906250, 0.253906250},  
    ["DWARF_FEMALE"]     = {0.063476563, 0.125976563, 0.128906250, 0.253906250}, 
    ["GNOME_FEMALE"]     = {0.192382813, 0.254882813, 0.128906250, 0.253906250}, 
    ["NIGHTELF_FEMALE"]  = {0.127441406, 0.189941406, 0.128906250, 0.253906250}, 
    ["DRAENEI_FEMALE"]   = {0.256347656, 0.318359375, 0.128906250, 0.253906250}, 

    ["ORC_MALE"]         = {0.062011719, 0.000000000, 0.262695313, 0.384765625},
    ["SCOURGE_MALE"]     = {0.125976563, 0.063964844, 0.262695313, 0.384765625},
    ["TAUREN_MALE"]      = {0.189941406, 0.127929688, 0.262695313, 0.384765625},
    ["TROLL_MALE"]       = {0.253906250, 0.192382813, 0.262695313, 0.384765625},
    ["BLOODELF_MALE"]    = {0.317871094, 0.256835938, 0.262695313, 0.384765625},

    ["ORC_FEMALE"]       = {0.060546875, 0.000000000, 0.391601563, 0.512695313},   
    ["SCOURGE_FEMALE"]   = {0.124023438, 0.063476563, 0.391601563, 0.512695313},   
    ["TAUREN_FEMALE"]    = {0.187988281, 0.127441406, 0.391601563, 0.512695313},  
    ["TROLL_FEMALE"]     = {0.252441406, 0.191894531, 0.391601563, 0.512695313},  
    ["BLOODELF_FEMALE"]  = {0.316894531, 0.256835938, 0.391601563, 0.512695313},
};
CLASS_ICON_TCOORDS = {
	["WARRIOR"]	    = {0.000000000, 0.063000000, 0.872000000, 1.000000000},
	["MAGE"]	    = {0.127441406, 0.189941406, 0.872070313, 1.000000000},
	["ROGUE"]	    = {0.191406250, 0.253906250, 0.872070313, 1.000000000},
	["DRUID"]	    = {0.447753906, 0.510253906, 0.872070313, 1.000000000},
	["HUNTER"]	    = {0.063476563, 0.126464844, 0.872070313, 1.000000000},
	["SHAMAN"]	    = {0.512695313, 0.575195313, 0.872070313, 1.000000000},
	["PRIEST"]	    = {0.255859375, 0.318359375, 0.872070313, 1.000000000},
	["WARLOCK"]	    = {0.319824219, 0.382324219, 0.872070313, 1.000000000},
	["PALADIN"]	    = {0.383300781, 0.445800781, 0.872070313, 1.000000000},
	["DEATHKNIGHT"]	= {0.576660156, 0.639160156, 0.872070313, 1.000000000},
};

if not _G.ALLIANCE_RACES then
    _G.ALLIANCE_RACES = {1, 2, 3, 4, 5}
end

if not _G.HORDE_RACES then
    _G.HORDE_RACES = {6, 7, 8, 9, 10}
end

local HideNameEditFrame = CreateFrame("Frame")
local hideScheduled = false

local AllianceTooltip
local HordeTooltip
local raceTooltips = {};
local classTooltips = {};
local detailedRaceTooltips = {};
local detailedClassTooltips = {};

local function HideAllTooltips()
    for button, tooltip in pairs(raceTooltips) do
        if tooltip then
            tooltip:Hide()
        end
    end

    for button, tooltip in pairs(classTooltips) do
        if tooltip then
            tooltip:Hide()
        end
    end

    if AllianceTooltip then
        AllianceTooltip:Hide()
    end
    
    if HordeTooltip then
        HordeTooltip:Hide()
    end
end

local backdrop = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
    tile = true, tileSize = 16, edgeSize = 16, 
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
};

local Backdrop2 = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
    edgeFile = "Interface\\Tooltips\\ui-tooltip-border-maw", 
    tile = true, tileSize = 16, edgeSize = 16, 
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
};

local function GetOrCreateRaceTooltip(button)
    if not raceTooltips[button] then
        local tooltip = CreateFrame("Frame", nil, CharacterCreateFrame)
        tooltip:SetBackdrop(Backdrop2)
        tooltip:SetSize(280, 150)
        tooltip:SetFrameStrata("TOOLTIP")
        tooltip:SetBackdropColor(0, 0, 0, 1)
        
        local raceID = button:GetID()
        local faction = _G.GetFactionForRaceID(raceID)
        
        if faction == "Alliance" then
            tooltip:SetPoint("LEFT", CharacterCreateFrame, "LEFT", 160, 50)
        elseif faction == "Horde" then
            tooltip:SetPoint("RIGHT", CharacterCreateFrame, "RIGHT", -160, 50)
        else
            tooltip:SetPoint("CENTER", CharacterCreateFrame, "CENTER", 0, 0)
        end

        tooltip.text = tooltip:CreateFontString(nil, "OVERLAY", "GlueFontNormalSmall")
        tooltip.text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        tooltip.text:SetPoint("TOPLEFT", tooltip, "TOPLEFT", 10, -10)
        tooltip.text:SetTextColor(1, 0.82, 0)
        tooltip.text:SetJustifyH("LEFT")

        tooltip.detailsText = tooltip:CreateFontString(nil, "OVERLAY")
        tooltip.detailsText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        tooltip.detailsText:SetPoint("TOPLEFT", tooltip.text, "BOTTOMLEFT", 0, -5)
        tooltip.detailsText:SetWidth(260)
        tooltip.detailsText:SetWordWrap(true)
        tooltip.detailsText:SetJustifyH("LEFT")

        tooltip.rightClickText = tooltip:CreateFontString(nil, "OVERLAY")
        tooltip.rightClickText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        tooltip.rightClickText:SetPoint("TOP", tooltip.detailsText, "BOTTOM", 0, -10)
        tooltip.rightClickText:SetTextColor(0.8, 0.8, 0.8)
        tooltip.rightClickText:SetJustifyH("CENTER")
        
        raceTooltips[button] = tooltip
    end
    return raceTooltips[button]
end

local function UpdateRaceTooltip(button, toggleDetails)
    local tooltip = GetOrCreateRaceTooltip(button)
    local raceID = button:GetID()
    local info = _G.Races_Informations[raceID]
    if not info then return end

    for i = 1, 6 do
        if tooltip["spellContainer"..i] then
            tooltip["spellContainer"..i]:Hide()
        end
    end

    tooltip.text:SetText("|cFFFFFFFF"..info.Name)
    tooltip.detailsText:SetText("|cffffd100"..info.Description.."|r")

    tooltip.text:ClearAllPoints()
    tooltip.text:SetPoint("TOPLEFT", tooltip, "TOPLEFT", 10, -5)
    
    tooltip.detailsText:ClearAllPoints()
    tooltip.detailsText:SetPoint("TOPLEFT", tooltip.text, "BOTTOMLEFT", 0, -5)

    if toggleDetails == nil then
        toggleDetails = not detailedRaceTooltips[button]
    end

    tooltip.rightClickText:SetText(toggleDetails and RACIALS_HIDE_HINT or RACIALS_SHOW_HINT)

    local lastElement = tooltip.detailsText
    local heightToAdd = 0

    tooltip.rightClickText:ClearAllPoints()
    tooltip.rightClickText:SetPoint("TOP", tooltip.detailsText, "BOTTOM", 0, -10)
    lastElement = tooltip.rightClickText

    if toggleDetails then
        for i = 1, 6 do
            if info["Spell_"..i] and info["Spell_"..i].name ~= "" then
                if not tooltip["spellContainer"..i] then
                    tooltip["spellContainer"..i] = CreateFrame("Frame", nil, tooltip)
                    tooltip["spellContainer"..i]:SetSize(260, 60)

                    tooltip["spellIcon"..i] = tooltip["spellContainer"..i]:CreateTexture(nil, "OVERLAY")
                    tooltip["spellIcon"..i]:SetTexture("Interface\\Icons\\"..info["Spell_"..i].icon)
                    tooltip["spellIcon"..i]:SetSize(25, 25)
                    tooltip["spellIcon"..i]:SetPoint("TOPLEFT", -35, -20)

                    tooltip["spellName"..i] = tooltip["spellContainer"..i]:CreateFontString(nil, "OVERLAY")
                    tooltip["spellName"..i]:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
                    tooltip["spellName"..i]:SetPoint("LEFT", tooltip["spellIcon"..i], "RIGHT", 5, 8)
                    tooltip["spellName"..i]:SetTextColor(1, 0.82, 0)
                    tooltip["spellName"..i]:SetJustifyH("LEFT")

                    tooltip["spellDesc"..i] = tooltip["spellContainer"..i]:CreateFontString(nil, "OVERLAY")
                    tooltip["spellDesc"..i]:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
                    tooltip["spellDesc"..i]:SetWordWrap(true)
                    tooltip["spellDesc"..i]:SetJustifyH("LEFT")
                    tooltip["spellDesc"..i]:SetPoint("TOPLEFT", tooltip["spellName"..i], "BOTTOMLEFT", 0, -2)
                end

                tooltip["spellName"..i]:SetText(info["Spell_"..i].name)
                tooltip["spellDesc"..i]:SetText(info["Spell_"..i].description)

                tooltip["spellContainer"..i]:Show()
                tooltip["spellContainer"..i]:ClearAllPoints()
                tooltip["spellContainer"..i]:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 0, 3)

                local containerHeight = tooltip["spellIcon"..i]:GetHeight() + tooltip["spellDesc"..i]:GetHeight() + 3
                tooltip["spellContainer"..i]:SetHeight(containerHeight)
                
                lastElement = tooltip["spellContainer"..i]
            end
        end
    end

    local maxWidth = math.max(tooltip.text:GetWidth(), tooltip.detailsText:GetWidth())
    if toggleDetails then
        for i = 1, 6 do
            if tooltip["spellContainer"..i] and tooltip["spellContainer"..i]:IsShown() then
                local nameWidth = tooltip["spellName"..i]:GetStringWidth()
                maxWidth = math.max(maxWidth, nameWidth + 70)
            end
        end
    end
    maxWidth = math.max(280, math.min(maxWidth + 40, 600))
    tooltip:SetWidth(300)

    if toggleDetails then
        for i = 1, 6 do
            if tooltip["spellContainer"..i] and tooltip["spellContainer"..i]:IsShown() then
                tooltip["spellDesc"..i]:SetWidth(maxWidth - 60)
                local containerHeight = tooltip["spellIcon"..i]:GetHeight() + tooltip["spellDesc"..i]:GetHeight() + 3
                tooltip["spellContainer"..i]:SetHeight(containerHeight)
            end
        end
    end

    heightToAdd = 0
    if toggleDetails then
        for i = 1, 6 do
            if tooltip["spellContainer"..i] and tooltip["spellContainer"..i]:IsShown() then
                heightToAdd = heightToAdd + tooltip["spellContainer"..i]:GetHeight() + 3
            end
        end
    end

    local baseHeight = tooltip.text:GetHeight() + 
                      tooltip.detailsText:GetHeight() + 
                      tooltip.rightClickText:GetHeight() + 25
    
    tooltip:SetHeight(baseHeight + heightToAdd)
    detailedRaceTooltips[button] = toggleDetails
    tooltip:ClearAllPoints()

    local pos = _G.GetRaceTooltipPosition(raceID, button)
    tooltip:SetPoint(pos.point, button, pos.relPoint, pos.x, pos.y)
end

local function GetOrCreateClassTooltip(button)
    if not classTooltips[button] then
        local tooltip = CreateFrame("Frame", nil, CharacterCreateFrame)
        tooltip:SetBackdrop(Backdrop2)
        tooltip:SetSize(300, 200)
        tooltip:SetFrameStrata("TOOLTIP")
        tooltip:SetBackdropColor(0, 0, 0, 1)

        tooltip.text = tooltip:CreateFontString(nil, "OVERLAY", "GlueFontNormalSmall")
        tooltip.text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        tooltip.text:SetPoint("TOPLEFT", tooltip, "TOPLEFT", 8, -8)
        tooltip.text:SetTextColor(1, 0.82, 0)
        tooltip.text:SetJustifyH("LEFT")

        tooltip.detailsText = tooltip:CreateFontString(nil, "OVERLAY")
        tooltip.detailsText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        tooltip.detailsText:SetPoint("TOPLEFT", tooltip.text, "BOTTOMLEFT", 0, -5)
        tooltip.detailsText:SetWidth(284)
        tooltip.detailsText:SetWordWrap(true)
        tooltip.detailsText:SetJustifyH("LEFT")

        tooltip.Roles = tooltip:CreateFontString(nil, "OVERLAY", "GlueFontNormalSmall")
        tooltip.Roles:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        tooltip.Roles:SetWidth(284)
        tooltip.Roles:SetWordWrap(true)
        tooltip.Roles:SetJustifyH("LEFT")
        
        classTooltips[button] = tooltip
    end

    return classTooltips[button]
end

local function GetValidRacesForClass(classID)
    local allianceRaces = {}
    local hordeRaces = {}

    for _, raceID in ipairs(_G.ALLIANCE_RACES) do
        if IsRaceClassValid(raceID, classID) then
            local raceName = _G["RACE_" .. raceID] or RACE .. raceID
            table.insert(allianceRaces, raceName)
        end
    end

    for _, raceID in ipairs(_G.HORDE_RACES) do
        if IsRaceClassValid(raceID, classID) then
            local raceName = _G["RACE_" .. raceID] or RACE .. raceID
            table.insert(hordeRaces, raceName)
        end
    end
    
    return allianceRaces, hordeRaces
end
local function UpdateClassTooltip(button)
    local tooltip = GetOrCreateClassTooltip(button)
    local classID = button:GetID()
    local info = _G.Class_Informations[classID]

    if not info then return end

    local buttonX, buttonY = button:GetCenter()
    local parentX, parentY = CharacterCreateFrame:GetCenter()
    
    if buttonX > parentX then
        tooltip:SetPoint("BOTTOMRIGHT", button, "TOPRIGHT", 0, 10)
    else
        tooltip:SetPoint("BOTTOMLEFT", button, "TOPLEFT", 0, 10)
    end

    tooltip.text:SetText("|cFFFFFFFF"..info.Name)
    tooltip.detailsText:SetText("|cffffd100"..info.Description.."|r")

    tooltip.text:ClearAllPoints()
    tooltip.text:SetPoint("TOPLEFT", tooltip, "TOPLEFT", 8, -8)
    
    tooltip.detailsText:ClearAllPoints()
    tooltip.detailsText:SetPoint("TOPLEFT", tooltip.text, "BOTTOMLEFT", 0, -5)

    local currentRaceID = GetSelectedRace()
    local isAllowed = IsRaceClassValid(currentRaceID, classID)
    local showRestriction = not isAllowed

    tooltip.RestrictionText = tooltip.RestrictionText or tooltip:CreateFontString(nil, "OVERLAY")
    tooltip.RestrictionText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    tooltip.RestrictionText:SetJustifyH("LEFT")
    
    tooltip.FactionText = tooltip.FactionText or tooltip:CreateFontString(nil, "OVERLAY")
    tooltip.FactionText:SetFont("Fonts\\FRIZQT__.TTF", 11)
    tooltip.FactionText:SetWordWrap(true)
    tooltip.FactionText:SetJustifyH("LEFT")

    local coloredRoles = info.Roles
    coloredRoles = string.gsub(coloredRoles, "Daño cuerpo a cuerpo", "|cffff2020Daño cuerpo a cuerpo|r")
    coloredRoles = string.gsub(coloredRoles, "Daño a distancia", "|cffff2020Daño a distancia|r")
    coloredRoles = string.gsub(coloredRoles, "Tanque", "|cff0070ddTanque|r")
    coloredRoles = string.gsub(coloredRoles, "Sanador", "|cff20c000Sanador|r")
    
    if not tooltip.Roles then
        tooltip.Roles = tooltip:CreateFontString(nil, "OVERLAY")
        tooltip.Roles:SetFont("Fonts\\FRIZQT__.TTF", 11)
    end
    
    tooltip.Roles:SetText("|cFFFFFFFF"..FUNTION_INF.."|r\n\n "..coloredRoles)

    if showRestriction then
        tooltip.Roles:ClearAllPoints()
        tooltip.Roles:SetPoint("TOPLEFT", tooltip.detailsText, "BOTTOMLEFT", 0, -20)
        tooltip.Roles:Show()

        tooltip.RestrictionText:SetPoint("TOPLEFT", tooltip.Roles, "BOTTOMLEFT", 0, -20)
        tooltip.RestrictionText:SetTextColor(1, 0, 0)
        tooltip.RestrictionText:SetText(WARNING_RACE)
        tooltip.RestrictionText:Show()

        local allianceRaces, hordeRaces = GetValidRacesForClass(classID)
        
        local factionText = ""
        
        if #allianceRaces > 0 then
            factionText = ALLIANCE_RACE .. " |cFFFFFFFF" .. table.concat(allianceRaces, ", ") .. "|r"
        end
        
        if #hordeRaces > 0 then
            if factionText ~= "" then
                factionText = factionText .. "\n\n"
            end
            factionText = factionText .. "\n" .. HORDE_RACE .. " |cFFFFFFFF" .. table.concat(hordeRaces, ", ") .. "|r"
        end
        
        tooltip.FactionText:SetPoint("TOPLEFT", tooltip.RestrictionText, "BOTTOMLEFT", 0, -15)
        tooltip.FactionText:SetTextColor(1, 0.82, 0)
        tooltip.FactionText:SetText(factionText)
        tooltip.FactionText:Show()

        local maxWidth = math.max(tooltip.text:GetWidth(), tooltip.detailsText:GetWidth())
        maxWidth = math.max(maxWidth, tooltip.Roles:GetWidth())
        maxWidth = math.max(maxWidth, tooltip.RestrictionText:GetWidth())
        maxWidth = math.max(maxWidth, tooltip.FactionText:GetWidth())
        maxWidth = math.max(280, math.min(maxWidth + 16, 400))
        
        tooltip:SetWidth(maxWidth)
        tooltip.FactionText:SetWidth(maxWidth - 16)
        
        local restrictionHeight = tooltip.text:GetHeight() + 
                                tooltip.detailsText:GetHeight() + 
                                tooltip.Roles:GetHeight() +
                                tooltip.RestrictionText:GetHeight() + 
                                tooltip.FactionText:GetHeight() + 80
        
        tooltip:SetHeight(restrictionHeight)
        
    else
        tooltip.RestrictionText:Hide()
        tooltip.FactionText:Hide()

        tooltip.Roles:Show()
        tooltip.Roles:ClearAllPoints()
        tooltip.Roles:SetPoint("TOPLEFT", tooltip.detailsText, "BOTTOMLEFT", 0, -10)

        local maxWidth = math.max(tooltip.text:GetWidth(), tooltip.detailsText:GetWidth())
        maxWidth = math.max(maxWidth, tooltip.Roles:GetWidth())
        maxWidth = math.max(280, math.min(maxWidth + 16, 400))
        tooltip:SetWidth(maxWidth)

        local baseHeight = tooltip.text:GetHeight() + 
                          tooltip.detailsText:GetHeight() + 
                          tooltip.Roles:GetHeight() + 30
        
        tooltip:SetHeight(baseHeight)
    end
end

function CharacterCreate_MoveTexturesToBackground()
    for i = 1, MAX_RACES do
        local button = _G["CharacterCreateRaceButton"..i]
        if button then
            local normalTex = _G[button:GetName().."NormalTexture"]
            local pushedTex = _G[button:GetName().."PushedTexture"]
            
            if normalTex then
                normalTex:SetDrawLayer("BACKGROUND")
            end
            if pushedTex then
                pushedTex:SetDrawLayer("BACKGROUND")
            end
        end
    end

    for i = 1, MAX_CLASSES_PER_RACE do
        local button = _G["CharacterCreateClassButton"..i]
        if button then
            local normalTex = _G[button:GetName().."NormalTexture"]
            local pushedTex = _G[button:GetName().."PushedTexture"]
            
            if normalTex then
                normalTex:SetDrawLayer("BACKGROUND")
            end
            if pushedTex then
                pushedTex:SetDrawLayer("BACKGROUND")
            end
        end
    end

    local maleButton = CharacterCreateGenderButtonMale
    local femaleButton = CharacterCreateGenderButtonFemale
    
    if maleButton then
        _G[maleButton:GetName().."NormalTexture"]:SetDrawLayer("BACKGROUND")
        _G[maleButton:GetName().."PushedTexture"]:SetDrawLayer("BACKGROUND")
    end
    
    if femaleButton then
        _G[femaleButton:GetName().."NormalTexture"]:SetDrawLayer("BACKGROUND")
        _G[femaleButton:GetName().."PushedTexture"]:SetDrawLayer("BACKGROUND")
    end
end

local function CreateFactionTooltip(parent, factionName)
    local tooltip = CreateFrame("Frame", nil, parent)
    tooltip:SetBackdrop(backdrop)
    tooltip:SetFrameStrata("TOOLTIP")
    tooltip:SetBackdropColor(0, 0, 0, 0.9)
    tooltip:SetBackdropBorderColor(1, 1, 1, 1)
    tooltip:Hide()

    tooltip.title = tooltip:CreateFontString(nil, "OVERLAY")
    tooltip.title:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    tooltip.title:SetPoint("TOPLEFT", tooltip, "TOPLEFT", 10, -10)
    tooltip.title:SetTextColor(1, 0.82, 0)
    tooltip.title:SetJustifyH("LEFT")

    tooltip.description = tooltip:CreateFontString(nil, "OVERLAY")
    tooltip.description:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    tooltip.description:SetPoint("TOPLEFT", tooltip.title, "BOTTOMLEFT", 0, -8)
    tooltip.description:SetWidth(280)
    tooltip.description:SetWordWrap(true)
    tooltip.description:SetJustifyH("LEFT")
    tooltip.description:SetTextColor(0.9, 0.9, 0.9)
    
    return tooltip
end

local function UpdateTooltipSize(tooltip)
    local titleHeight = tooltip.title:GetHeight()
    local descHeight = tooltip.description:GetHeight()
    local totalHeight = titleHeight + descHeight + 30
    
    tooltip:SetHeight(totalHeight)
    tooltip:SetWidth(300)
end

function CharacterCreate_PositionRaceButtons()
    local buttonSpacing = 100
    local horizontalOffset = -10
    local verticalStart = -20

    for i = 1, 5 do
        local button = _G["CharacterCreateRaceButton"..i]
        if button then
            button:ClearAllPoints()
            
            if i == 1 then
                button:SetPoint("TOP", AllianceLogoFrame, "BOTTOM", -horizontalOffset, verticalStart)
            else
                local prevButton = _G["CharacterCreateRaceButton"..(i-1)]
                button:SetPoint("TOP", prevButton, "BOTTOM", 0, -buttonSpacing + 38)
            end
        end
    end

    for i = 6, 10 do
        local button = _G["CharacterCreateRaceButton"..i]
        if button then
            button:ClearAllPoints()
            
            if i == 6 then
                button:SetPoint("TOP", HordeLogoFrame, "BOTTOM", horizontalOffset, verticalStart)
            else
                local prevButton = _G["CharacterCreateRaceButton"..(i-1)]
                button:SetPoint("TOP", prevButton, "BOTTOM", 0, -buttonSpacing + 38)
            end
        end
    end
end

function CharacterCreate_PositionClassButtons()
    local buttonSpacing = 80
    
    for i = 1, MAX_CLASSES_PER_RACE do
        local button = _G["CharacterCreateClassButton"..i]
        if button then
            button:ClearAllPoints()
            
            if i == 1 then
                button:SetPoint("CENTER", CharacterCreateFrame, "BOTTOM", -360, 80)
            else
                local prevButton = _G["CharacterCreateClassButton"..(i-1)]
                button:SetPoint("LEFT", prevButton, "RIGHT", buttonSpacing - 38, 0)
            end
        end
    end
end

function CharacterCreate_PositionGenderButtons()
    local genderSpacing = 310 
    
    local maleButton = CharacterCreateGenderButtonMale
    local femaleButton = CharacterCreateGenderButtonFemale
    
    if maleButton then
        maleButton:ClearAllPoints()
        maleButton:SetPoint("CENTER", CharacterCreateFrame, "CENTER", -(genderSpacing/2), -250)
    end
    
    if femaleButton then
        femaleButton:ClearAllPoints()
        femaleButton:SetPoint("CENTER", CharacterCreateFrame, "CENTER", (genderSpacing/2), -250)
    end
end

function CharacterCreate_PositionAllButtons()
    CharacterCreate_PositionRaceButtons()
    CharacterCreate_PositionClassButtons()
    CharacterCreate_PositionGenderButtons()
end

function CharacterCreate_OnLoad(self)
	self:SetSequence(0)
	self:SetCamera(0)
    SetCharCustomizeFrame("CharacterCreate")
	
	CharacterCreate.numRaces = 0
	CharacterCreate.selectedRace = 0
	CharacterCreate.numClasses = 0
	CharacterCreate.selectedClass = 0
	CharacterCreate.selectedGender = 0
	CharacterCreate.personalizationMode = false
	CharacterCreate_MoveTexturesToBackground()
	CharacterCreate_SetupCustomButtons()

	for i=1, NUM_CHAR_CUSTOMIZATIONS, 1 do
		_G["CharacterCustomizationButtonFrame"..i.."Text"]:SetText(_G["CHAR_CUSTOMIZATION"..i.."_DESC"])
	end

	local backdropColor = FACTION_BACKDROP_COLOR_TABLE["Alliance"]
	CharacterCreateNameEdit:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3])
	CharacterCreateNameEdit:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6])

	CustomizationBG2 = CharacterCreateFrame:CreateTexture("CustomizationBG2", "BACKGROUND")
	CustomizationBG2:SetSize(GlueParent:GetWidth() + 2, GlueParent:GetHeight() + 6)
    CustomizationBG2:SetTexture("Interface\\Glues\\CharacterCreate\\MainShadow")
    CustomizationBG2:SetPoint("CENTER")
    CustomizationBG2:SetAlpha(0.8)

	CustomizationLogoAlliance = CharacterCreateFrame:CreateTexture("CustomizationLogoAlliance", "ARTWORK")
	CustomizationLogoAlliance:SetSize(100, 100)
    CustomizationLogoAlliance:SetTexture("Interface\\Glues\\CharacterCreate\\AllianceLogo")
    CustomizationLogoAlliance:SetPoint("TOPLEFT", -16, 16)

	CustomizationTextAlliance = CharacterCreateFrame:CreateFontString("CustomizationTextAlliance", "OVERLAY")
    CustomizationTextAlliance:SetFontObject(GlueFontNormal)
    CustomizationTextAlliance:SetText(string.upper(ALLIANCE))
    CustomizationTextAlliance:SetPoint("LEFT", CustomizationLogoAlliance, "RIGHT", -24, 0)

	AllianceTooltip = CreateFactionTooltip(CharacterCreateFrame, "Alliance")

	AllianceLogoFrame = CreateFrame("Frame", "AllianceLogoFrame", CharacterCreateFrame)
	AllianceLogoFrame:SetSize(100, 100)
	AllianceLogoFrame:SetPoint("TOPLEFT", -16, 16)
	AllianceLogoFrame:EnableMouse(true)
	
	AllianceLogoFrame:SetScript("OnEnter", function(self)
		AllianceTooltip.title:SetText(ALLIANCE)
		AllianceTooltip.description:SetText(FACTION_ALLIANCE_DESCRIPTION)
		UpdateTooltipSize(AllianceTooltip)
		AllianceTooltip:ClearAllPoints()
		AllianceTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 90, 60)
		AllianceTooltip:Show()
	end)
	
	AllianceLogoFrame:SetScript("OnLeave", function(self)
		AllianceTooltip:Hide()
	end)

	CustomizationLogoHorde = CharacterCreateFrame:CreateTexture("CustomizationLogoHorde", "ARTWORK")
	CustomizationLogoHorde:SetSize(100, 100)
    CustomizationLogoHorde:SetTexture("Interface\\Glues\\CharacterCreate\\HordeLogo")
    CustomizationLogoHorde:SetPoint("TOPRIGHT", 16, 16)

	CustomizationTextHorde = CharacterCreateFrame:CreateFontString("CustomizationTextHorde", "OVERLAY")
    CustomizationTextHorde:SetFontObject(GlueFontNormal)
    CustomizationTextHorde:SetText(string.upper(HORDE))
    CustomizationTextHorde:SetPoint("RIGHT", CustomizationLogoHorde, "LEFT", 24, 0)

	HordeTooltip = CreateFactionTooltip(CharacterCreateFrame, "Horde")

	HordeLogoFrame = CreateFrame("Frame", "HordeLogoFrame", CharacterCreateFrame)
	HordeLogoFrame:SetSize(100, 100)
	HordeLogoFrame:SetPoint("TOPRIGHT", 16, 16)
	HordeLogoFrame:EnableMouse(true)
	
	HordeLogoFrame:SetScript("OnEnter", function(self)
		HordeTooltip.title:SetText(HORDE)
		HordeTooltip.description:SetText(FACTION_HORDE_DESCRIPTION)
		UpdateTooltipSize(HordeTooltip)
		HordeTooltip:ClearAllPoints()
		HordeTooltip:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -90, 60)
		HordeTooltip:Show()
	end)
	
	HordeLogoFrame:SetScript("OnLeave", function(self)
		HordeTooltip:Hide()
	end)

    CharacterCreate_CreateGenderButtonTextures()
   CharacterCreate_PositionAllButtons()
end

function CharacterCreate_SetupCustomButtons()
    local buttons = {
        {button = CharCreateRandomizeButton, width = 36, height = 36},
        {button = CharacterCreateRandomName, width = 30, height = 30}
    }
    
    local texturePath = "Interface\\Buttons\\charactercreate.blp"
    
    for _, btnInfo in ipairs(buttons) do
        local button = btnInfo.button
        if button then
            button:SetNormalTexture(texturePath.."-Up")
            button:GetNormalTexture():SetTexCoord(0.261230469, 0.292480469, 0.890625000, 0.920410156)

            button:SetPushedTexture(texturePath.."-Down")
            button:GetPushedTexture():SetTexCoord(0.223144531, 0.253906250, 0.890625000, 0.920410156)

            button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
            button:GetHighlightTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
            button:GetHighlightTexture():SetBlendMode("ADD")

            button:SetSize(btnInfo.width, btnInfo.height)

            if button:GetFontString() then
                button:GetFontString():Hide()
            else
                button:SetText("")
            end
        end
    end
end

function CharacterCreate_TogglePersonalization()
    if (CharacterCreate.personalizationMode == false) then
        CharacterCreate.personalizationMode = true;
        PlaySound("gsCharacterSelectionCreateNew");
        CharacterCreateRaceButtonsContainer:Hide();
        CharacterCreateClassButtonsContainer:Hide();
        CharacterCreateGenderButtonsContainer:Hide();
        CustomizationLogoAlliance:Hide();
        CustomizationTextAlliance:Hide();
        CustomizationLogoHorde:Hide();
        CustomizationTextHorde:Hide();
        CharacterCreateRotateLeft:Show();
        CharacterCreateRotateRight:Show();
        CharacterCreateRotateLeft30:Show();
        CharacterCreateRotateRight30:Show();
        CharCreatePersonalizeButton:Hide();
        CharCreateOkayButton:Show();
        CharacterCreate_UpdateHairCustomization();
        CharCreateRandomizeButton:Show();
        CharacterCreateNameEdit:Show();
        CharacterCreateRandomName:Show();

        for i=1, NUM_CHAR_CUSTOMIZATIONS do
            _G["CharacterCustomizationButtonFrame"..i]:Show();
        end
    else
        CharacterCreate.personalizationMode = false;
        PlaySound("gsCharacterCreationCancel");
        CharacterCreateRaceButtonsContainer:Show();
        CharacterCreateClassButtonsContainer:Show();
        CharacterCreateGenderButtonsContainer:Show();
        CustomizationLogoAlliance:Show();
        CustomizationTextAlliance:Show();
        CustomizationLogoHorde:Show();
        CustomizationTextHorde:Show();
        CharacterCreateRotateLeft:Hide();
        CharacterCreateRotateRight:Hide();
        CharacterCreateRotateLeft30:Hide();
        CharacterCreateRotateRight30:Hide();
        CharCreateRandomizeButton:Hide();
        CharacterCreateNameEdit:Hide();
        CharacterCreateRandomName:Hide();
        CharCreatePersonalizeButton:Show();
        CharCreateOkayButton:Hide();

        for i=1, NUM_CHAR_CUSTOMIZATIONS do
            _G["CharacterCustomizationButtonFrame"..i]:Hide();
        end
    end
end

HideNameEditFrame:SetScript("OnUpdate", function(self, elapsed)
    if hideScheduled then
        CharacterCreateNameEdit:Hide()
        CharacterCreateRandomName:Hide()
        hideScheduled = false
        self:Hide()
    end
end)

function CharacterCreate_OnShow()
    CharacterCreate.personalizationMode = false;
    
    for i=1, MAX_CLASSES_PER_RACE, 1 do
        local button = _G["CharacterCreateClassButton"..i];
        button:Enable();
        SetButtonDesaturated(button, false)
    end
    for i=1, MAX_RACES, 1 do
        local button = _G["CharacterCreateRaceButton"..i];
        button:Enable();
        SetButtonDesaturated(button, false)
    end

    if ( PAID_SERVICE_TYPE ) then
        CustomizeExistingCharacter( PAID_SERVICE_CHARACTER_ID );
        CharacterCreateNameEdit:SetText( PaidChange_GetName() );
    else
        ResetCharCustomize();
        CharacterCreateNameEdit:SetText("");
        CharCreateRandomizeButton:Hide();
    end

    CharacterCreate.personalizationMode = false;
    CharCreateOkayButton:Hide();
    
    for i=1, NUM_CHAR_CUSTOMIZATIONS do
        _G["CharacterCustomizationButtonFrame"..i]:Hide();
    end

    CharacterCreateEnumerateRaces(GetAvailableRaces());
    SetCharacterRace(GetSelectedRace());
    CharacterCreateEnumerateClasses(GetAvailableClasses());
    local_,_,index = GetSelectedClass();
    SetCharacterClass(index);
    SetCharacterGender(GetSelectedSex())
    CharacterCreate_UpdateHairCustomization();
    SetCharacterCreateFacing(-15);
    CharacterChangeFixup();
    CharacterCreate_CreateGenderButtonTextures();
    CharacterCreate_UpdateButtonCheckedStates();
    CharacterCreate_ResetState();

    hideScheduled = true
    HideNameEditFrame:Show()
   CharacterCreate_PositionAllButtons()
end

function CharacterCreate_OnHide()
    PAID_SERVICE_CHARACTER_ID = nil;
    PAID_SERVICE_TYPE = nil;
    CharacterCreate_ResetState();

    for button, tooltip in pairs(raceTooltips) do
        if tooltip then tooltip:Hide() end
    end
    for button, tooltip in pairs(classTooltips) do
        if tooltip then tooltip:Hide() end
    end
    if AllianceTooltip then AllianceTooltip:Hide() end
    if HordeTooltip then HordeTooltip:Hide() end
end

function CharacterCreateFrame_OnMouseDown(button)
	if ( button == "LeftButton" ) then
		CHARACTER_CREATE_ROTATION_START_X = GetCursorPosition();
		CHARACTER_CREATE_INITIAL_FACING = GetCharacterCreateFacing();
	end
end

function CharacterCreateFrame_OnMouseUp(button)
	if ( button == "LeftButton" ) then
		CHARACTER_CREATE_ROTATION_START_X = nil
	end
end

function CharacterCreateFrame_OnUpdate()
	if ( CHARACTER_CREATE_ROTATION_START_X ) then
		local x = GetCursorPosition();
		local diff = (x - CHARACTER_CREATE_ROTATION_START_X) * CHARACTER_ROTATION_CONSTANT;
		CHARACTER_CREATE_ROTATION_START_X = GetCursorPosition();
		SetCharacterCreateFacing(GetCharacterCreateFacing() + diff);
	end
end

function CharacterCreateEnumerateRaces(...)
    CharacterCreate.numRaces = select("#", ...)/3;
    if ( CharacterCreate.numRaces > MAX_RACES ) then
        message("Too many races!  Update MAX_RACES");
        return;
    end
    local coords;
    local index = 1;
    local button;
    local gender;
    local selectedSex = GetSelectedSex();
    if ( selectedSex == SEX_MALE ) then
        gender = "MALE";
    elseif ( selectedSex == SEX_FEMALE ) then
        gender = "FEMALE";
    end
    for i=1, select("#", ...), 3 do
        coords = RACE_ICON_TCOORDS[strupper(select(i+1, ...).."_"..gender)];
        _G["CharacterCreateRaceButton"..index.."NormalTexture"]:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
        _G["CharacterCreateRaceButton"..index.."PushedTexture"]:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
        button = _G["CharacterCreateRaceButton"..index];

        local raceID = index
        local faction = _G.GetFactionForRaceID(raceID)
        local borderColor
        
        if faction == "Alliance" then
            borderColor = {0.0, 0.4, 1.0}
        else
            borderColor = {1.0, 0.0, 0.0} 
        end

        if not button.staticTexture then
            button.staticTexture = button:CreateTexture(button:GetName().."StaticTexture", "ARTWORK");
            button.staticTexture:SetTexture("Interface\\Glues\\CharacterCreate\\IconBorder_F");
            button.staticTexture:SetSize(112, 112);
            button.staticTexture:SetPoint("CENTER", 0, 0);
            button.staticTexture:SetVertexColor(borderColor[1], borderColor[2], borderColor[3]);
        else
            button.staticTexture:SetVertexColor(borderColor[1], borderColor[2], borderColor[3]);
        end

        if not button.highlightTexture then
            button.highlightTexture = button:CreateTexture(button:GetName().."HighlightTexture", "HIGHLIGHT");
            button.highlightTexture:SetTexture("Interface\\Glues\\CharacterCreate\\IconBorder_F");
            button.highlightTexture:SetAlpha(0.5);
            button.highlightTexture:SetBlendMode("ADD");
            button.highlightTexture:SetSize(112, 112);
            button.highlightTexture:SetPoint("CENTER", 0, 0);
            button.highlightTexture:SetVertexColor(borderColor[1], borderColor[2], borderColor[3]);
        else
            button.highlightTexture:SetVertexColor(borderColor[1], borderColor[2], borderColor[3]);
        end

		if not button.checkedTexture then
			button.checkedTexture = button:CreateTexture(button:GetName().."CheckedTexture", "OVERLAY");
			button.checkedTexture:SetDrawLayer("OVERLAY", 7);
			button.checkedTexture:SetTexture("Interface\\Glues\\CharacterCreate\\IconBorderRace_H");
			button.checkedTexture:SetBlendMode("ADD");
			button.checkedTexture:SetSize(112, 112);
			button.checkedTexture:SetPoint("CENTER", 0, 0);
			button.checkedTexture:Hide();
		end

		if not button.texturesMoved then
			button:SetScript("OnMouseDown", nil);
			button:SetScript("OnMouseUp", nil);
			
			button.texturesMoved = true;
		end
		
		button:Show();
		if ( select(i+2, ...) == 1 ) then
    		button.enable = true;
    		SetButtonDesaturated(button);
    		button.name = select(i, ...)
    		button.tooltip = select(i, ...);

    		button:SetScript("OnEnter", function(self)
        		if self:IsEnabled() then
            		local tooltip = GetOrCreateRaceTooltip(self)
            		tooltip:Show()
            		UpdateRaceTooltip(self, false)
        		end
    		end)

    		button:SetScript("OnLeave", function(self)
        		if self:IsEnabled() then
            		local tooltip = GetOrCreateRaceTooltip(self)
            		tooltip:Hide()
        		end
    		end)
    
    		button:SetScript("OnMouseDown", function(self, clickedButton)
        		if self:IsEnabled() and clickedButton == "RightButton" then
            		local tooltip = GetOrCreateRaceTooltip(self)
            		local isDetailed = detailedRaceTooltips[self]
            		UpdateRaceTooltip(self, not isDetailed)
        		end
    		end)
		else
    		button.enable = false;
    		SetButtonDesaturated(button, 1);
    		button.name = select(i, ...)
    		button.tooltip = _G[strupper(select(i+1, ...).."_".."DISABLED")];
		end
		index = index + 1;
	end
	for i=CharacterCreate.numRaces + 1, MAX_RACES, 1 do
		_G["CharacterCreateRaceButton"..i]:Hide();
	end
end

function CharacterCreateEnumerateClasses(...)
	CharacterCreate.numClasses = select("#", ...)/3;
	if ( CharacterCreate.numClasses > MAX_CLASSES_PER_RACE ) then
		message("Too many classes!  Update MAX_CLASSES_PER_RACE");
		return;
	end
	local coords;
	local index = 1;
	local button;
	for i=1, select("#", ...), 3 do
		coords = CLASS_ICON_TCOORDS[strupper(select(i+1, ...))];
		_G["CharacterCreateClassButton"..index.."NormalTexture"]:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
		_G["CharacterCreateClassButton"..index.."PushedTexture"]:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
		button = _G["CharacterCreateClassButton"..index];

		if not button.staticTexture then
			button.staticTexture = button:CreateTexture(button:GetName().."StaticTexture", "ARTWORK");
			button.staticTexture:SetTexture("Interface\\Glues\\CharacterCreate\\IconBorder_F1");
			button.staticTexture:SetSize(112, 112);
			button.staticTexture:SetPoint("CENTER", 0, 0);
		end

		if not button.highlightTexture then
			button.highlightTexture = button:CreateTexture(button:GetName().."HighlightTexture", "HIGHLIGHT");
			button.highlightTexture:SetTexture("Interface\\Glues\\CharacterCreate\\IconBorder_F1");
			button.highlightTexture:SetAlpha(0.5);
			button.highlightTexture:SetBlendMode("ADD");
			button.highlightTexture:SetSize(112, 112);
			button.highlightTexture:SetPoint("CENTER", 0, 0);
		end

		if not button.checkedTexture then
			button.checkedTexture = button:CreateTexture(button:GetName().."CheckedTexture", "OVERLAY");
			button.checkedTexture:SetDrawLayer("OVERLAY", 7);
			button.checkedTexture:SetTexture("Interface\\Glues\\CharacterCreate\\IconBorderRace_H");
			button.checkedTexture:SetBlendMode("ADD");
			button.checkedTexture:SetSize(112, 112);
			button.checkedTexture:SetPoint("CENTER", 0, 0);
			button.checkedTexture:Hide();
		end

		if not button.nameFrame then
			button.nameFrame = CreateFrame("Frame", nil, button);
			button.nameFrame:SetSize(112, 40);
			button.nameFrame:SetPoint("TOP", button, "BOTTOM", 0, -5);
			
			button.nameFrame.text = button.nameFrame:CreateFontString(nil, "OVERLAY");
			button.nameFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
			button.nameFrame.text:SetPoint("CENTER", 0, 0);
			button.nameFrame.text:SetTextColor(1, 1, 1);
			button.nameFrame.text:SetJustifyH("CENTER");
			button.nameFrame.text:SetJustifyV("CENTER");
			button.nameFrame.text:SetWidth(112);
			button.nameFrame.text:SetWordWrap(true);
			button.nameFrame.text:SetHeight(40);
		end

		if not button.texturesMoved then
			button:SetScript("OnMouseDown", nil);
			button:SetScript("OnMouseUp", nil);
			
			button.texturesMoved = true;
		end
		
		button:Show();

		local className = select(i, ...);

		if className == "Caballero de la Muerte" then
			button.nameFrame.text:SetText("Caballero\nde la Muerte");
		elseif string.len(className) > 12 then
			local spacePos = string.find(className, " ", 6)
			if spacePos then
				local firstPart = string.sub(className, 1, spacePos - 1);
				local secondPart = string.sub(className, spacePos + 1);
				button.nameFrame.text:SetText(firstPart .. "\n" .. secondPart);
			else
				local midPoint = math.floor(string.len(className) / 2);
				local firstPart = string.sub(className, 1, midPoint);
				local secondPart = string.sub(className, midPoint + 1);
				button.nameFrame.text:SetText(firstPart .. "-\n" .. secondPart);
			end
		else
			button.nameFrame.text:SetText(className);
		end

		if ( (select(i+2, ...) == 1) and (IsRaceClassValid(CharacterCreate.selectedRace, index)) ) then
			button.enable = true;
			button:Enable();
			SetButtonDesaturated(button);
			button.name = select(i, ...)
			button.tooltip = select(i, ...);
			_G["CharacterCreateClassButton"..index.."DisableTexture"]:Hide();

			button.nameFrame.text:SetTextColor(1, 1, 1);

			button:SetScript("OnEnter", function(self)
				if self:IsEnabled() then
					local tooltip = GetOrCreateClassTooltip(self)
					tooltip:Show()
					UpdateClassTooltip(self, false)
				end
			end)

			button:SetScript("OnLeave", function(self)
				if self:IsEnabled() then
					local tooltip = GetOrCreateClassTooltip(self)
					tooltip:Hide()
				end
			end)
			
			button:SetScript("OnMouseDown", function(self, clickedButton)
				if self:IsEnabled() and clickedButton == "RightButton" then
					local tooltip = GetOrCreateClassTooltip(self)
					local isDetailed = detailedClassTooltips[self]
					UpdateClassTooltip(self, not isDetailed)
				end
			end)
		else
			button.enable = false;
			button:Disable();
			SetButtonDesaturated(button, 1);
			button.name = select(i, ...)
			button.tooltip = _G[strupper(select(i+1, ...).."_".."DISABLED")];
			_G["CharacterCreateClassButton"..index.."DisableTexture"]:Show();

			button.nameFrame.text:SetTextColor(0.5, 0.5, 0.5);

			button:SetScript("OnEnter", function(self)
				local tooltip = GetOrCreateClassTooltip(self)
				tooltip:Show()
				UpdateClassTooltip(self, false)
			end)

			button:SetScript("OnLeave", function(self)
				local tooltip = GetOrCreateClassTooltip(self)
				tooltip:Hide()
			end)
		end

		index = index + 1;
	end

	for i=CharacterCreate.numClasses + 1, MAX_CLASSES_PER_RACE, 1 do
		_G["CharacterCreateClassButton"..i]:Hide();
	end
end

function CharacterCreate_CreateGenderButtonTextures()
    local maleButton = CharacterCreateGenderButtonMale;
    if maleButton and not maleButton.highlightTexture then
        maleButton.staticTexture = maleButton:CreateTexture(maleButton:GetName().."StaticTexture", "ARTWORK");
        maleButton.staticTexture:SetTexture("Interface\\Glues\\CharacterCreate\\IconBorder_F1");
        maleButton.staticTexture:SetSize(86, 86);
        maleButton.staticTexture:SetPoint("CENTER", 0, 0);
        
        maleButton.highlightTexture = maleButton:CreateTexture(maleButton:GetName().."HighlightTexture", "HIGHLIGHT");
        maleButton.highlightTexture:SetTexture("Interface\\Glues\\CharacterCreate\\IconBorder_F1");
        maleButton.highlightTexture:SetAlpha(0.5);
        maleButton.highlightTexture:SetBlendMode("ADD");
        maleButton.highlightTexture:SetSize(86, 86);
        maleButton.highlightTexture:SetPoint("CENTER", 0, 0);
        
        maleButton.checkedTexture = maleButton:CreateTexture(maleButton:GetName().."CheckedTexture", "OVERLAY");
        maleButton.checkedTexture:SetDrawLayer("OVERLAY", 7);
        maleButton.checkedTexture:SetTexture("Interface\\Glues\\CharacterCreate\\IconBorderRace_H");
        maleButton.checkedTexture:SetBlendMode("ADD");
        maleButton.checkedTexture:SetSize(86, 86);
        maleButton.checkedTexture:SetPoint("CENTER", 0, 0);
        maleButton.checkedTexture:Hide();

        maleButton:SetScript("OnMouseDown", nil);
        maleButton:SetScript("OnMouseUp", nil);
    end

    local femaleButton = CharacterCreateGenderButtonFemale;
    if femaleButton and not femaleButton.highlightTexture then
        femaleButton.staticTexture = femaleButton:CreateTexture(femaleButton:GetName().."StaticTexture", "ARTWORK");
        femaleButton.staticTexture:SetTexture("Interface\\Glues\\CharacterCreate\\IconBorder_F1");
        femaleButton.staticTexture:SetSize(86, 86);
        femaleButton.staticTexture:SetPoint("CENTER", 0, 0);
        
        femaleButton.highlightTexture = femaleButton:CreateTexture(femaleButton:GetName().."HighlightTexture", "HIGHLIGHT");
        femaleButton.highlightTexture:SetTexture("Interface\\Glues\\CharacterCreate\\IconBorder_F1");
        femaleButton.highlightTexture:SetAlpha(0.5);
        femaleButton.highlightTexture:SetBlendMode("ADD");
        femaleButton.highlightTexture:SetSize(86, 86);
        femaleButton.highlightTexture:SetPoint("CENTER", 0, 0);
        
        femaleButton.checkedTexture = femaleButton:CreateTexture(femaleButton:GetName().."CheckedTexture", "OVERLAY");
        femaleButton.checkedTexture:SetDrawLayer("OVERLAY", 7);
        femaleButton.checkedTexture:SetTexture("Interface\\Glues\\CharacterCreate\\IconBorderRace_H");
        femaleButton.checkedTexture:SetBlendMode("ADD");
        femaleButton.checkedTexture:SetSize(86, 86);
        femaleButton.checkedTexture:SetPoint("CENTER", 0, 0);
        femaleButton.checkedTexture:Hide();

        femaleButton:SetScript("OnMouseDown", nil);
        femaleButton:SetScript("OnMouseUp", nil);
    end
end

function SetCharacterRace(id)
	CharacterCreate.selectedRace = id;
	local selectedButton;
	for i=1, CharacterCreate.numRaces, 1 do
    	local button = _G["CharacterCreateRaceButton"..i];
    	if ( i == id ) then
        	if button.nameFrame and button.nameFrame.text then
            	button.nameFrame.text:SetText(button.name);
        	end
        	button:SetChecked(1);
        	selectedButton = button;
    	else
        	if button.nameFrame and button.nameFrame.text then
            	button.nameFrame.text:SetText("");
        	end
        	button:SetChecked(0);
    	end
	end

	CharacterCreate_UpdateButtonCheckedStates();

	local name, faction = GetFactionForRace(CharacterCreate.selectedRace);

	local race, fileString = GetNameForRace();

	CharacterCreateRaceLabel:SetText(race);
	fileString = strupper(fileString);
	if ( GetSelectedSex() == SEX_MALE ) then
		gender = "MALE";
	else
		gender = "FEMALE";
	end
	local coords = RACE_ICON_TCOORDS[fileString.."_"..gender];
	CharacterCreateRaceIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
	local raceText = _G["RACE_INFO_"..fileString];
	local abilityIndex = 1;
	local tempText = _G["ABILITY_INFO_"..fileString..abilityIndex];
	abilityText = "";
	while ( tempText ) do
		abilityText = abilityText..tempText.."\n\n";
		abilityIndex = abilityIndex + 1;
		tempText = _G["ABILITY_INFO_"..fileString..abilityIndex];
	end

	CharacterCreateRaceScrollFrameScrollBar:SetValue(0);
	CharacterCreateRaceText:SetText(GetFlavorText("RACE_INFO_"..strupper(fileString), GetSelectedSex()).."|n|n");
	if ( abilityText and abilityText ~= "" ) then
		CharacterCreateRaceAbilityText:SetText(abilityText);
	else
		CharacterCreateRaceAbilityText:SetText("");
	end

	local backdropColor = FACTION_BACKDROP_COLOR_TABLE[faction];
	local frame;
	for index, value in pairs(FRAMES_TO_BACKDROP_COLOR) do
		frame = _G[value];
		frame:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6]);
	end
	CharacterCreateConfigurationBackground:SetVertexColor(backdropColor[4], backdropColor[5], backdropColor[6]);

	local backgroundFilename = GetCreateBackgroundModel();
	SetBackgroundModel(CharacterCreate, backgroundFilename);
end

function SetCharacterClass(id)
	CharacterCreate.selectedClass = id;
	for i=1, CharacterCreate.numClasses, 1 do
		local button = _G["CharacterCreateClassButton"..i];
		if ( i == id ) then
			CharacterCreateClassName:SetText(button.name);
			button:SetChecked(1);
		else
			button:SetChecked(0);
		end
	end

	CharacterCreate_UpdateButtonCheckedStates();
	
	local className, classFileName, _, tank, healer, damage = GetSelectedClass();
	local abilityIndex = 0;
	local tempText = _G["CLASS_INFO_"..classFileName..abilityIndex];
	abilityText = "";
	while ( tempText ) do
		abilityText = abilityText..tempText.."\n\n";
		abilityIndex = abilityIndex + 1;
		tempText = _G["CLASS_INFO_"..classFileName..abilityIndex];
	end
	local coords = CLASS_ICON_TCOORDS[classFileName];
	CharacterCreateClassIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
	CharacterCreateClassLabel:SetText(className);
	CharacterCreateClassRolesText:SetText(abilityText);	
	CharacterCreateClassText:SetText(GetFlavorText("CLASS_"..strupper(classFileName), GetSelectedSex()).."|n|n");
	CharacterCreateClassScrollFrameScrollBar:SetValue(0);
end

function CharacterCreate_OnChar()
end

function CharacterCreate_UpdateButtonCheckedStates()
    for i=1, MAX_RACES, 1 do
        local button = _G["CharacterCreateRaceButton"..i];
        if button and button:IsShown() and button.checkedTexture then
            if button:GetChecked() then
                button.checkedTexture:Show();
            else
                button.checkedTexture:Hide();
            end
        end
    end

    for i=1, MAX_CLASSES_PER_RACE, 1 do
        local button = _G["CharacterCreateClassButton"..i];
        if button and button:IsShown() and button.checkedTexture then
            if button:GetChecked() then
                button.checkedTexture:Show();
            else
                button.checkedTexture:Hide();
            end
        end
    end

    local maleButton = CharacterCreateGenderButtonMale;
    local femaleButton = CharacterCreateGenderButtonFemale;
    
    if maleButton and maleButton.checkedTexture then
        if maleButton:GetChecked() then
            maleButton.checkedTexture:Show();
        else
            maleButton.checkedTexture:Hide();
        end
    end
    
    if femaleButton and femaleButton.checkedTexture then
        if femaleButton:GetChecked() then
            femaleButton.checkedTexture:Show();
        else
            femaleButton.checkedTexture:Hide();
        end
    end
end

function CharacterCreate_OnKeyDown(key)
    if ( key == "ESCAPE" ) then
        if (CharacterCreate.personalizationMode == true) then
            CharacterCreate_TogglePersonalization();
        else
            CharacterCreate_Back();
        end
    elseif ( key == "ENTER" ) then
        CharacterCreate_Okay();
    elseif ( key == "PRINTSCREEN" ) then
        Screenshot();
    end
end

function CharacterCreate_UpdateModel(self)
	UpdateCustomizationScene();
	self:AdvanceTime();
end

function CharacterCreate_Okay()
    if ( PAID_SERVICE_TYPE ) then
        GlueDialog_Show("CONFIRM_PAID_SERVICE");
    else
        CreateCharacter(CharacterCreateNameEdit:GetText());
    end

    CharacterCreate.personalizationMode = false;
    PlaySound("gsCharacterCreationCreateChar");
end

function CharacterCreate_Back()
    if (CharacterCreate.personalizationMode == true) then
        CharacterCreate_TogglePersonalization();
        CharacterCreate.personalizationMode = false;
        return;
    end

    CharacterCreate.personalizationMode = false;
    PlaySound("gsCharacterCreationCancel");
    SetGlueScreen("charselect");
end

function CharacterClass_OnClick(id)
    PlaySound("gsCharacterCreationClass");
    local _,_,currClass = GetSelectedClass();
    if ( currClass ~= id and IsRaceClassValid(GetSelectedRace(), id) ) then
        SetSelectedClass(id);
        SetCharacterClass(id);
        SetCharacterRace(GetSelectedRace());
        CharacterChangeFixup();

        CharacterCreate_UpdateButtonCheckedStates();
    end
end

function CharacterRace_OnClick(self, id)
    PlaySound("gsCharacterCreationClass");
    if ( not self:GetChecked() ) then
        self:SetChecked(1);
        return;
    end
    if ( GetSelectedRace() ~= id ) then
        SetSelectedRace(id);
        SetCharacterRace(id);
        SetSelectedSex(GetSelectedSex());
        SetCharacterCreateFacing(-15);
        CharacterCreateEnumerateClasses(GetAvailableClasses());
        local _,_,classIndex = GetSelectedClass();
        if ( PAID_SERVICE_TYPE ) then
            classIndex = PaidChange_GetCurrentClassIndex();
        end
        SetCharacterClass(classIndex);

        CharacterCreate_UpdateHairCustomization();
            
        CharacterChangeFixup();

        CharacterCreate_UpdateButtonCheckedStates();
    end
end

function SetCharacterGender(sex)
	local gender;
	SetSelectedSex(sex);
	if ( sex == SEX_MALE ) then
		gender = "MALE";
		CharacterCreateGender:SetText(MALE);
		CharacterCreateGenderButtonMale:SetChecked(1);
		CharacterCreateGenderButtonFemale:SetChecked(nil);
	elseif ( sex == SEX_FEMALE ) then
		gender = "FEMALE";
		CharacterCreateGender:SetText(FEMALE);
		CharacterCreateGenderButtonMale:SetChecked(nil);
		CharacterCreateGenderButtonFemale:SetChecked(1);
	end

	CharacterCreateEnumerateRaces(GetAvailableRaces());
	CharacterCreateEnumerateClasses(GetAvailableClasses());
 	SetCharacterRace(GetSelectedRace());
	
	local _,_,classIndex = GetSelectedClass();
	if ( PAID_SERVICE_TYPE ) then
		classIndex = PaidChange_GetCurrentClassIndex();
	end
	SetCharacterClass(classIndex);

	CharacterCreate_UpdateHairCustomization();

	local race, fileString = GetNameForRace();
	CharacterCreateRaceLabel:SetText(race);
	fileString = strupper(fileString);
	local coords = RACE_ICON_TCOORDS[fileString.."_"..gender];
	CharacterCreateRaceIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
	
	CharacterChangeFixup();

	CharacterCreate_UpdateButtonCheckedStates();
end

function CharacterCreate_ResetState()
    CharacterCreate.personalizationMode = false;
    CharacterCreateRaceButtonsContainer:Show();
    CharacterCreateClassButtonsContainer:Show();
    CharacterCreateGenderButtonsContainer:Show();
    CustomizationLogoAlliance:Show();
    CustomizationTextAlliance:Show();
    CustomizationLogoHorde:Show();
    CustomizationTextHorde:Show();
    CharacterCreateRotateLeft:Hide();
    CharacterCreateRotateRight:Hide();
    CharacterCreateRotateLeft30:Hide();
    CharacterCreateRotateRight30:Hide();
    CharCreateRandomizeButton:Hide();
    CharacterCreateNameEdit:Hide();
    CharacterCreateRandomName:Hide();
    CharCreatePersonalizeButton:Show();
    CharCreateOkayButton:Hide();
    
    for i=1, NUM_CHAR_CUSTOMIZATIONS do
        _G["CharacterCustomizationButtonFrame"..i]:Hide();
    end
end

function CharacterCustomization_Left(id)
	PlaySound("gsCharacterCreationLook");
	CycleCharCustomization(id, -1);
end

function CharacterCustomization_Right(id)
	PlaySound("gsCharacterCreationLook");
	CycleCharCustomization(id, 1);
end

function CharacterCreate_Randomize()
	PlaySound("gsCharacterCreationLook");
	RandomizeCharCustomization();
end

function CharacterCreateRotateRight_OnUpdate(self)
	if ( self:GetButtonState() == "PUSHED" ) then
		SetCharacterCreateFacing(GetCharacterCreateFacing() + CHARACTER_FACING_INCREMENT);
	end
end

function CharacterCreateRotateLeft_OnUpdate(self)
	if ( self:GetButtonState() == "PUSHED" ) then
		SetCharacterCreateFacing(GetCharacterCreateFacing() - CHARACTER_FACING_INCREMENT);
	end
end

function CharacterCreate_RotateLeft30()
    local currentFacing = GetCharacterCreateFacing();
    SetCharacterCreateFacing(currentFacing - CHARACTER_ROTATION_INCREMENT);
end

function CharacterCreate_RotateRight30()
    local currentFacing = GetCharacterCreateFacing();
    SetCharacterCreateFacing(currentFacing + CHARACTER_ROTATION_INCREMENT);
end

function CharacterCreate_UpdateHairCustomization()
	CharacterCustomizationButtonFrame3Text:SetText(_G["HAIR_"..GetHairCustomization().."_STYLE"]);
	CharacterCustomizationButtonFrame4Text:SetText(_G["HAIR_"..GetHairCustomization().."_COLOR"]);
	CharacterCustomizationButtonFrame5Text:SetText(_G["FACIAL_HAIR_"..GetFacialHairCustomization()]);		
end

function SetButtonDesaturated(button, desaturated, r, g, b)
	if ( not button ) then
		return;
	end
	local icon = button:GetNormalTexture();
	if ( not icon ) then
		return;
	end
	local shaderSupported = icon:SetDesaturated(desaturated);

	if ( not desaturated ) then
		r = 1.0;
		g = 1.0;
		b = 1.0;
	elseif ( not r or not shaderSupported ) then
		r = 0.5;
		g = 0.5;
		b = 0.5;
	end
	
	icon:SetVertexColor(r, g, b);
end

function GetFlavorText(tagname, sex)
	local primary, secondary;
	if ( sex == SEX_MALE ) then
		primary = "";
		secondary = "_FEMALE";
	else
		primary = "_FEMALE";
		secondary = "";
	end
	local text = _G[tagname..primary];
	if ( (text == nil) or (text == "") ) then
		text = _G[tagname..secondary];
	end
	return text;
end

function CharacterCreate_DeathKnightSwap(self)
	local _, classFilename = GetSelectedClass();
	if ( classFilename == "DEATHKNIGHT" ) then
		if (self.currentModel ~= "DEATHKNIGHT") then
			self.currentModel = "DEATHKNIGHT";
			self:SetNormalTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Up-Blue");
			self:SetPushedTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Down-Blue");
			self:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight-Blue");
		end
	else
		if (self.currentModel == "DEATHKNIGHT") then
			self.currentModel = nil;
			self:SetNormalTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Up");
			self:SetPushedTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Down");
			self:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight");
		end
	end
end

function CharacterChangeFixup()
	if ( PAID_SERVICE_TYPE ) then
		for i=1, MAX_CLASSES_PER_RACE, 1 do
			if (CharacterCreate.selectedClass ~= i) then
				local button = _G["CharacterCreateClassButton"..i];
				button:Disable();
				SetButtonDesaturated(button, true)
			end
		end

		for i=1, MAX_RACES, 1 do
			local allow = false;
			if ( PAID_SERVICE_TYPE == PAID_FACTION_CHANGE ) then
				local faction = GetFactionForRace(PaidChange_GetCurrentRaceIndex());
				if ( (i == PaidChange_GetCurrentRaceIndex()) or ((GetFactionForRace(i) ~= faction) and (IsRaceClassValid(i,CharacterCreate.selectedClass))) ) then
					allow = true;
				end
			elseif ( PAID_SERVICE_TYPE == PAID_RACE_CHANGE ) then
				local faction = GetFactionForRace(PaidChange_GetCurrentRaceIndex());
				if ( (i == PaidChange_GetCurrentRaceIndex()) or ((GetFactionForRace(i) == faction) and (IsRaceClassValid(i,CharacterCreate.selectedClass))) ) then
					allow = true
				end
			elseif ( PAID_SERVICE_TYPE == PAID_CHARACTER_CUSTOMIZATION ) then
				if ( i == CharacterCreate.selectedRace ) then
					allow = true
				end
			end
			if (not allow) then
				local button = _G["CharacterCreateRaceButton"..i];
				button:Disable();
				SetButtonDesaturated(button, true)
			end
		end
	end
end