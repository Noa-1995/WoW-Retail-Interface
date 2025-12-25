-- ==============================================================================================
-- Autora: Noa - SISTEMA DE AUTOLOGIN CON BOTONES DE REDES SOCIALES CON ANIMACIÓN BLP Y ESCENA 3D
-- ==============================================================================================
local Config = {
    FADE_IN_TIME = 2,
    DEFAULT_TOOLTIP_COLOR = {0.8, 0.8, 0.8, 0.09, 0.09, 0.09},
    MAX_PIN_LENGTH = 10,
    AUTO_LOGIN_DELAY = 3.0,
    BACKGROUND_TEXTURE = "Interface/Loginscreen/Background.blp",
    LOGIN_AMBIENCE = false,

    ENABLE_BLP_ANIMATION = false,
    FRAME_COUNT = 3,
    ANIMATION_DURATION = 16.0,
    FPS_LIMIT = 30,
    ANIMATION_PATH = "Interface\\Loginscreen\\Scene\\",

    MODEL_UPDATE_INTERVAL = 0.1,
    MODEL_UPDATE_COUNT_REQUIRED = 2,
    SCROLL_THRESHOLD = 20,
    FADE_DURATION = 0.5,
    LOGO_TEXTURE = "Interface\\Glues\\Common\\glues-wow-wotlklogo",
    LOGO_SIZE = 225,
    LOGO_POSITION_X = 60,
    LOGO_POSITION_Y = 40,
    CUSTOM_PANEL_WIDTH = 352,
    CUSTOM_PANEL_SCROLL_WIDTH = 300,
    DEFAULT_FRAME_LEVEL = 2,
    AMBIENCE_FADE_TIME = 5.0,
    UNDEAD_AMBIENCE_FADE_TIME = 4.0,
    SFX_STOP_TIME = 1.0,
    TOS_FRAME_WIDTH = 640,
    TOS_FRAME_HEIGHT = 512,
    TOS_SCROLL_WIDTH = 540,
    TOS_SCROLL_HEIGHT = 407,
    TOS_HEADER_WIDTH = 300,
    TOS_TITLE_OFFSET = 12,
    TOS_TEXT_OFFSET = 56,
    BUTTON_HEIGHT_SMALL = 38,
    BUTTON_HEIGHT_LARGE = 55, 
    CINEMATICS_BUTTON_HEIGHT = 80,
    CINEMATICS_BACKGROUND_HEIGHT_BASE = 70
}

local LoginState = {
    autoLoginTimer = nil, autoLoginDelay = Config.AUTO_LOGIN_DELAY, autoLoginAttempted = false, musicTimer = 0, sceneTimer = 0, currentFrame = 0, lastUpdateTime = 0, currentScene = 1
}

local ModelManager = {
    models = {}, loginModels = {}
}

local UICache = {
    accountEdit = nil, passwordEdit = nil, saveAccountName = nil, savePassword = nil, autoLogin = nil, autoLoginText = nil, loginButton = nil, versionText = nil, realmName = nil, upgradeButton = nil, tosFrame = nil, tosAccept = nil, tosDecline = nil, backgroundTexture = nil, animatedTexture = nil, newLogo = nil, newLogoFrame = nil
}

LOGIN_MODEL_LIGHTS = {
    [0] = {1, 0, 0, -0.707, -0.707, 0.7, 1.0, 1.0, 1.0, 0, 1.0, 1.0, 0.8},
}
LOGIN_MODEL_STRUCT = {
    SCENE_ID = 1, POS_Y = 2, POS_Z = 3, POS_X = 4, FACING = 5, SCALE = 6, ALPHA = 7, LIGHT = 8, SEQUENCE = 9, WIDTH_SQUISH = 10, HEIGHT_SQUISH = 11, MODEL_PATH = 12,
}

LOGIN_MODELS = {
    {1, 0.000, 0.300, 0.285, 0.684, 0.085, 1.000, LOGIN_MODEL_LIGHTS[0], 1, 1, 1, "Environments\\Stars\\icecrownarthasdeathsky.m2"},
    {1, -0.712, 0.800, 0.000, 6.245, 0.100, 0.400, LOGIN_MODEL_LIGHTS[0], 1, 1, 1, "Environments\\Stars\\aurorayellowgreen.m2"},
    {1, -0.712, -0.750, 0.000, 6.245, 0.100, 0.500, LOGIN_MODEL_LIGHTS[0], 1, 1, 1, "Environments\\Stars\\auroraorange.m2"},
}

BACKGROUND_MODELS = {
    ["Environments\\Stars\\icecrownarthasdeathsky.m2"] = { frameLevel = 0 },
}
-- ==================== CONFIGURACIÓN ADICIONAL ====================
local function InitializeUICache()
    UICache.accountEdit = _G["AccountLoginAccountEdit"] 
    UICache.passwordEdit = _G["AccountLoginPasswordEdit"] 
    UICache.saveAccountName = _G["AccountLoginSaveAccountName"] 
    UICache.savePassword = _G["AccountLoginSavePassword"] 
    UICache.autoLogin = _G["AccountLoginAutoLogin"] 
    UICache.autoLoginText = _G["AccountLoginAutoLoginText"] 
    UICache.loginButton = _G["AccountLoginLoginButton"] 
    UICache.versionText = _G["AccountLoginVersion"] 
    UICache.realmName = _G["AccountLoginRealmName"] 
    UICache.upgradeButton = _G["AccountLoginUpgradeAccountButton"] 
    UICache.tosFrame = _G["TOSFrame"] 
    UICache.tosAccept = _G["TOSAccept"] 
    UICache.tosDecline = _G["TOSDecline"]
end

function GetLoginConfig()
    return Config
end

function GetLoginState()
    return LoginState
end
-- ============================================================================
-- SISTEMA DE ANIMACIÓN BLP
-- ============================================================================
local function UpdateBackgroundAnimation(self, elapsed)
    if not Config.ENABLE_BLP_ANIMATION or Config.FRAME_COUNT <= 0 then
        return
    end
    
    local currentTime = GetTime()
    if (currentTime - LoginState.lastUpdateTime) < (1 / Config.FPS_LIMIT) then
        return
    end
    
    LoginState.lastUpdateTime = currentTime
    LoginState.currentFrame = (LoginState.currentFrame + 1) % Config.FRAME_COUNT
    
    if self.animatedTexture then
        local texturePath = Config.ANIMATION_PATH .. string.format("%04d.blp", LoginState.currentFrame)
        self.animatedTexture:SetTexture(texturePath)
    end
end
-- ============================================================================
-- DIÁLOGOS
-- ============================================================================
GlueDialogTypes["REMEMBER_PASSWORD"] = {
    text = SAVE_PASSWORD_NOTICE,
    button1 = OKAY,
    button2 = CANCEL,
    OnAccept = function()
        UICache.autoLoginText:Show()
        UICache.autoLogin:Show()
    end,
    OnCancel = function()
        UICache.savePassword:SetChecked(0)
        UICache.autoLoginText:Hide()
        UICache.autoLogin:Hide()
        UICache.autoLogin:SetChecked(0)
    end,
}

GlueDialogTypes["AUTO_LOGIN"] = {
    text = SAVE_AUTOLOGIN_NOTICE,
    button1 = OKAY,
    button2 = CANCEL,
    OnAccept = function()
    end,
    OnCancel = function()
        UICache.autoLogin:SetChecked(0)
    end,
}
-- ============================================================================
-- GESTIÓN DE MODELOS 3D
-- ============================================================================
local function CreateLoginModel(parent, modelData)
    local model = CreateFrame("Model", nil, parent)
    local width, height = parent:GetSize()
    
    model:SetSize(
        width * (modelData[LOGIN_MODEL_STRUCT.WIDTH_SQUISH] or 1), 
        height * (modelData[LOGIN_MODEL_STRUCT.HEIGHT_SQUISH] or 1)
    )
    model:SetPoint("CENTER")
    model:SetModel("Character/Human/Male/HumanMale.mdx")
    model:SetCamera(1)
    model:SetModel(modelData[LOGIN_MODEL_STRUCT.MODEL_PATH])
    model:SetPosition(
        modelData[LOGIN_MODEL_STRUCT.POS_X], 
        modelData[LOGIN_MODEL_STRUCT.POS_Y], 
        modelData[LOGIN_MODEL_STRUCT.POS_Z]
    )
    model:SetFacing(modelData[LOGIN_MODEL_STRUCT.FACING])
    model:SetModelScale(modelData[LOGIN_MODEL_STRUCT.SCALE])
    model:SetAlpha(modelData[LOGIN_MODEL_STRUCT.ALPHA])
    model:SetSequence(modelData[LOGIN_MODEL_STRUCT.SEQUENCE])
    
    if modelData[LOGIN_MODEL_STRUCT.LIGHT] then
        model:SetLight(unpack(modelData[LOGIN_MODEL_STRUCT.LIGHT]))
    end
    
    return model
end

local function InitializeLoginScene(parent)
    for _, model in ipairs(ModelManager.loginModels) do
        model:Hide()
        model:SetParent(nil)
    end
    ModelManager.loginModels = {}

    for _, modelData in ipairs(LOGIN_MODELS) do
        if modelData[LOGIN_MODEL_STRUCT.SCENE_ID] == LoginState.currentScene then
            local model = CreateLoginModel(parent, modelData)
            table.insert(ModelManager.loginModels, model)
        end
    end
end
-- ============================================================================
-- ACTUALIZACIÓN DE LA ESCENA
-- ============================================================================
function LoginScene_OnUpdate(self, elapsed)
    if Config.LOGIN_AMBIENCE and not self.ambiencePlayed then
        PlayGlueAmbience(Config.LOGIN_AMBIENCE, Config.AMBIENCE_FADE_TIME)
        self.ambiencePlayed = true
    end

    if LoginState.autoLoginTimer and LoginState.autoLoginTimer < LoginState.autoLoginDelay then
        LoginState.autoLoginTimer = LoginState.autoLoginTimer + elapsed
        if LoginState.autoLoginTimer >= LoginState.autoLoginDelay then
            AccountLogin_Login()
            LoginState.autoLoginTimer = nil
        end
    end
    UpdateBackgroundAnimation(self, elapsed)

    if not self.modelsInitialized and self.Models then
        self.modelUpdateTimer = (self.modelUpdateTimer or 0) + elapsed

        if self.modelUpdateTimer >= Config.MODEL_UPDATE_INTERVAL then
            self.modelUpdateTimer = 0
            self.modelUpdateCount = (self.modelUpdateCount or 0) + 1
            
            if self.modelUpdateCount == 1 then
                for i = 1, #self.Models do
                    local model = self.Models[i]
                    local data = LOGIN_MODELS[i]
                    
                    if model and data then
                        model:SetModel(data[LOGIN_MODEL_STRUCT.MODEL_PATH])
                        model:SetPosition(data[LOGIN_MODEL_STRUCT.POS_X], data[LOGIN_MODEL_STRUCT.POS_Y], data[LOGIN_MODEL_STRUCT.POS_Z])
                        model:SetFacing(data[LOGIN_MODEL_STRUCT.FACING])
                        model:SetModelScale(data[LOGIN_MODEL_STRUCT.SCALE])
                        model:SetSequence(data[LOGIN_MODEL_STRUCT.SEQUENCE])
                        if data[LOGIN_MODEL_STRUCT.LIGHT] then
                            model:SetLight(unpack(data[LOGIN_MODEL_STRUCT.LIGHT]))
                        end
                        model:Show()
                    end
                end
            end
            if self.modelUpdateCount >= Config.MODEL_UPDATE_COUNT_REQUIRED then
                self.modelsInitialized = true
                self.modelsCreated = true
                self.modelUpdateTimer = nil
                self.modelUpdateCount = nil
            end
        end
    end
    LoginState.sceneTimer = LoginState.sceneTimer + elapsed
end
-- ============================================================================
-- INICIALIZACIÓN Y EVENTOS
-- ============================================================================
local function isBackgroundModel(modelPath)
    return BACKGROUND_MODELS[modelPath] ~= nil
end

local function getModelFrameLevel(modelPath)
    return isBackgroundModel(modelPath) and BACKGROUND_MODELS[modelPath].frameLevel or Config.DEFAULT_FRAME_LEVEL
end

function AccountLogin_OnLoad(self)
    InitializeUICache()
    
    AccountLogin_SetupServerAlert()
    
    UICache.tosFrame.noticeType = "EULA"
    self:RegisterEvent("SHOW_SERVER_ALERT")
    self:RegisterEvent("SHOW_SURVEY_NOTIFICATION")
    self:RegisterEvent("CLIENT_ACCOUNT_MISMATCH")
    self:RegisterEvent("CLIENT_TRIAL")
    self:RegisterEvent("SCANDLL_ERROR")
    self:RegisterEvent("SCANDLL_FINISHED")
    
    local versionType, buildType, version, internalVersion, date = GetBuildInfo()
    UICache.versionText:SetText(buildType.." "..version.." ("..internalVersion..")")
    
    local backdropColor = Config.DEFAULT_TOOLTIP_COLOR
    UICache.accountEdit:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3])
    UICache.accountEdit:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6])
    UICache.passwordEdit:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3])
    UICache.passwordEdit:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6])

    self.Models = {}
    for i = 1, #LOGIN_MODELS do
        local data = LOGIN_MODELS[i]
        local model = CreateFrame("Model", "AccountLoginModel"..i, self)

        model:SetModel("Character/Human/Male/HumanMale.mdx")
        model:SetPoint("CENTER", 0, 0)
        model:SetSize(self:GetWidth() / (data[LOGIN_MODEL_STRUCT.WIDTH_SQUISH] or 1), 
                      self:GetHeight() / (data[LOGIN_MODEL_STRUCT.HEIGHT_SQUISH] or 1))
        model:SetCamera(1)
        
        if data[LOGIN_MODEL_STRUCT.LIGHT] then
            model:SetLight(unpack(data[LOGIN_MODEL_STRUCT.LIGHT]))
        end
        model:SetAlpha(data[LOGIN_MODEL_STRUCT.ALPHA])
        
        local frameLevel = getModelFrameLevel(data[LOGIN_MODEL_STRUCT.MODEL_PATH])
        model:SetFrameLevel(frameLevel)
        
        if frameLevel == 0 then
            model:SetFrameStrata("LOW")
        end
        model:Hide()
        self.Models[i] = model
    end
    self.modelUpdateCount = 0
    self.modelUpdateTimer = 0
    self.modelsInitialized = false
    self.ambiencePlayed = false
    self.modelsCreated = false

    AcceptTOS()
    AcceptEULA()
end

function AccountLogin_OnShow(self)
    self:Show()
    self:SetAlpha(1)
    WorldOfWarcraftRating:Hide()
    if not self.backgroundTexture then
        self.backgroundTexture = self:CreateTexture("AccountLoginBackground", "BACKGROUND")
        self.backgroundTexture:SetTexture(Config.BACKGROUND_TEXTURE)
        self.backgroundTexture:SetAllPoints(self)
        self.backgroundTexture:SetTexCoord(0, 1, 0, 1)
        UICache.backgroundTexture = self.backgroundTexture
    else
        self.backgroundTexture:Show()
    end

    if Config.ENABLE_BLP_ANIMATION and Config.FRAME_COUNT > 0 then
        if not self.animatedTexture then
            self.animatedTexture = self:CreateTexture("AccountLoginAnimatedBackground", "BACKGROUND")
            self.animatedTexture:SetAllPoints(self)
            self.animatedTexture:SetTexture(Config.ANIMATION_PATH .. "0000.blp")
            UICache.animatedTexture = self.animatedTexture
            LoginState.currentFrame = 0
            LoginState.lastUpdateTime = GetTime()
        else
            self.animatedTexture:Show()
            LoginState.currentFrame = 0
            LoginState.lastUpdateTime = GetTime()
        end
    elseif self.animatedTexture then
        self.animatedTexture:Hide()
    end
    AccountLoginUI:Show()
    AccountLoginUI:SetAlpha(1)

    if not self.newLogo then
        self.newLogoFrame = CreateFrame("Frame", nil, self)
        self.newLogoFrame:SetSize(Config.LOGO_SIZE, Config.LOGO_SIZE)
        self.newLogoFrame:SetPoint("TOPLEFT", Config.LOGO_POSITION_X, Config.LOGO_POSITION_Y)
        
        self.newLogo = self.newLogoFrame:CreateTexture("AccountLoginNewLogo", "OVERLAY")
        self.newLogo:SetTexture(Config.LOGO_TEXTURE)
        self.newLogo:SetAllPoints(self.newLogoFrame)
        self.newLogo:Show()
        UICache.newLogo = self.newLogo
        UICache.newLogoFrame = self.newLogoFrame
    else
        self.newLogoFrame:Show()
    end

    if self.Models then
        for i = 1, #self.Models do
            local model = self.Models[i]
            if model then
                model:Show()
            end
        end
    end

    if self.modelsCreated then
        self.modelsInitialized = true
    else
        self.modelsInitialized = false
    end
    self.modelUpdateCount = 0
    self.modelUpdateTimer = 0

    local accountName, password = unpack(string_explode(GetSavedAccountName(), "#&|&#"))
    UICache.accountEdit:SetText(accountName or "")
    UICache.passwordEdit:SetText(password or "")

    PlayGlueAmbience("GlueScreenUndead", Config.UNDEAD_AMBIENCE_FADE_TIME)
    AccountLogin_ShowUserAgreements()

    local serverName = GetServerName()
    if serverName then
        UICache.realmName:SetText(serverName)
    else
        UICache.realmName:SetText("No Recent Server")
    end

    if accountName == "" then
        AccountLogin_FocusAccountName()
    else
        AccountLogin_FocusPassword()
    end

    if UICache.savePassword:GetChecked() then
        UICache.autoLoginText:Show()
        UICache.autoLogin:Show()
    else
        UICache.autoLoginText:Hide()
        UICache.autoLogin:Hide()
    end

    if IsTrialAccount() then
        UICache.upgradeButton:Show()
    else
        UICache.upgradeButton:Hide()
    end
    ACCOUNT_MSG_NUM_AVAILABLE = 0
    ACCOUNT_MSG_PRIORITY = 0
    ACCOUNT_MSG_HEADERS_LOADED = false
    ACCOUNT_MSG_BODY_LOADED = false
    ACCOUNT_MSG_CURRENT_INDEX = nil

    AccountLogin_CheckAutoLogin()
    self:SetScript("OnUpdate", LoginScene_OnUpdate)
end

function AccountLogin_OnHide(self)
    StopAllSFX(Config.SFX_STOP_TIME)
    if not UICache.saveAccountName:GetChecked() then
        SetSavedAccountList("")
    end
    self:SetScript("OnUpdate", nil)

    if self.Models then
        for i = 1, #self.Models do
            local model = self.Models[i]
            if model then
                model:Hide()
            end
        end
    end
    self.modelsInitialized = false
    self.ambiencePlayed = false

    if UICache.backgroundTexture then
        UICache.backgroundTexture:Hide()
    end
    if UICache.animatedTexture then
        UICache.animatedTexture:Hide()
    end
    if UICache.newLogoFrame then
        UICache.newLogoFrame:Hide()
    end
    StopGlueAmbience()
end

function AccountLogin_FocusPassword()
    UICache.passwordEdit:SetFocus()
end

function AccountLogin_FocusAccountName()
    UICache.accountEdit:SetFocus()
end

function AccountLogin_OnKeyDown(key)
    if key == "ESCAPE" then
        if ConnectionHelpFrame:IsShown() then
            ConnectionHelpFrame:Hide()
            AccountLoginUI:Show()
        elseif SurveyNotificationFrame:IsShown() then
        else
            AccountLogin_Exit()
        end
    elseif key == "ENTER" then
        if not TOSAccepted() then
            return
        elseif TOSFrame:IsShown() or ConnectionHelpFrame:IsShown() then
            return
        elseif SurveyNotificationFrame:IsShown() then
            AccountLogin_SurveyNotificationDone(1)
        end
        AccountLogin_Login()
    elseif key == "PRINTSCREEN" then
        Screenshot()
    end
end

function AccountLogin_OnEvent(event, arg1, arg2, arg3)
    if event == "SHOW_SERVER_ALERT" then
        ServerAlertText:SetText(arg1)
        ServerAlertFrame:Show()
    elseif event == "SHOW_SURVEY_NOTIFICATION" then
        AccountLogin_ShowSurveyNotification()
    elseif event == "CLIENT_ACCOUNT_MISMATCH" then
        local accountExpansionLevel = arg1
        local installationExpansionLevel = arg2
        if accountExpansionLevel == 1 then
            GlueDialog_Show("CLIENT_ACCOUNT_MISMATCH", CLIENT_ACCOUNT_MISMATCH_BC)
        else
            GlueDialog_Show("CLIENT_ACCOUNT_MISMATCH", CLIENT_ACCOUNT_MISMATCH_LK)
        end
    elseif event == "CLIENT_TRIAL" then
        GlueDialog_Show("CLIENT_TRIAL")
    elseif event == "SCANDLL_ERROR" then
        GlueDialog:Hide()
        ScanDLLContinueAnyway()
        AccountLoginUI:Show()
    elseif event == "SCANDLL_FINISHED" then
        if arg1 == "OK" then
            GlueDialog:Hide()
            AccountLoginUI:Show()
        else
            AccountLogin.hackURL = _G["SCANDLL_URL_"..arg1]
            AccountLogin.hackName = arg2
            AccountLogin.hackType = arg1
            local formatString = _G["SCANDLL_MESSAGE_"..arg1]
            if arg3 == 1 then
                formatString = _G["SCANDLL_MESSAGE_HACKNOCONTINUE"]
            end
            local msg = format(formatString, AccountLogin.hackName, AccountLogin.hackURL)
            if arg3 == 1 then
                GlueDialog_Show("SCANDLL_HACKFOUND_NOCONTINUE", msg)
            else
                GlueDialog_Show("SCANDLL_HACKFOUND", msg)
            end
            PlaySoundFile("Sound\\Creature\\MobileAlertBot\\MobileAlertBotIntruderAlert01.wav")
        end
    end
end
-- ============================================================================
-- SISTEMA DE LOGIN CON GUARDADO DE CONTRASEÑA
-- ============================================================================
function AccountLogin_Login()
    PlaySound("gsLogin")
    local accountName = UICache.accountEdit:GetText()
    local password = UICache.passwordEdit:GetText()
    local savedData = ""
    
    if UICache.saveAccountName:GetChecked() then
        if UICache.savePassword:GetChecked() then
            local autoLoginFlag = UICache.autoLogin:GetChecked() and "1" or "0"
            savedData = accountName.."#&|&#"..password.."#&|&#"..autoLoginFlag
        else
            local autoLoginFlag = UICache.autoLogin:GetChecked() and "1" or "0"
            savedData = accountName.."#&|&#".."".."#&|&#"..autoLoginFlag
        end
    else
        if UICache.autoLogin:GetChecked() then
            GlueDialog_Show("AUTO_LOGIN_NEEDS_ACCOUNT")
            UICache.autoLogin:SetChecked(0)
        end
        SetSavedAccountName("")
        SetUsesToken(false)
    end
    
    if savedData ~= "" then
        SetSavedAccountName(savedData)
    end
    DefaultServerLogin(accountName, password)
end
-- ============================================================================
-- SISTEMA DE AUTOLOGIN
-- ============================================================================
function AccountLogin_CheckAutoLogin()
    if not LoginState.autoLoginAttempted then
        LoginState.autoLoginAttempted = true
        local savedAccountInfo = GetSavedAccountName()
        
        if savedAccountInfo and savedAccountInfo ~= "" then
            local accountData = string_explode(savedAccountInfo, "#&|&#")
            local accountName = accountData[1] or ""
            local password = accountData[2] or ""
            local autoLogin = accountData[3] or "0"

            if autoLogin == "1" and accountName ~= "" and password ~= "" then
                LoginState.autoLoginTimer = 0
                LoginState.autoLoginDelay = Config.AUTO_LOGIN_DELAY
            else
                LoginState.autoLoginTimer = nil
            end
        end
    end
end
-- ============================================================================
-- ANIMACIÓN PARA SERVER ALERT FRAME
-- ============================================================================
function AccountLogin_ToggleServerAlert()
    local frame = ServerAlertFrame
    if not frame then return end
    
    if frame.isAnimating then
        return
    end
    
    if frame.fadeInfo then
        frame:SetScript("OnUpdate", nil)
        frame.fadeInfo = nil
    end
    
    frame.isAnimating = true

    local logoTexture = UICache.newLogo
    
    if frame:IsShown() then
        local startWidth = frame:GetWidth()
        local scrollFrame = _G["ServerAlertScrollFrame"]
        
        if not scrollFrame then
            frame:Hide()
            frame.isAnimating = false
            return
        end
        
        local startScrollWidth = scrollFrame:GetWidth()
        
        frame.fadeInfo = {
            mode = "OUT",
            timeToFade = 0.5,
            startAlpha = 1,
            endAlpha = 0,
            startWidth = startWidth,
            endWidth = 0,
            startScrollWidth = startScrollWidth,
            endScrollWidth = 0,
            scrollFrame = scrollFrame,
            savedWidth = startWidth,
            savedScrollWidth = startScrollWidth,
            logoAlpha = logoTexture and logoTexture:GetAlpha() or 1,
            logoEndAlpha = 0
        }
        
        frame:SetScript("OnUpdate", function(self, elapsed)
            if not self.fadeInfo then return end
            local fadeInfo = self.fadeInfo
            fadeInfo.elapsed = (fadeInfo.elapsed or 0) + elapsed
            
            if fadeInfo.elapsed < fadeInfo.timeToFade then
                local progress = fadeInfo.elapsed / fadeInfo.timeToFade
                self:SetAlpha(fadeInfo.startAlpha + (fadeInfo.endAlpha - fadeInfo.startAlpha) * progress)

                if logoTexture then
                    local logoProgress = progress
                    local logoAlpha = fadeInfo.logoAlpha + (fadeInfo.logoEndAlpha - fadeInfo.logoAlpha) * logoProgress
                    logoTexture:SetAlpha(logoAlpha)
                end
                
                local currentWidth = fadeInfo.startWidth + (fadeInfo.endWidth - fadeInfo.startWidth) * progress
                self:SetWidth(currentWidth)
                
                local currentScrollWidth = fadeInfo.startScrollWidth + (fadeInfo.endScrollWidth - fadeInfo.startScrollWidth) * progress
                if fadeInfo.scrollFrame then
                    fadeInfo.scrollFrame:SetWidth(currentScrollWidth)
                end
            else
                self:SetAlpha(fadeInfo.endAlpha)
                self:SetWidth(fadeInfo.endWidth)
                
                if logoTexture then
                    logoTexture:SetAlpha(fadeInfo.logoEndAlpha)
                end
                
                if fadeInfo.scrollFrame then
                    fadeInfo.scrollFrame:SetWidth(fadeInfo.endScrollWidth)
                end
                
                self:Hide()
                self:SetWidth(fadeInfo.savedWidth or 341)
                if fadeInfo.scrollFrame then
                    fadeInfo.scrollFrame:SetWidth(fadeInfo.savedScrollWidth or 300)
                end
                
                self:SetScript("OnUpdate", nil)
                self.fadeInfo = nil
                self.isAnimating = false
            end
        end)
    else
        local targetWidth = 341
        local targetScrollWidth = 300
        
        local scrollFrame = _G["ServerAlertScrollFrame"]
        if not scrollFrame then
            frame:Show()
            frame.isAnimating = false
            return
        end
        
        frame:SetWidth(0)
        scrollFrame:SetWidth(0)
        frame:SetAlpha(0)
        frame:Show()

        if logoTexture then
            logoTexture:SetAlpha(0)
            logoTexture:Show()
        end
        
        frame.fadeInfo = {
            mode = "IN",
            timeToFade = 0.5,
            startAlpha = 0,
            endAlpha = 1,
            startWidth = 0,
            endWidth = targetWidth,
            startScrollWidth = 0,
            endScrollWidth = targetScrollWidth,
            scrollFrame = scrollFrame,
            logoAlpha = 0,
            logoEndAlpha = 1
        }
        
        frame:SetScript("OnUpdate", function(self, elapsed)
            if not self.fadeInfo then return end
            local fadeInfo = self.fadeInfo
            fadeInfo.elapsed = (fadeInfo.elapsed or 0) + elapsed
            
            if fadeInfo.elapsed < fadeInfo.timeToFade then
                local progress = fadeInfo.elapsed / fadeInfo.timeToFade
                self:SetAlpha(fadeInfo.startAlpha + (fadeInfo.endAlpha - fadeInfo.startAlpha) * progress)

                if logoTexture then
                    local logoProgress = progress
                    local logoAlpha = fadeInfo.logoAlpha + (fadeInfo.logoEndAlpha - fadeInfo.logoAlpha) * logoProgress
                    logoTexture:SetAlpha(logoAlpha)
                end
                
                local currentWidth = fadeInfo.startWidth + (fadeInfo.endWidth - fadeInfo.startWidth) * progress
                self:SetWidth(currentWidth)
                
                local currentScrollWidth = fadeInfo.startScrollWidth + (fadeInfo.endScrollWidth - fadeInfo.startScrollWidth) * progress
                if fadeInfo.scrollFrame then
                    fadeInfo.scrollFrame:SetWidth(currentScrollWidth)
                end
            else
                self:SetAlpha(fadeInfo.endAlpha)
                self:SetWidth(fadeInfo.endWidth)

                if logoTexture then
                    logoTexture:SetAlpha(fadeInfo.logoEndAlpha)
                end
                
                if fadeInfo.scrollFrame then
                    fadeInfo.scrollFrame:SetWidth(fadeInfo.endScrollWidth)
                end
                
                self:SetScript("OnUpdate", nil)
                self.fadeInfo = nil
                self.isAnimating = false
            end
        end)
    end
    PlaySound("gsLoginNewAccount")
end

function AccountLogin_SetupServerAlert()
    if ServerAlertFrame then
        ServerAlertFrame.isAnimating = false
        ServerAlertFrame.fadeInfo = nil
    end
end
-- ============================================================================
-- FUNCIONES ADICIONALES
-- ============================================================================
function AccountLogin_TOS()
    if not GlueDialog:IsShown() then
        PlaySound("gsLoginNewAccount")
        AccountLoginUI:Hide()
        UICache.tosFrame:Show()
        TOSScrollFrameScrollBar:SetValue(0)
        TOSScrollFrame:Show()
        TOSFrameTitle:SetText(TOS_FRAME_TITLE)
        TOSText:Show()
    end
end

function AccountLogin_ManageAccount()
    PlaySound("gsLoginNewAccount")
    LaunchURL(AUTH_NO_TIME_URL)
end

function AccountLogin_LaunchCommunitySite()
    PlaySound("gsLoginNewAccount")
    LaunchURL(COMMUNITY_URL)
end

function CharacterSelect_UpgradeAccount()
    PlaySound("gsLoginNewAccount")
    LaunchURL(AUTH_NO_TIME_URL)
end

function AccountLogin_Credits()
    CreditsFrame.creditsType = 3
    PlaySound("gsTitleCredits")
    SetGlueScreen("credits")
end

function AccountLogin_Cinematics()
    if not GlueDialog:IsShown() then
        PlaySound("gsLoginNewAccount")
        MOVIE_RETURN_SCREEN = "login"
        if CinematicsFrame.numMovies > 1 then
            CinematicsFrame:Show()
        else
            MovieFrame.version = 1
            SetGlueScreen("movie")
        end
    end
end

function AccountLogin_Options()
    PlaySound("gsTitleOptions")
end

function AccountLogin_Exit()
    QuitGame()
end

function AccountLogin_ShowSurveyNotification()
    GlueDialog:Hide()
    AccountLoginUI:Hide()
    SurveyNotificationAccept:Enable()
    SurveyNotificationDecline:Enable()
    SurveyNotificationFrame:Show()
end

function AccountLogin_SurveyNotificationDone(accepted)
    SurveyNotificationFrame:Hide()
    SurveyNotificationAccept:Disable()
    SurveyNotificationDecline:Disable()
    SurveyNotificationDone(accepted)
    AccountLoginUI:Show()
end

function AccountLogin_ShowUserAgreements()
    TOSScrollFrame:Hide()
    EULAScrollFrame:Hide()
    TerminationScrollFrame:Hide()
    ScanningScrollFrame:Hide()
    ContestScrollFrame:Hide()
    TOSText:Hide()
    EULAText:Hide()
    TerminationText:Hide()
    ScanningText:Hide()
    
    if not EULAAccepted() then
        if ShowEULANotice() then
            TOSNotice:SetText(EULA_NOTICE)
            TOSNotice:Show()
        end
        AccountLoginUI:Hide()
        TOSFrame.noticeType = "EULA"
        TOSFrameTitle:SetText(EULA_FRAME_TITLE)
        TOSFrameHeader:SetWidth(TOSFrameTitle:GetWidth())
        EULAScrollFrame:Show()
        EULAText:Show()
        TOSFrame:Show()
    elseif not TOSAccepted() then
        if ShowTOSNotice() then
            TOSNotice:SetText(TOS_NOTICE)
            TOSNotice:Show()
        end
        AccountLoginUI:Hide()
        TOSFrame.noticeType = "TOS"
        TOSFrameTitle:SetText(TOS_FRAME_TITLE)
        TOSFrameHeader:SetWidth(TOSFrameTitle:GetWidth())
        TOSScrollFrame:Show()
        TOSText:Show()
        TOSFrame:Show()
    elseif not IsScanDLLFinished() then
        AccountLoginUI:Hide()
        TOSFrame:Hide()
        local dllURL = ""
        if IsWindowsClient() then 
            dllURL = SCANDLL_URL_WIN32_SCAN_DLL 
        end
        ScanDLLStart(SCANDLL_URL_LAUNCHER_TXT, dllURL)
    else
        AccountLoginUI:Show()
        TOSFrame:Hide()
    end
end

function AccountLogin_UpdateAcceptButton(scrollFrame, isAcceptedFunc, noticeType)
    local scrollbar = _G[scrollFrame:GetName().."ScrollBar"]
    local min, max = scrollbar:GetMinMaxValues()
    
    if scrollbar:GetValue() >= max - Config.SCROLL_THRESHOLD then
        UICache.tosAccept:Enable()
    else
        if not isAcceptedFunc() and UICache.tosFrame.noticeType == noticeType then
            UICache.tosAccept:Disable()
        end
    end
end
-- ============================================================================
-- FUNCIONES DE CINEMATICS
-- ============================================================================
function CinematicsFrame_OnLoad(self)
    local numMovies = GetClientExpansionLevel()
    CinematicsFrame.numMovies = numMovies
    if numMovies < 2 then
        return
    end
    
    for i = 1, numMovies do
        _G["CinematicsButton"..i]:Show()
    end
    CinematicsBackground:SetHeight(numMovies * 40 + 70)
end

function CinematicsFrame_OnKeyDown(key)
    if key == "PRINTSCREEN" then
        Screenshot()
    else
        PlaySound("igMainMenuOptionCheckBoxOff")
        CinematicsFrame:Hide()
    end
end

function Cinematics_PlayMovie(self)
    CinematicsFrame:Hide()
    PlaySound("gsTitleOptionOK")
    MovieFrame.version = self:GetID()
    SetGlueScreen("movie")
end
-- ============================================================================
-- FUNCIONES AUXILIARES
-- ============================================================================
function string_explode(str, div)
    assert(type(str) == "string" and type(div) == "string", "invalid arguments")
    local o = {}
    while true do
        local pos1, pos2 = str:find(div, 1, true)
        if not pos1 then
            o[#o+1] = str
            break
        end
        o[#o+1], str = str:sub(1, pos1-1), str:sub(pos2+1)
    end
    return o
end
-- ============================================================================
-- TOKEN SYSTEM - FUNCIONES SIMPLES
-- ============================================================================
function TokenEnterDialog_Okay(self)
    local editBox = TokenEnterDialogBackgroundEdit
    if not editBox then return end
    
    local text = editBox:GetText()
    if not text or string.len(text) < 6 then return end
    
    TokenEntered(text)
    TokenEnterDialog:Hide()
end

function TokenEnterDialog_Cancel(self)
    if TokenEnterDialog then
        TokenEnterDialog:Hide()
    end
    CancelLogin()
end

function TokenEntry_Okay(self)
    TokenEnterDialog_Okay(self)
end

function TokenEntry_Cancel(self)
    TokenEnterDialog_Cancel(self)
end

function TokenEntryOkayButton_OnLoad(self)
    self:RegisterEvent("PLAYER_ENTER_TOKEN")
end

function TokenEntryOkayButton_OnEvent(self, event)
    if event == "PLAYER_ENTER_TOKEN" then
        if AccountLoginSaveAccountName:GetChecked() then
            if GetUsesToken() then
                if AccountLoginTokenEdit:GetText() ~= "" then
                    TokenEntered(AccountLoginTokenEdit:GetText())
                    return
                end
            else
                SetUsesToken(true)
            end
        end
        self:Show()
    end
end

function TokenEntryOkayButton_OnShow()
    if TokenEnterDialogBackgroundEdit then
        TokenEnterDialogBackgroundEdit:SetText("")
        TokenEnterDialogBackgroundEdit:SetFocus()
    end
end

function TokenEntryOkayButton_OnKeyDown(self, key)
    if key == "ENTER" then
        TokenEntry_Okay(self)
    elseif key == "ESCAPE" then
        TokenEntry_Cancel(self)
    end
end
-- ============================================================================