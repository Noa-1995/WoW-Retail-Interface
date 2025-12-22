-- Autora: Noa

function OptionsSelectFrame_Hide()
	PlaySound("gsLoginChangeRealmCancel");
	OptionsSelectFrame:Hide();
end

function OptionsSelectResetSettingsButton_OnClick_Reset(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	GlueDialog_Show("RESET_SERVER_SETTINGS");
end

function OptionsSelectResetSettingsButton_OnClick_Cancel(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	GlueDialog_Show("CANCEL_RESET_SETTINGS");
end

function AccountLogin_RealmReset()
	SetCVar("realmName", "");
	AccountLogin_Exit();
end

function MovieList_Show()
    PlaySound("igMainMenuOption");
    OptionsSelectFrame:Hide();
    CinematicsFrame:Show();
    Cinematics_SetupButtons();
end

function CinematicsFrame_OnLoad(self)
    self:RegisterEvent("PLAY_MOVIE");
end

function CinematicsFrame_OnKeyDown(key)
    if key == "ESCAPE" then
        CinematicsFrame_Hide();
    end
end

function CinematicsFrame_Hide()
    PlaySound("gsLoginChangeRealmCancel");
    CinematicsFrame:Hide();
    if CharacterSelect and CharacterSelect:IsShown() then
        CharacterSelect:Show();
    else
        if CharacterSelect_Show then
            CharacterSelect_Show();
        end
    end
end

function Cinematics_SetupButtons()
    local buttons = {CinematicsButton1, CinematicsButton2, CinematicsButton3};
    
    for i, button in ipairs(buttons) do
        button:Show();
    end
end

function Cinematics_OnMovieFinished()
    if CharacterSelect and CharacterSelect:IsShown() then
        CharacterSelect:Show();
    else
        if CharacterSelect_Show then
            CharacterSelect_Show();
        end
    end
end

function OptionsSelectFrame_OnShow()
    local locale = GetLocale() or "enUS";
    local button = OptionsSelectResetSettingsButton;
    if button and GlueStrings and GlueStrings["RESET_REALM_EXIT"] then
        button:SetText(GlueStrings["RESET_REALM_EXIT"][locale] or GlueStrings["RESET_REALM_EXIT"].enUS);
    end
end