-- [[ Autora: Noa ]] --

CHARACTER_SELECT_ROTATION_START_X = nil;
CHARACTER_SELECT_INITIAL_FACING = nil;

CHARACTER_ROTATION_CONSTANT = 0.6;

MAX_CHARACTERS_DISPLAYED = 8;
MAX_CHARACTERS_PER_REALM = 8;


function CharacterSelect_OnLoad(self) 
    REALM_SIRION = GetServerName();
    
    self:SetSequence(0);
    self:SetCamera(0);

    self.createIndex = 0;
    self.selectedIndex = 0;
    self.selectLast = 0;
    self.currentModel = nil;
    self:RegisterEvent("ADDON_LIST_UPDATE");
    self:RegisterEvent("CHARACTER_LIST_UPDATE");
    self:RegisterEvent("UPDATE_SELECTED_CHARACTER");
    self:RegisterEvent("SELECT_LAST_CHARACTER");
    self:RegisterEvent("SELECT_FIRST_CHARACTER");
    self:RegisterEvent("SUGGEST_REALM");
    self:RegisterEvent("FORCE_RENAME_CHARACTER");
    SetCharSelectModelFrame("CharacterSelect");

    CharacterSelectCharacterFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    });

    CharacterSelectCharacterFrame:SetBackdropColor(0, 0, 0)

    SelectBorroso = 1;
    CharacterSelect_OnEventO();
    if CharSelectTooltip then
        CharSelectTooltipText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
        CharSelectTooltipText:SetTextColor(1, 1, 1)
        CharSelectTooltip:SetBackdropColor(0, 0, 0, 0.9)
        CharSelectTooltip:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    end
end

function CharacterSelect_OnShow()
	-- request account data times from the server (so we know if we should refresh keybindings, etc...)
	ReadyForAccountDataTimes()
	
	local CurrentModel = CharacterSelect.currentModel;

	if ( CurrentModel ) then
		PlayGlueAmbience(GlueAmbienceTracks[strupper(CurrentModel)], 4.0);
	end

	UpdateAddonButton();

	local serverName, isPVP, isRP = GetServerName();
	local connected = IsConnectedToServer();
	local serverType = "";
	if ( serverName ) then
		if( not connected ) then
			serverName = serverName.."\n("..SERVER_DOWN..")";
		end
		if ( isPVP ) then
			if ( isRP ) then
				serverType = RPPVP_PARENTHESES;
			else
				serverType = PVP_PARENTHESES;
			end
		elseif ( isRP ) then
			serverType = RP_PARENTHESES;
		end
		CharSelectRealmName:SetText(serverName.." "..serverType);
		CharSelectRealmName:Show();
	else
		CharSelectRealmName:Hide();
	end

	if ( connected ) then
		GetCharacterListUpdate();
	else
		UpdateCharacterList();
	end

	-- Gameroom billing stuff (For Korea and China only)
	if ( SHOW_GAMEROOM_BILLING_FRAME ) then
		local paymentPlan, hasFallBackBillingMethod, isGameRoom = GetBillingPlan();
		if ( paymentPlan == 0 ) then
			-- No payment plan
			GameRoomBillingFrame:Hide();
			CharacterSelectRealmSplitButton:ClearAllPoints();
			CharacterSelectRealmSplitButton:SetPoint("TOP", CharacterSelectLogo, "BOTTOM", 0, -5);
		else
			local billingTimeLeft = GetBillingTimeRemaining();
			-- Set default text for the payment plan
			local billingText = _G["BILLING_TEXT"..paymentPlan];
			if ( paymentPlan == 1 ) then
				-- Recurring account
				billingTimeLeft = ceil(billingTimeLeft/(60 * 24));
				if ( billingTimeLeft == 1 ) then
					billingText = BILLING_TIME_LEFT_LAST_DAY;
				end
			elseif ( paymentPlan == 2 ) then
				-- Free account
				if ( billingTimeLeft < (24 * 60) ) then
					billingText = format(BILLING_FREE_TIME_EXPIRE, billingTimeLeft.." "..MINUTES_ABBR);
				end				
			elseif ( paymentPlan == 3 ) then
				-- Fixed but not recurring
				if ( isGameRoom == 1 ) then
					if ( billingTimeLeft <= 30 ) then
						billingText = BILLING_GAMEROOM_EXPIRE;
					else
						billingText = format(BILLING_FIXED_IGR, MinutesToTime(billingTimeLeft, 1));
					end
				else
					-- personal fixed plan
					if ( billingTimeLeft < (24 * 60) ) then
						billingText = BILLING_FIXED_LASTDAY;
					else
						billingText = format(billingText, MinutesToTime(billingTimeLeft));
					end	
				end
			elseif ( paymentPlan == 4 ) then
				-- Usage plan
				if ( isGameRoom == 1 ) then
					-- game room usage plan
					if ( billingTimeLeft <= 600 ) then
						billingText = BILLING_GAMEROOM_EXPIRE;
					else
						billingText = BILLING_IGR_USAGE;
					end
				else
					-- personal usage plan
					if ( billingTimeLeft <= 30 ) then
						billingText = BILLING_TIME_LEFT_30_MINS;
					else
						billingText = format(billingText, billingTimeLeft);
					end
				end
			end
			-- If fallback payment method add a note that says so
			if ( hasFallBackBillingMethod == 1 ) then
				billingText = billingText.."\n\n"..BILLING_HAS_FALLBACK_PAYMENT;
			end
			GameRoomBillingFrameText:SetText(billingText);
			GameRoomBillingFrame:SetHeight(GameRoomBillingFrameText:GetHeight() + 26);
			GameRoomBillingFrame:Show();
			CharacterSelectRealmSplitButton:ClearAllPoints();
			CharacterSelectRealmSplitButton:SetPoint("TOP", GameRoomBillingFrame, "BOTTOM", 0, -10);
		end
	end
	
	if( IsTrialAccount() ) then
		CharacterSelectUpgradeAccountButton:Show();
	else
		CharacterSelectUpgradeAccountButton:Hide();
	end

	-- fadein the character select ui
	GlueFrameFadeIn(CharacterSelectUI, CHARACTER_SELECT_FADE_IN)

	RealmSplitCurrentChoice:Hide();
	RequestRealmSplitInfo();

	--Clear out the addons selected item
	GlueDropDownMenu_SetSelectedValue(AddonCharacterDropDown, ALL);
end

function CharacterSelect_OnHide()
	CharacterDeleteDialog:Hide();
	CharacterRenameDialog:Hide();
	if ( DeclensionFrame ) then
		DeclensionFrame:Hide();
	end
	SERVER_SPLIT_STATE_PENDING = -1;
end

function CharacterSelect_OnUpdate(elapsed)
	if ( SERVER_SPLIT_STATE_PENDING > 0 ) then
		CharacterSelectRealmSplitButton:Show();

		if ( SERVER_SPLIT_CLIENT_STATE > 0 ) then
			RealmSplit_SetChoiceText();
			RealmSplitPending:SetPoint("TOP", RealmSplitCurrentChoice, "BOTTOM", 0, -10);
		else
			RealmSplitPending:SetPoint("TOP", CharacterSelectRealmSplitButton, "BOTTOM", 0, 0);
			RealmSplitCurrentChoice:Hide();
		end

		if ( SERVER_SPLIT_STATE_PENDING > 1 ) then
			CharacterSelectRealmSplitButton:Disable();
			CharacterSelectRealmSplitButtonGlow:Hide();
			RealmSplitPending:SetText( SERVER_SPLIT_PENDING );
		else
			CharacterSelectRealmSplitButton:Enable();
			CharacterSelectRealmSplitButtonGlow:Show();
			local datetext = SERVER_SPLIT_CHOOSE_BY.."\n"..SERVER_SPLIT_DATE;
			RealmSplitPending:SetText( datetext );
		end

		if ( SERVER_SPLIT_SHOW_DIALOG and not GlueDialog:IsShown() ) then
			SERVER_SPLIT_SHOW_DIALOG = false;
			local dialogString = format(SERVER_SPLIT,SERVER_SPLIT_DATE);
			if ( SERVER_SPLIT_CLIENT_STATE > 0 ) then
				local serverChoice = RealmSplit_GetFormatedChoice(SERVER_SPLIT_REALM_CHOICE);
				local stringWithDate = format(SERVER_SPLIT,SERVER_SPLIT_DATE);
				dialogString = stringWithDate.."\n\n"..serverChoice;
				GlueDialog_Show("SERVER_SPLIT_WITH_CHOICE", dialogString);
			else
				GlueDialog_Show("SERVER_SPLIT", dialogString);
			end
		end
	else
		CharacterSelectRealmSplitButton:Hide();
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

function CharacterSelect_OnKeyDown(self,key)
	if ( key == "ESCAPE" ) then
		CharacterSelect_Exit();
	elseif ( key == "ENTER" ) then
		CharacterSelect_EnterWorld();
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	elseif ( key == "UP" or key == "LEFT" ) then
		local numChars = GetNumCharacters();
		if ( numChars > 1 ) then
			if ( self.selectedIndex > 1 ) then
				CharacterSelect_SelectCharacter(self.selectedIndex - 1);
			else
				CharacterSelect_SelectCharacter(numChars);
			end
		end
	elseif ( arg1 == "DOWN" or arg1 == "RIGHT" ) then
		local numChars = GetNumCharacters();
		if ( numChars > 1 ) then
			if ( self.selectedIndex < GetNumCharacters() ) then
				CharacterSelect_SelectCharacter(self.selectedIndex + 1);
			else
				CharacterSelect_SelectCharacter(1);
			end
		end
	end
end

function CharacterSelect_OnEventO()
    local numChars = GetNumCharacters();
    local index = 1;
    local coords;
    
    if ( SelectBorroso == 0 ) then
        CharSelectCharacterName:SetAlpha(0);
        CharacterSelectCharacterFrame:SetAlpha(0);
        CharacterSelectCharacterFrame:SetPoint("TOPRIGHT", 5000, -8);
        CharSelectCharacterName2:SetPoint("CENTER", 330, 100);
        CharSelectCharacterName2:SetAlpha(1);
        CharSelectCharacterName2:SetFont("Fonts\\FRIZQT__.ttf", 43, "OUTLINE");
        CharSelectCharacterName2:Show();
        CharSelectCharacterName3:SetPoint("TOP", "CharSelectCharacterName2", 0, 120);
        CharSelectCharacterName3:SetFont("Fonts\\FRIZQT__.ttf", 83, "OUTLINE");
        CharSelectCharacterName3:Show();
        CharacterSelectRotateLeft:SetAlpha(0);
        CharacterSelectRotateRight:SetAlpha(0);
        CharacterSelectAddonsButton:SetAlpha(0);
        CharSelectEnterWorldButton:SetAlpha(0);
        CharacterSelectBackButton:SetAlpha(0);
        CharacterSelectAddonsButton:Disable();
        CharacterSelectBackButton:Disable();
        DesenfoBoton:SetText(" ");
        DesenfoBoton2:Hide();
		OptionsButton2:Hide();
        CharSelectChangeRealmButton:Hide();
		CharacterSelectDeleteButton:Hide();
		CharacterSelectWebButton:Hide();
        
    elseif ( SelectBorroso == 1 ) then
        CharSelectCharacterName:SetAlpha(1);
        CharacterSelectCharacterFrame:SetAlpha(1);
        CharacterSelectCharacterFrame:SetPoint("TOPRIGHT", -5, -42);
        CharSelectCharacterName2:SetPoint("CENTER", 330, 100);
        CharSelectCharacterName2:SetFont("Fonts\\FRIZQT__.ttf", 43, "OUTLINE");
        CharSelectCharacterName2:SetAlpha(0);
        CharSelectCharacterName2:Hide();
        CharSelectCharacterName3:SetPoint("TOP", "CharSelectCharacterName2", 0, 120);
        CharSelectCharacterName3:SetFont("Fonts\\FRIZQT__.ttf", 83, "OUTLINE");
        CharSelectCharacterName3:Hide();
        CharacterSelectRotateLeft:SetAlpha(1);
        CharacterSelectRotateRight:SetAlpha(1);
        CharacterSelectAddonsButton:SetAlpha(1);
        CharSelectEnterWorldButton:SetAlpha(1);
        CharacterSelectBackButton:SetAlpha(1);
        CharacterSelectAddonsButton:Enable();
        CharacterSelectBackButton:Enable();
        DesenfoBoton:SetText(" ");
        DesenfoBoton2:Show();
		OptionsButton2:Show();
        CharSelectChangeRealmButton:Show();
		CharacterSelectDeleteButton:Show();
		CharacterSelectWebButton:Show();
    end
    PlaySound("igMainMenuOptionCheckBoxOn")
end

function CharacterSelect_OnEventO2()
    if (SelectBorroso2 == 0) then
        CharacterSelectCharacterFrame:Hide();
        if CharacterSelectDeleteButton then
            CharacterSelectDeleteButton:Hide();
        end
        
    elseif (SelectBorroso2 == 1) then
        CharacterSelectCharacterFrame:Show();
        if CharacterSelectDeleteButton then
            CharacterSelectDeleteButton:Show();
        end
    end
    PlaySound("igMainMenuOptionCheckBoxOn");
end

function CharacterSelect_OnEvent(self, event, ...)
	if ( event == "ADDON_LIST_UPDATE" ) then
		UpdateAddonButton();
	elseif ( event == "CHARACTER_LIST_UPDATE" ) then
		UpdateCharacterList();
		CharSelectCharacterName:SetText(GetCharacterInfo(self.selectedIndex));
	elseif ( event == "UPDATE_SELECTED_CHARACTER" ) then
		local index = ...;
		if ( index == 0 ) then
			CharSelectCharacterName:SetText("");
		else
			CharSelectCharacterName:SetText(GetCharacterInfo(index));
			self.selectedIndex = index;
		end
		UpdateCharacterSelection(self);
	elseif ( event == "SELECT_LAST_CHARACTER" ) then
		self.selectLast = 1;
	elseif ( event == "SELECT_FIRST_CHARACTER" ) then
		CharacterSelect_SelectCharacter(1, 1);
	elseif ( event == "SUGGEST_REALM" ) then
		local category, id = ...;
		local name = GetRealmInfo(category, id);
		if ( name ) then
			SetGlueScreen("charselect");
			ChangeRealm(category, id);
		else
			if ( RealmList:IsShown() ) then
				RealmListUpdate();
			else
				RealmList:Show();
			end
		end
	elseif ( event == "FORCE_RENAME_CHARACTER" ) then
		local message = ...;
		CharacterRenameDialog:Show();
		CharacterRenameText1:SetText(_G[message]);
	end
end

function CharacterSelect_UpdateModel(self)
	UpdateSelectionCustomizationScene();
	self:AdvanceTime();
end

function UpdateCharacterSelection(self)
	for i=1, MAX_CHARACTERS_DISPLAYED, 1 do
		_G["CharSelectCharacterButton"..i]:UnlockHighlight();
	end

	local index = self.selectedIndex;
	if ( (index > 0) and (index <= MAX_CHARACTERS_DISPLAYED) )then
		_G["CharSelectCharacterButton"..index]:LockHighlight();
	end
end

function UpdateCharacterList()
    local numChars = GetNumCharacters();
    local index = 1;
    local coords;

    for i = 1, MAX_CHARACTERS_DISPLAYED do
        local button = _G["CharSelectCharacterButton"..i];
        button:Show();
    end
    
    _G["CharacterSelectCharacterFrame"]:SetHeight(620);

    local GENERAL_BACKGROUND = {
        texture = "Interface\\Glues\\CharacterSelect\\uicharacterselectglues2x",
        coords = {0.656250000, 0.965820313, 0.123046875, 0.217285156}
    };

    for i = 1, MAX_CHARACTERS_DISPLAYED do
        local button = _G["CharSelectCharacterButton"..i];
        
        local generalBg = _G["CharSelectCharacterButton"..i.."GeneralBackground"];
        if generalBg then generalBg:Hide(); end
        
        local background = _G["CharSelectCharacterButton"..i.."Background"];
        if background then background:Hide(); end
        
        local factionIcon = _G["CharSelectCharacterButton"..i.."FactionIcon"];
        if factionIcon then factionIcon:Hide(); end
        
        local nameText = _G["CharSelectCharacterButton"..i.."ButtonTextName"];
        if nameText then nameText:SetText(""); end
        
        local levelText = _G["CharSelectCharacterButton"..i.."ButtonTextLevel"];
        if levelText then levelText:SetText(""); end
        
        local classText = _G["CharSelectCharacterButton"..i.."ButtonTextClass"];
        if classText then classText:SetText(""); end
        
        local zoneText = _G["CharSelectCharacterButton"..i.."ButtonTextZone"];
        if zoneText then zoneText:SetText(""); end
        
        local statusText = _G["CharSelectCharacterButton"..i.."ButtonTextStatus"];
        if statusText then statusText:SetText(""); end

        local defaultBg = _G["CharSelectCharacterButton"..i.."DefaultBackground"];
        if defaultBg then defaultBg:Hide(); end
    end

    local CLASS_COLORS = {
        -- EspaÃ±ol
        ["GUERRERO"]="|cffC79C6E",["GUERRERA"]="|cffC79C6E",
        ["PALADÃN"]="|cffF58CBA",
        ["CAZADOR"]="|cffABD473",["CAZADORA"]="|cffABD473",
        ["PÃCARO"]="|cffFFF569",["PÃCARA"]="|cffFFF569",
        ["SACERDOTE"]="|cffFFFFFF",["SACERDOTISA"]="|cffFFFFFF",
        ["CABALLERO DE LA MUERTE"]="|cffC41F3B",
        ["CHAMÃN"]="|cff0070DE",
        ["MAGO"]="|cff69CCF0",["MAGA"]="|cff69CCF0",
        ["BRUJO"]="|cff9482C9",["BRUJA"]="|cff9482C9",
        ["DRUIDA"]="|cffFF7D0A",
        -- English
        ["WARRIOR"]="|cffC79C6E",
        ["PALADIN"]="|cffF58CBA",
        ["HUNTER"]="|cffABD473",
        ["ROGUE"]="|cffFFF569",
        ["PRIEST"]="|cffFFFFFF",
        ["DEATHKNIGHT"]="|cffC41F3B",
        ["SHAMAN"]="|cff0070DE",
        ["MAGE"]="|cff69CCF0",
        ["WARLOCK"]="|cff9482C9",
        ["DRUID"]="|cffFF7D0A"
    };

    local function GetCharacterFaction(race)
        local normalizedRace = string.upper(race or ""):gsub("[%s%-']", "")
        local allianceRaces = {
            -- EspaÃ±ol
            ["HUMANO"] = true, ["HUMANA"] = true, ["ENANO"] = true, ["ENANA"] = true, ["ELFODELANOCHE"] = true, ["ELFADELANOCHE"] = true, ["GNOMO"] = true, ["GNOMA"] = true, ["DRAENEI"] = true,
            -- English
            ["HUMAN"] = true, ["DWARF"] = true, ["NIGHTELF"] = true, ["GNOME"] = true, ["DRAENEI"] = true
        }

        if allianceRaces[normalizedRace] then
            return "Alliance"
        else
            return "Horde"
        end
    end

    local FACTION_ICONS = {
        ["Alliance"] = "Interface\\Glues\\CharacterSelect\\AllianceLogo",
        ["Horde"] = "Interface\\Glues\\CharacterSelect\\HordeLogo"
    };

    for i=1, numChars, 1 do
        local name, race, class, level, zone, sex, ghost, PCC, PRC, PFC = GetCharacterInfo(i);
        local button = _G["CharSelectCharacterButton"..index];
    
        if ( not name ) then
            button:SetText("ERROR - Contact Admin");
        else
            if ( not zone ) then
                zone = "";
            end
        
            local faction = GetCharacterFaction(race);

            local defaultBg = _G["CharSelectCharacterButton"..index.."DefaultBackground"];
            if defaultBg then defaultBg:Hide(); end

            local generalBg = _G["CharSelectCharacterButton"..index.."GeneralBackground"];
            if not generalBg then
                generalBg = button:CreateTexture("CharSelectCharacterButton"..index.."GeneralBackground", "BACKGROUND", nil, 1);
            end
            generalBg:ClearAllPoints();
            generalBg:SetPoint("CENTER", button, "CENTER", -22, 1);
            generalBg:SetSize(243, 62);
            generalBg:SetTexture(GENERAL_BACKGROUND.texture);
            generalBg:SetTexCoord(unpack(GENERAL_BACKGROUND.coords));
            generalBg:Show();

            local background = _G["CharSelectCharacterButton"..index.."Background"];
            if not background then
                background = button:CreateTexture("CharSelectCharacterButton"..index.."Background", "OVERLAY", nil, 2);
            end
            background:ClearAllPoints();
            background:SetPoint("CENTER", button, "CENTER", -35, 0);
            background:SetSize(205, 55);
            background:Show();

            local factionIcon = _G["CharSelectCharacterButton"..index.."FactionIcon"];
            if not factionIcon then
                factionIcon = button:CreateTexture("CharSelectCharacterButton"..index.."FactionIcon", "OVERLAY", nil, 3);
            end
            factionIcon:ClearAllPoints();
            factionIcon:SetPoint("TOPLEFT", button, "TOPLEFT", 170, -5);
            factionIcon:SetSize(60, 60);
        
            if faction == "Alliance" then
                factionIcon:SetTexture(FACTION_ICONS["Alliance"]);
            else
                factionIcon:SetTexture(FACTION_ICONS["Horde"]);
            end
            factionIcon:Show();

            -- Nombre
            local nameText = _G["CharSelectCharacterButton"..index.."ButtonTextName"];
            if not nameText then
                nameText = button:CreateFontString("CharSelectCharacterButton"..index.."ButtonTextName", "OVERLAY", "GlueFontNormal");
            end
            nameText:ClearAllPoints();
            nameText:SetPoint("TOPLEFT", button, "TOPLEFT", 0, -8);
            nameText:SetText(name);

            -- Nivel
            local levelText = _G["CharSelectCharacterButton"..index.."ButtonTextLevel"];
            if not levelText then
                levelText = button:CreateFontString("CharSelectCharacterButton"..index.."ButtonTextLevel", "OVERLAY", "GlueFontNormalSmall");
            end
            levelText:ClearAllPoints();

            -- Separador entre nivel y clase
            local separatorText = _G["CharSelectCharacterButton"..index.."ButtonTextSeparator"];
            if not separatorText then
                separatorText = button:CreateFontString("CharSelectCharacterButton"..index.."ButtonTextSeparator", "OVERLAY", "GlueFontNormalSmall");
            end
            separatorText:ClearAllPoints();
            separatorText:SetPoint("TOPLEFT", button, "TOPLEFT", 20, -25);
            separatorText:SetText("|cffffffff-|r");

            if level < 10 then
                levelText:SetPoint("TOPLEFT", button, "TOPLEFT", 5, -25);
                levelText:SetText("|cffffffff"..level.."|r");
            else
                levelText:SetPoint("TOPLEFT", button, "TOPLEFT", 0, -25);
                levelText:SetText("|cffffffff"..level.."|r");
            end

            -- Clase
            local classText = _G["CharSelectCharacterButton"..index.."ButtonTextClass"];
            if not classText then
                classText = button:CreateFontString("CharSelectCharacterButton"..index.."ButtonTextClass", "OVERLAY", "GlueFontNormalSmall");
            end
            classText:ClearAllPoints();
            classText:SetPoint("TOPLEFT", button, "TOPLEFT", 30, -25);
        
            classText:SetWidth(150);
            classText:SetJustifyH("LEFT");
            classText:SetWordWrap(false);
        
            local classColor = CLASS_COLORS[strupper(class)] or "|cffFFFFFF";
            classText:SetText(classColor..class.."|r");
        
            -- Zona
            local zoneText = _G["CharSelectCharacterButton"..index.."ButtonTextZone"];
            if not zoneText then
                zoneText = button:CreateFontString("CharSelectCharacterButton"..index.."ButtonTextZone", "OVERLAY", "GlueFontNormalSmall");
            end
            zoneText:ClearAllPoints();
            zoneText:SetPoint("TOPLEFT", button, "TOPLEFT", 0, -40);
        
            zoneText:SetWidth(180);
            zoneText:SetJustifyH("LEFT");
            zoneText:SetWordWrap(false);
        
            zoneText:SetText(zone);
			zoneText:SetTextColor(0.3, 0.3, 0.3);

            -- Estado: Vivo/Muerto
            local statusText = _G["CharSelectCharacterButton"..index.."ButtonTextStatus"];
            if not statusText then
                statusText = button:CreateFontString("CharSelectCharacterButton"..index.."ButtonTextStatus", "OVERLAY", "GlueFontNormalSmall");
            end
            statusText:ClearAllPoints();
        
            if ghost then
                statusText:SetPoint("TOPLEFT", button, "TOPLEFT", 170, -5);
                statusText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
                statusText:SetTextColor(1, 0.2, 0.2);
                statusText:SetText("[Muerto]");
            else
                statusText:SetPoint("TOPLEFT", button, "TOPLEFT", 182, -5);
                statusText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
                statusText:SetTextColor(0.2, 1, 0.2);
                statusText:SetText("[Vivo]");
            end
        end
        
        button:Show();

        _G["CharSelectCharacterCustomize"..index]:Hide();
        _G["CharSelectRaceChange"..index]:Hide();
        _G["CharSelectFactionChange"..index]:Hide();
        if (PFC) then
            _G["CharSelectFactionChange"..index]:Show();
        elseif (PRC) then
            _G["CharSelectRaceChange"..index]:Show();
        elseif (PCC) then
            _G["CharSelectCharacterCustomize"..index]:Show();
        end

        index = index + 1;
        if (index > MAX_CHARACTERS_DISPLAYED) then
            break;
        end
    end

    for i = index, MAX_CHARACTERS_DISPLAYED do
        local button = _G["CharSelectCharacterButton"..i];

        local defaultBg = _G["CharSelectCharacterButton"..i.."DefaultBackground"];
        if not defaultBg then
            defaultBg = button:CreateTexture("CharSelectCharacterButton"..i.."DefaultBackground", "BACKGROUND");
        end
        defaultBg:ClearAllPoints();
        defaultBg:SetPoint("CENTER", button, "CENTER", -22, 1);
        defaultBg:SetSize(242, 61);
        defaultBg:SetTexture("Interface\\Glues\\CharacterSelect\\uicharacterselectglues2x");
        defaultBg:SetTexCoord(0.619628906, 0.929199219, 0.242675781, 0.336425781);
        defaultBg:Show();

        local generalBg = _G["CharSelectCharacterButton"..i.."GeneralBackground"];
        if generalBg then generalBg:Hide(); end
        
        local background = _G["CharSelectCharacterButton"..i.."Background"];
        if background then background:Hide(); end
        
        local factionIcon = _G["CharSelectCharacterButton"..i.."FactionIcon"];
        if factionIcon then factionIcon:Hide(); end
        
        local nameText = _G["CharSelectCharacterButton"..i.."ButtonTextName"];
        if nameText then nameText:SetText(""); end
        
        local levelText = _G["CharSelectCharacterButton"..i.."ButtonTextLevel"];
        if levelText then levelText:SetText(""); end

        local separatorText = _G["CharSelectCharacterButton"..i.."ButtonTextSeparator"];
        if separatorText then separatorText:Hide(); end

        local classText = _G["CharSelectCharacterButton"..i.."ButtonTextClass"];
        if classText then classText:SetText(""); end
        
        local zoneText = _G["CharSelectCharacterButton"..i.."ButtonTextZone"];
        if zoneText then zoneText:SetText(""); end
        
        local statusText = _G["CharSelectCharacterButton"..i.."ButtonTextStatus"];
        if statusText then statusText:SetText(""); end

        _G["CharSelectCharacterCustomize"..i]:Hide();
        _G["CharSelectRaceChange"..i]:Hide();
        _G["CharSelectFactionChange"..i]:Hide();

        button:Show();
    end

    if ( numChars == 0 ) then
        CharacterSelect.selectedIndex = 0;
        CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex, 1);
        CharacterSelectDeleteButton:Disable();
        CharSelectEnterWorldButton:Disable();
    else
        CharacterSelectDeleteButton:Enable();
        CharSelectEnterWorldButton:Enable();
    end

    CharacterSelect.createIndex = 0;
    local connected = IsConnectedToServer();

    if (numChars < MAX_CHARACTERS_PER_REALM and connected) then
        CharacterSelect.createIndex = numChars + 1;
        CharSelectCreateCharacterButton:SetID(CharacterSelect.createIndex);
        CharSelectCreateCharacterButton:Show();
    else
        CharSelectCreateCharacterButton:Hide();
    end

    if ( CharacterSelect.selectLast == 1 ) then
        CharacterSelect.selectLast = 0;
        CharacterSelect_SelectCharacter(numChars, 1);
        return;
    end

    if ( (CharacterSelect.selectedIndex == 0) or (CharacterSelect.selectedIndex > numChars) ) then
        CharacterSelect.selectedIndex = 1;
    end
    CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex, 1);
end

function CharacterSelectButton_OnClick(self)
    local id = self:GetID();
    local numChars = GetNumCharacters();

    if ( id <= numChars and id ~= CharacterSelect.selectedIndex ) then
        CharacterSelect_SelectCharacter(id);
    else
        PlaySound("igMainMenuOptionCheckBoxOn");
    end
end

function CharacterSelectButton_OnDoubleClick(self)
    local id = self:GetID();
    local numChars = GetNumCharacters();

    if ( id <= numChars ) then
        if ( id ~= CharacterSelect.selectedIndex ) then
            CharacterSelect_SelectCharacter(id);
        end
        CharacterSelect_EnterWorld();
    else
        PlaySound("igMainMenuOptionCheckBoxOn");
    end
end

function CharacterSelect_TabResize(self)
	local buttonMiddle = _G[self:GetName().."Middle"];
	local buttonMiddleDisabled = _G[self:GetName().."MiddleDisabled"];
	local width = self:GetTextWidth() - 8;
	local leftWidth = _G[self:GetName().."Left"]:GetWidth();
	buttonMiddle:SetWidth(width);
	buttonMiddleDisabled:SetWidth(width);
	self:SetWidth(width + (2 * leftWidth));
end

function CharacterSelect_SelectCharacter(id, noCreate)
	if ( id == CharacterSelect.createIndex ) then
		if ( not noCreate ) then
			PlaySound("gsCharacterSelectionCreateNew");
			SetGlueScreen("charcreate");
		end
	else
		CharacterSelect.currentModel = GetSelectBackgroundModel(id);
		SetBackgroundModel(CharacterSelect,CharacterSelect.currentModel);

		SelectCharacter(id);
	end
end

function CharacterDeleteDialog_OnShow()
    local name, race, class, level = GetCharacterInfo(CharacterSelect.selectedIndex);
    local faction, isAlliance;

    if name == "You" or name == "Found" or name == "Asecret" or name == "Area" then
        DisconnectFromServer();
        CharacterDeleteDialog:Hide();
        return;
    end

    if race == "Humano" or race == "Humana" or race == "Enano" or race == "Enana" or race == "Elfo de la noche" or race == "Elfa de la noche" or race == "Gnomo" or race == "Gnoma" or race == "Draenei" then
        faction = "|cff0080ffAlianza|r";
        isAlliance = true;
    elseif race == "Orco" or race == "Orca" or race == "No-muerto" or race == "No-muerta" or race == "Tauren" or race == "Trol" or race == "Elfo de sangre" or race == "Elfa de sangre" then
        faction = "|cffff0000Horda|r";
        isAlliance = false;
    else
        faction = race;
        isAlliance = nil;
    end

    CharacterDeleteText1:SetFont("Fonts\\FRIZQT__.TTF", 12)
    CharacterDeleteText2:SetFont("Fonts\\FRIZQT__.TTF", 10)
    CharacterDeleteAlertText:SetFont("Fonts\\FRIZQT__.TTF", 10)
    CharacterDeleteAlertText:SetTextColor(1, 0.2, 0.2)
    CharacterDeleteAlertText:SetText("Quieres Borrar este Personaje.")

    CharacterDeleteCenterText:SetFont("Fonts\\FRIZQT__.TTF", 11)
    CharacterDeleteCenterText:SetTextColor(1, 0, 0)
    CharacterDeleteCenterText:SetText("Esta accion no se puede deshacer")
    
    CharacterDeleteText1:SetFormattedText(CONFIRM_CHAR_DELETE, name, level, class, faction);

    CharacterDeleteText1:ClearAllPoints()
    CharacterDeleteText1:SetPoint("CENTER", CharacterDeleteBackground, "CENTER", 0, 50)

    CharacterDeleteText2:ClearAllPoints()
    CharacterDeleteText2:SetPoint("CENTER", CharacterDeleteBackground, "CENTER", 0, -20)
    
    CharacterDeleteBackground:SetWidth(300);
    CharacterDeleteBackground:SetHeight(250);
    CharacterDeleteButton1:Disable();

    if not CharacterDeleteLeftTexture then
        CharacterDeleteLeftTexture = CharacterDeleteBackground:CreateTexture(nil, "ARTWORK")
        CharacterDeleteLeftTexture:SetSize(42, 42)
        CharacterDeleteLeftTexture:SetPoint("RIGHT", CharacterDeleteText1, "LEFT", 70, 0)
        CharacterDeleteLeftTexture:SetTexture("Interface\\Glues\\CharacterSelect\\PlusManz-Alliance")
    end
    
    if not CharacterDeleteRightTexture then
        CharacterDeleteRightTexture = CharacterDeleteBackground:CreateTexture(nil, "ARTWORK")
        CharacterDeleteRightTexture:SetSize(42, 42)
        CharacterDeleteRightTexture:SetPoint("LEFT", CharacterDeleteText1, "RIGHT", -70, 0)
        CharacterDeleteRightTexture:SetTexture("Interface\\Glues\\CharacterSelect\\PlusManz-Horde")
    end

    if isAlliance == true then
        CharacterDeleteLeftTexture:SetDesaturated(false)
        CharacterDeleteLeftTexture:SetAlpha(1.0)
        CharacterDeleteRightTexture:SetDesaturated(true)
        CharacterDeleteRightTexture:SetAlpha(0.6)
    elseif isAlliance == false then
        CharacterDeleteRightTexture:SetDesaturated(false)
        CharacterDeleteRightTexture:SetAlpha(1.0)
        CharacterDeleteLeftTexture:SetDesaturated(true)
        CharacterDeleteLeftTexture:SetAlpha(0.6)
    else
        CharacterDeleteLeftTexture:SetDesaturated(true)
        CharacterDeleteRightTexture:SetDesaturated(true)
        CharacterDeleteLeftTexture:SetAlpha(0.6)
        CharacterDeleteRightTexture:SetAlpha(0.6)
    end

    CharacterDeleteLeftTexture:Show()
    CharacterDeleteRightTexture:Show()

    if not CharacterDeleteTooltip then
        CharacterDeleteTooltip = CreateFrame("Frame", nil, CharacterDeleteBackground)
        CharacterDeleteTooltip:SetFrameLevel(CharacterDeleteBackground:GetFrameLevel() - 1)

        CharacterDeleteTooltip:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\ui-tooltip-border-mawBlack",
            tile = true,
            tileSize = 12,
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        
        CharacterDeleteTooltip:SetBackdropColor(0, 0, 0)
    end

    CharacterDeleteTooltip:ClearAllPoints()
    CharacterDeleteTooltip:SetPoint("LEFT", CharacterDeleteLeftTexture, "LEFT", -10, 0)
    CharacterDeleteTooltip:SetPoint("RIGHT", CharacterDeleteRightTexture, "RIGHT", 10, 0)
    CharacterDeleteTooltip:SetPoint("TOP", CharacterDeleteText1, "TOP", 0, 8)
    CharacterDeleteTooltip:SetPoint("BOTTOM", CharacterDeleteText1, "BOTTOM", 0, -10)
    
    CharacterDeleteTooltip:Show()

    if not CharacterDeleteCenterTooltip then
        CharacterDeleteCenterTooltip = CreateFrame("Frame", nil, CharacterDeleteBackground)
        CharacterDeleteCenterTooltip:SetFrameLevel(CharacterDeleteBackground:GetFrameLevel() - 1)

        CharacterDeleteCenterTooltip:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\ui-tooltip-border-mawBlack",
            tile = true,
            tileSize = 12,
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        
        CharacterDeleteCenterTooltip:SetBackdropColor(0, 0, 0)
    end

    CharacterDeleteCenterTooltip:ClearAllPoints()
    CharacterDeleteCenterTooltip:SetPoint("TOP", CharacterDeleteCenterText, "TOP", 0, 5)
    CharacterDeleteCenterTooltip:SetPoint("BOTTOM", CharacterDeleteCenterText, "BOTTOM", 0, -5)
    CharacterDeleteCenterTooltip:SetPoint("LEFT", CharacterDeleteCenterText, "LEFT", 20, 0)
    CharacterDeleteCenterTooltip:SetPoint("RIGHT", CharacterDeleteCenterText, "RIGHT", -20, 0)
    
    CharacterDeleteCenterTooltip:Show()

    CharacterDeleteEditBox:SetText("")
    CharacterDeleteEditBox:SetFocus()
end

function CharacterSelect_EnterWorld()
	PlaySound("gsCharacterSelectionEnterWorld");
	StopGlueAmbience();
	EnterWorld();
end

function CharacterSelect_Exit()
	PlaySound("gsCharacterSelectionExit");
	DisconnectFromServer();
	SetGlueScreen("login");
end

function CharacterSelect_AccountOptions()
	PlaySound("gsCharacterSelectionAcctOptions");
end

function CharacterSelect_TechSupport()
	PlaySound("gsCharacterSelectionAcctOptions");
	LaunchURL(TECH_SUPPORT_URL);
end

function CharacterSelect_Delete()
	PlaySound("gsCharacterSelectionDelCharacter");
	if ( CharacterSelect.selectedIndex > 0 ) then
		CharacterDeleteDialog:Show();
	end
end

function CharacterSelect_ChangeRealm()
	PlaySound("gsCharacterSelectionDelCharacter");
	RequestRealmList(1);
end

function CharacterSelectFrame_OnMouseDown(button)
	if ( button == "LeftButton" ) then
		CHARACTER_SELECT_ROTATION_START_X = GetCursorPosition();
		CHARACTER_SELECT_INITIAL_FACING = GetCharacterSelectFacing();
	end
end

function CharacterSelectFrame_OnMouseUp(button)
	if ( button == "LeftButton" ) then
		CHARACTER_SELECT_ROTATION_START_X = nil
	end
end

function CharacterSelectFrame_OnUpdate()
	if ( CHARACTER_SELECT_ROTATION_START_X ) then
		local x = GetCursorPosition();
		local diff = (x - CHARACTER_SELECT_ROTATION_START_X) * CHARACTER_ROTATION_CONSTANT;
		CHARACTER_SELECT_ROTATION_START_X = GetCursorPosition();
		SetCharacterSelectFacing(GetCharacterSelectFacing() + diff);
	end
end

function CharacterSelectRotateRight_OnUpdate(self)
	if ( self:GetButtonState() == "PUSHED" ) then
		SetCharacterSelectFacing(GetCharacterSelectFacing() + CHARACTER_FACING_INCREMENT);
	end
end

function CharacterSelectRotateLeft_OnUpdate(self)
	if ( self:GetButtonState() == "PUSHED" ) then
		SetCharacterSelectFacing(GetCharacterSelectFacing() - CHARACTER_FACING_INCREMENT);
	end
end

function CharacterSelect_ManageAccount()
	PlaySound("gsCharacterSelectionAcctOptions");
	LaunchURL(AUTH_NO_TIME_URL);
end

function RealmSplit_GetFormatedChoice(formatText)
	if ( SERVER_SPLIT_CLIENT_STATE == 1 ) then
		realmChoice = SERVER_SPLIT_SERVER_ONE;
	else
		realmChoice = SERVER_SPLIT_SERVER_TWO;
	end
	return format(formatText, realmChoice);
end

function RealmSplit_SetChoiceText()
	RealmSplitCurrentChoice:SetText( RealmSplit_GetFormatedChoice(SERVER_SPLIT_CURRENT_CHOICE) );
	RealmSplitCurrentChoice:Show();
end

function CharacterSelect_PaidServiceOnClick(self, button, down, service)
	PAID_SERVICE_CHARACTER_ID = self:GetID();
	PAID_SERVICE_TYPE = service;
	PlaySound("gsCharacterSelectionCreateNew");
	SetGlueScreen("charcreate");
end

function CharacterSelect_DeathKnightSwap(self)
	if ( CharacterSelect.currentModel == "DEATHKNIGHT" ) then
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

