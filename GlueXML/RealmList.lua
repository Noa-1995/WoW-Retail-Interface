-- ============================================================================
-- Autora: Noa
-- ============================================================================
REALM_BUTTON_HEIGHT = 16;
MAX_REALMS_DISPLAYED = 18;
MAX_REALM_CATEGORY_TABS = 8;

local TEXTURE_SIZE = 36

local REALM_BACKGROUNDS = {
    ["RealmListRealmButton1"] = "Interface\\GluesVideo\\Assets\\RealmSelection\\Realm1.blp",
    ["RealmListRealmButton2"] = "Interface\\GluesVideo\\Assets\\RealmSelection\\Realm2.blp",
}

local logoAnimationInProgress = false

local realmListLogoFrame = nil
local realmListLogo = nil

local logoAnimationInProgress = false

local realmListLogoFrame = nil
local realmListLogo = nil

local function InitializeRealmListLogo(self)
    if not realmListLogoFrame then
        realmListLogoFrame = CreateFrame("Frame", nil, self)
        realmListLogoFrame:SetSize(285, 285)
        realmListLogoFrame:SetPoint("CENTER", self, "CENTER", 0, 0)
        realmListLogoFrame:Hide()
        
        realmListLogo = realmListLogoFrame:CreateTexture("RealmListLogo", "ARTWORK")
        realmListLogo:SetTexture(" ")
        realmListLogo:SetAllPoints(realmListLogoFrame)
        
        realmListLogoFrame.zoomDirection = 1
        realmListLogoFrame.zoomSpeed = 0.1
        realmListLogoFrame.minSize = 250
        realmListLogoFrame.maxSize = 280
        realmListLogoFrame.currentSize = 250
        
        realmListLogoFrame:SetScript("OnUpdate", function(self, elapsed)
            self.currentSize = self.currentSize + (self.zoomDirection * self.zoomSpeed)
            
            if self.currentSize >= self.maxSize then
                self.currentSize = self.maxSize
                self.zoomDirection = -1
            elseif self.currentSize <= self.minSize then
                self.currentSize = self.minSize
                self.zoomDirection = 1
            end
            
            self:SetSize(self.currentSize, self.currentSize)
        end)
    end
end

local function ResetRealmListLogoAnimation()
    logoAnimationInProgress = false
    if realmListLogoFrame then
        realmListLogoFrame:Hide()
        realmListLogoFrame:SetScript("OnUpdate", nil)
    end
end

local function ShowRealmListLogo()
    if logoAnimationInProgress or not realmListLogoFrame then
        return
    end
    
    logoAnimationInProgress = true
    realmListLogoFrame:Show()
    
    local startY = 480
    local endY = 380
    local startSize = 285
    local minSize = 250
    local maxSize = 285
    local midSize = (minSize + maxSize) / 2

    local animationTime = 0
    local currentSize = startSize
    local zoomPhaseTime = 0
    local zoomSpeed = 0.5
    local smoothingProgress = -1
    
    realmListLogoFrame:SetPoint("TOP", RealmList, "CENTER", 0, startY)
    realmListLogoFrame:SetAlpha(0)
    realmListLogoFrame:SetSize(startSize, startSize)
    
    realmListLogoFrame:SetScript("OnUpdate", function(self, elapsed)
        animationTime = animationTime + elapsed
        
        if animationTime <= 1.0 then
            local progress = animationTime / 1.0
            local currentY = startY - (startY - endY) * progress
            local currentAlpha = progress
            
            self:SetPoint("TOP", RealmList, "CENTER", 0, currentY)
            self:SetAlpha(currentAlpha)
            
        elseif animationTime <= 1.5 then
            local transitionProgress = (animationTime - 1.0) / 0.5
            currentSize = startSize - (startSize - minSize) * transitionProgress
            self:SetSize(currentSize, currentSize)
            
            smoothingProgress = 0
            
        else
            if smoothingProgress < 1 then
                smoothingProgress = smoothingProgress + elapsed * 5  -- 5 = 1/0.2
                if smoothingProgress > 1 then smoothingProgress = 1 end
                
                zoomPhaseTime = zoomPhaseTime + elapsed * zoomSpeed * smoothingProgress
            else
                zoomPhaseTime = zoomPhaseTime + elapsed * zoomSpeed
            end
            
            local oscillation = math.sin(zoomPhaseTime * math.pi * 2)
            oscillation = oscillation * 0.5 + 0.5
            
            currentSize = minSize + (maxSize - minSize) * oscillation
            
            local currentWidth, currentHeight = self:GetSize()
            local smoothingFactor = smoothingProgress < 1 and 0.05 or 0.1
            local newWidth = currentWidth + (currentSize - currentWidth) * smoothingFactor
            local newHeight = currentHeight + (currentSize - currentHeight) * smoothingFactor
            
            self:SetSize(newWidth, newHeight)
        end
    end)
end

local function CreateRealmButtonBorder(button)
    if button.borderFrame then return button.borderFrame end
    
    local border = CreateFrame("Frame", nil, button, BackdropTemplateMixin and "BackdropTemplate")
    border:SetFrameLevel(button:GetFrameLevel() + 1)
    
    border:SetBackdrop({
        edgeFile = "Interface\\tooltips\\ui-tooltip-border-maw",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    border:SetBackdropBorderColor(1, 1, 1, 1)
    
    local backgroundContainer = CreateFrame("Frame", nil, border)
    backgroundContainer:SetAllPoints(border)
    backgroundContainer:SetFrameLevel(border:GetFrameLevel() - 1)
    
    local TEXTURE_OFFSET_X = 4
    local TEXTURE_OFFSET_Y = 4
    
    local background = backgroundContainer:CreateTexture(nil, "BACKGROUND")
    background:SetPoint("TOPLEFT", backgroundContainer, "TOPLEFT", TEXTURE_OFFSET_X, -TEXTURE_OFFSET_Y)
    background:SetPoint("BOTTOMRIGHT", backgroundContainer, "BOTTOMRIGHT", -TEXTURE_OFFSET_X, TEXTURE_OFFSET_Y)
    background:SetTexture(REALM_BACKGROUNDS[button:GetName()] or "Interface\\GluesVideo\\Assets\\RealmSelection\\Realm1.blp")
    
    border:SetPoint("TOPLEFT", button, "TOPLEFT", -30, 20)
    border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 30, -350)
    border:Show()
    
    local currentScale = 1
    local targetScale = 1
    local isMouseOverBackground = false
    
    local function IsMouseOverBackground()
        local x, y = GetCursorPosition()
        local scale = button:GetEffectiveScale()
        x = x / scale
        y = y / scale
    
        local left = backgroundContainer:GetLeft()
        local right = backgroundContainer:GetRight()
        local top = backgroundContainer:GetTop()
        local bottom = backgroundContainer:GetBottom()
    
        return x >= left and x <= right and y <= top and y >= bottom
    end
    
    local function UpdateBackgroundZoom(elapsed)
        if isMouseOverBackground then
            targetScale = 1.1
        else
            targetScale = 1
        end
        
        if math.abs(currentScale - targetScale) > 0.001 then
            currentScale = currentScale + (targetScale - currentScale) * (elapsed * 2)
            background:SetTexCoord(
                0.5 - (0.5 / currentScale),
                0.5 + (0.5 / currentScale),
                0.5 - (0.5 / currentScale),
                0.5 + (0.5 / currentScale)
            )
        end
    end
    
    button:SetScript("OnUpdate", function(_, elapsed)
        isMouseOverBackground = IsMouseOverBackground()
        UpdateBackgroundZoom(elapsed)
    end)
    
    local texture1 = button:CreateTexture(nil, "ARTWORK")
    texture1:SetSize(TEXTURE_SIZE, TEXTURE_SIZE)
    texture1:SetPoint("TOPLEFT", button, "TOPLEFT", -30, -45)

    local texture2 = button:CreateTexture(nil, "ARTWORK")
    texture2:SetSize(TEXTURE_SIZE, TEXTURE_SIZE)
    texture2:SetPoint("TOP", texture1, "BOTTOM", 0, 3)

    local texture3 = button:CreateTexture(nil, "ARTWORK")
    texture3:SetSize(TEXTURE_SIZE, TEXTURE_SIZE)
    texture3:SetPoint("TOP", texture2, "BOTTOM", 0, 4)

    local texture4 = button:CreateTexture(nil, "ARTWORK")
    texture4:SetSize(TEXTURE_SIZE, TEXTURE_SIZE)
    texture4:SetPoint("TOP", texture3, "BOTTOM", 0, 4)
    
    local buttonName = button:GetName()
    if buttonName == "RealmListRealmButton1" then
        texture1:SetTexture("Interface\\GluesVideo\\Assets\\RealmSelection\\RealmIcon\\TypeGame1")
        texture2:SetTexture("Interface\\GluesVideo\\Assets\\RealmSelection\\RealmIcon\\Characters1")
        texture3:SetTexture("Interface\\GluesVideo\\Assets\\RealmSelection\\RealmIcon\\Population1")
        texture4:SetTexture("Interface\\GluesVideo\\Assets\\RealmSelection\\RealmIcon\\Expansion1")
    elseif buttonName == "RealmListRealmButton2" then
        texture1:SetTexture("Interface\\GluesVideo\\Assets\\RealmSelection\\RealmIcon\\TypeGame2")
        texture2:SetTexture("Interface\\GluesVideo\\Assets\\RealmSelection\\RealmIcon\\Characters2")
        texture3:SetTexture("Interface\\GluesVideo\\Assets\\RealmSelection\\RealmIcon\\Population2")
        texture4:SetTexture("Interface\\GluesVideo\\Assets\\RealmSelection\\RealmIcon\\Expansion2")
    else
        texture1:SetTexture("Interface\\Icons\\inv_misc_questionmark")
        texture2:SetTexture("Interface\\Icons\\inv_misc_questionmark")
        texture3:SetTexture("Interface\\Icons\\inv_misc_questionmark")
        texture4:SetTexture("Interface\\Icons\\inv_misc_questionmark")
    end
    
    button.borderFrame = border
    return border
end

function RealmList_OnLoad(self)
    self:RegisterEvent("OPEN_REALM_LIST");
    self.currentRealm = 0;
    self.offset = 0;
end

function RealmList_OnEvent(self, event)
	if ( event == "OPEN_REALM_LIST" ) then
		if ( self:IsShown() ) then
			RealmListUpdate();
		else
			self:Show();
		end
	end
end

function RealmListUpdate()
    if ( not RealmList.selectedCategory ) then
        RealmList.selectedCategory = 1;
    end
    
    RealmList.refreshTime = RealmListUpdateRate();

    RealmList_UpdateTabs(GetRealmCategories());

    local numRealms = GetNumRealms(RealmList.selectedCategory);
    local name, numCharacters, invalidRealm, currentRealm, pvp, rp, load, locked;
    local realmIndex;
    local isFull;
    local major, minor, revision, build, type;

    RealmListOkButton:Hide();
    RealmListHighlight:Hide();
    for i=1, MAX_REALMS_DISPLAYED, 1 do
        realmIndex = RealmList.offset + i;
        local button = _G["RealmListRealmButton"..i];
        local acceptButton = _G["RealmListRealmButton"..i.."AcceptButton"]; 
        
        if ( realmIndex > numRealms ) then
            button:Hide();
        else
            name, numCharacters, invalidRealm, realmDown, currentRealm, pvp, rp, load, locked, major, minor, revision = GetRealmInfo(RealmList.selectedCategory, realmIndex);

            if ( not name ) then
                button:Hide();
            else
                local pvpText = _G["RealmListRealmButton"..i.."PVP"] or button:CreateFontString("$parentPVP", "ARTWORK", "GlueFontHighlightSmall");
                local loadText = _G["RealmListRealmButton"..i.."Load"] or button:CreateFontString("$parentLoad", "ARTWORK", "GlueFontHighlightSmall");
                local players = _G["RealmListRealmButton"..i.."Players"] or button:CreateFontString("$parentPlayers", "ARTWORK", "GlueFontHighlightSmall");

                if ( pvp and rp ) then
                    pvpText:SetText(RPPVP_PARENTHESES);
                    pvpText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                elseif ( rp ) then
                    pvpText:SetText(RP_PARENTHESES);
                    pvpText:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
                elseif ( pvp ) then
                    pvpText:SetText(PVP_PARENTHESES);
                    pvpText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
                else
                    pvpText:SetText(GAMETYPE_NORMAL);
                    pvpText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                end

                isFull = nil;
                if ( realmDown ) then
                    loadText:SetText(REALM_DOWN);
                    loadText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
                elseif ( locked ) then
                    loadText:SetText(REALM_LOCKED);
                    loadText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
                elseif ( load == -3.0 ) then
                    loadText:SetText(LOAD_RECOMMENDED);
                    loadText:SetTextColor(BLUE_FONT_COLOR.r, BLUE_FONT_COLOR.g, BLUE_FONT_COLOR.b);
                elseif ( load == -2.0 ) then
                    loadText:SetText(LOAD_NEW);
                    loadText:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
                elseif ( load == 2.0 ) then
                    loadText:SetText(LOAD_FULL);
                    loadText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
                    isFull = 1;
                elseif ( load > 0 ) then
                    loadText:SetText(LOAD_HIGH);
                    loadText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
                elseif ( load < 0 ) then
                    loadText:SetText(LOAD_LOW);
                    loadText:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
                else
                    loadText:SetText(LOAD_MEDIUM);
                    loadText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                end

                if ( numCharacters > 0 ) then
                    players:SetText(numCharacters);
                else
                    players:SetText(" 0");
                end

                pvpText:ClearAllPoints();
                pvpText:SetPoint("TOPLEFT", button, "TOPLEFT", 10, -40);
                pvpText:SetWidth(150);
                pvpText:SetJustifyH("LEFT");

                players:ClearAllPoints();
                players:SetPoint("TOPLEFT", pvpText, "BOTTOMLEFT", 0, -5);
                players:SetWidth(150);
                players:SetJustifyH("LEFT");

                loadText:ClearAllPoints();
                loadText:SetPoint("TOPLEFT", players, "BOTTOMLEFT", 0, -5);
                loadText:SetWidth(150);
                loadText:SetJustifyH("LEFT");

                if (major) then
                    button:SetText(name.."\n("..major.."."..minor.."."..revision..")");
                else
                    button:SetText(name);
                end

                CreateRealmButtonBorder(button);
                button:Show();
                button:SetID(realmIndex);
                button.name = name;

                if ( realmDown ) then
                    button:Disable();
                else
                    button:Enable();
                end
                
                if (pvp and rp) then       -- RPPVP
                    pvpText:SetPoint("TOPLEFT", button, "TOPLEFT", 118, -57);
                    pvpText:SetWidth(180);
                elseif (rp) then           -- RP
                    pvpText:SetPoint("TOPLEFT", button, "TOPLEFT", 118, -57);
                    pvpText:SetWidth(150);
                elseif (pvp) then          -- PVP
                    pvpText:SetPoint("TOPLEFT", button, "TOPLEFT", 118, -57);
                    pvpText:SetWidth(150);
                else                        -- Normal (PVE)
                    pvpText:SetPoint("TOPLEFT", button, "TOPLEFT", 118, -57);
                    pvpText:SetWidth(150);
                end

                players:SetPoint("TOPLEFT", pvpText, "BOTTOMLEFT", -35, -20);
                players:SetWidth(150);
                
                if (load == -3.0) then       -- "Recomendado"
                    loadText:SetPoint("TOPLEFT", players, "BOTTOMLEFT", 0, -20);
                    loadText:SetWidth(180);
                elseif (load == -2.0) then   -- "Nuevo"
                    loadText:SetPoint("TOPLEFT", players, "BOTTOMLEFT", 0, -20);
                    loadText:SetWidth(150);
                elseif (load == 2.0) then    -- "Lleno"
                    loadText:SetPoint("TOPLEFT", players, "BOTTOMLEFT", 0, -20);
                    loadText:SetWidth(150);
                elseif (load > 0) then       -- "Alto"
                    loadText:SetPoint("TOPLEFT", players, "BOTTOMLEFT", 0, -20);
                    loadText:SetWidth(150);
                elseif (load < 0) then       -- "Bajo"
                    loadText:SetPoint("TOPLEFT", players, "BOTTOMLEFT", 0, -20);
                    loadText:SetWidth(150);
                else                          -- "Medio" (valor por defecto)
                    loadText:SetPoint("TOPLEFT", players, "BOTTOMLEFT", -5, -20);
                    loadText:SetWidth(150);
                end

                pvpText:SetJustifyH("LEFT");
                players:SetJustifyH("LEFT");
                loadText:SetJustifyH("LEFT");

                local expansionText = _G["RealmListRealmButton"..i.."ExpansionText"] or button:CreateFontString("$parentExpansionText", "ARTWORK", "GlueFontHighlightSmall");
                local expansionNames = {
                    ["RealmListRealmButton1"] = "Wrath of the Lich King",
                    ["RealmListRealmButton2"] = "Dragonflight",
                };
                local buttonName = "RealmListRealmButton"..i;
                local expansionName = expansionNames[buttonName] or "Clásico";

                if string.len(expansionName) > 23 then
                    local midPoint = math.floor(string.len(expansionName) / 2)
                    local spacePos = string.find(expansionName, " ", midPoint) or midPoint
                    local line1 = string.sub(expansionName, 1, spacePos)
                    local line2 = string.sub(expansionName, spacePos + 1)
                    expansionText:SetText(line1.."\n"..line2)
                else
                    expansionText:SetText(expansionName)
                end

                expansionText:SetTextColor(0.9, 0.8, 0.5);
                expansionText:ClearAllPoints();
                expansionText:SetPoint("LEFT", _G["RealmListRealmButton"..i.."ExpansionLabel"], "RIGHT", -5, 0);
                expansionText:SetJustifyH("LEFT");

                if string.len(expansionName) > 23 then
                    expansionText:SetHeight(24)
                else
                    expansionText:SetHeight(12)
                end

                if ( realmDown ) then
                    button:SetNormalFontObject(RealmDownNormal);
                    button:SetHighlightFontObject(RealmDownHighlight);
                else
                    if ( invalidRealm ) then
                        button:SetNormalFontObject(RealmInvalidNormal);
                        button:SetHighlightFontObject(RealmInvalidHighlight);
                    else
                        if ( numCharacters > 0 ) then
                            button:SetNormalFontObject(RealmCharactersNormal);
                            button:SetHighlightFontObject(GlueFontHighlightLeft);
                        else
                            button:SetNormalFontObject(RealmNoCharactersNormal);
                            button:SetHighlightFontObject(GlueFontHighlightLeft);
                        end
                    end
                end
				
                CreateRealmButtonBorder(button)
                button:Show();
                button:SetID(realmIndex);
                button.name = name;

                if ( realmDown ) then
                    button:Disable();
                else
                    button:Enable();
                end
                
                if ( RealmList.selectedName ) then
                    if ( name == RealmList.selectedName ) then
                        RealmList.currentRealm = realmIndex;
                        button:LockHighlight();
                        RealmListOkButton:Enable();
                        
                        if ( isFull and numCharacters == 0 ) then
                            RealmList.showRealmIsFullDialog = 1;
                        else
                            RealmList.showRealmIsFullDialog = nil;
                        end
                        
                        if ( realmDown ) then
                            RealmListOkButton:Disable();
                        else
                            RealmListOkButton:Enable();
                        end
                    else
                        button:UnlockHighlight();
                    end
                else
                    if ( currentRealm == 1 ) then
                        RealmList.currentRealm = realmIndex;
                        button:LockHighlight();
                        if ( realmDown ) then
                            RealmListOkButton:Disable();
                        else
                            RealmListOkButton:Enable();
                        end
                    else
                        button:UnlockHighlight();
                    end
                end            
            end
        end
    end

    RealmList.selectedName = nil;
    GlueScrollFrame_Update(RealmListScrollFrame, numRealms, MAX_REALMS_DISPLAYED, REALM_BUTTON_HEIGHT, RealmListHighlight, 557,  587);
end

function RealmList_UpdateTabs(...)
	local numTabs = select("#", ...);
	local tab;
	for i=1, MAX_REALM_CATEGORY_TABS do
		tab = _G["RealmListTab"..i];
		if ( not tab ) then
			tab = CreateFrame("Button", "RealmListTab"..i, RealmListBackground, "RealmListTabButtonTemplate");
			tab:SetID(i);
			tab:SetPoint("LEFT", "RealmListTab"..(i-1), "RIGHT", -15, 0);
		end
		tab.disabled = nil;
		if ( numTabs == 1 ) then
			tab:Hide();
		elseif ( i <= numTabs ) then
			tab:SetText(select(i, ...));
			GlueTemplates_TabResize(0, tab);
			tab:Show();
			if (IsInvalidTournamentRealmCategory(i)) then
				tab:SetDisabledFontObject("GlueFontDisableSmall");
				tab.disabled = true;
			else
				tab:SetDisabledFontObject("GlueFontHighlightSmall");
			end
		else
			tab:Hide();
		end
	end
	GlueTemplates_SetNumTabs(RealmList, numTabs);
	if ( not GlueTemplates_GetSelectedTab(RealmList) ) then
		GlueTemplates_SetTab(RealmList, 1);
	end
end

function RealmList_OnKeyDown(key)
	if ( key == "ESCAPE" ) then
		RealmList_OnCancel();
	elseif ( key == "ENTER" ) then
		RealmList_OnOk();
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	end
end

function RealmList_OnOk()
	RealmList:Hide();
	-- If trying to join a Full realm then popup a dialog
	if ( RealmList.showRealmIsFullDialog ) then
		GlueDialog_Show("REALM_IS_FULL");
		return;
	end
	if ( RealmList.currentRealm > 0 ) then
		ChangeRealm(RealmList.selectedCategory , RealmList.currentRealm);
	end
end

function RealmList_OnCancel()
	RealmList:Hide();
	RealmListDialogCancelled();
	local serverName, isPVP, isRP, isDown = GetServerName();

	if ( (GetNumRealms(RealmList.selectedCategory) == 0) or (isDown) ) then
		SetGlueScreen("realmwizard");
	end
end

function RealmSelectButton_OnClick(self, id)
	if ( IsInvalidLocale( RealmList.selectedCategory ) ) then
		--Display popup explaining locale specific realms
		GlueDialog_Show("REALM_LOCALE_WARNING");
	else
		RealmList.refreshTime = RealmListUpdateRate();
		RealmList.currentRealm = id;
		RealmList.selectedName = self.name;
		RealmListUpdate();
	end
end

function RealmSelectButton_OnDoubleClick(self, id)
	if ( IsInvalidLocale( RealmList.selectedCategory ) ) then
		--Display popup explaining locale specific realms
		GlueDialog_Show("REALM_LOCALE_WARNING");
	else
		RealmList.currentRealm = id;
		RealmList.selectedName = self.name;
		RealmList_OnOk();
	end
end

function RealmListScrollFrame_OnVerticalScroll(self, offset)
	RealmList.refreshTime = RealmListUpdateRate();
	local scrollbar = _G[self:GetName().."ScrollBar"];
	scrollbar:SetValue(offset);
	RealmList.offset = floor((offset / REALM_BUTTON_HEIGHT) + 0.5);
	RealmListUpdate();
end

function RealmList_OnShow(self)
    InitializeRealmListLogo(self)
    ShowRealmListLogo()
    
    RealmListUpdate();
    self.refreshTime = RealmListUpdateRate();
    local selectedCategory = GetSelectedCategory();
    if ( selectedCategory == 0 ) then
        selectedCategory = 1;
    end
    local button = _G["RealmListTab"..selectedCategory];
    if ( button ) then
        RealmListTab_OnClick(button);
        GlueTemplates_SetTab(RealmList, selectedCategory);
    end
end

function RealmList_OnHide()
    CancelRealmListQuery()
    ResetRealmListLogoAnimation()
end

function RealmList_OnUpdate(self, elapsed)
	if ( self.refreshTime ) then
		self.refreshTime = self.refreshTime - elapsed;
		if ( self.refreshTime <= 0 ) then
			self.refreshTime = nil;
			RequestRealmList();
		end
	end

	-- Account Msg stuff
	if ( (ACCOUNT_MSG_NUM_AVAILABLE > 0) and not GlueDialog:IsShown() ) then
		if ( ACCOUNT_MSG_HEADERS_LOADED ) then
			if ( ACCOUNT_MSG_BODY_LOADED ) then
				local dialogString = AccountMsg_GetHeaderSubject( ACCOUNT_MSG_CURRENT_INDEX ).."\n\n"..AccountMsg_GetBody();
				GlueDialog_Show("ACCOUNT_MSG", dialogString);
			end
		end
	end
end

function RealmListTab_OnClick(tab)
	if ( tab.disabled ) then
		if ( IsTournamentRealmCategory(tab:GetID()) ) then
			--Display popup explaining tournament realms
--			RealmHelpFrame:Show();
			GlueDialog_Show("REALM_TOURNAMENT_WARNING");
		end

		local button = _G["RealmListTab"..RealmList.selectedCategory];
		if ( button ) then
			button:Click();
		end
		return;
	end
	RealmList.selectedCategory = tab:GetID();
	RealmListUpdate();
end

function RealmHelpText_OnShow(self)
	self:SetText("<html><body><p>" .. string.format(REALM_HELP_FRAME_TEXT, REALM_HELP_FRAME_URL) .. "</p></body></html>");
end