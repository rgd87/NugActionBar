NugActionBar = CreateFrame("Frame", "NugActionBar", UIParent)

NugActionBar:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...)
end)

NugActionBar.Button = {}
local NugActionBarButton = NugActionBar.Button

NugActionBar:RegisterEvent("ADDON_LOADED")

BINDING_HEADER_NUGACTIONBAR = "NugActionBar"
_G["BINDING_NAME_CLICK NugActionBarButton1:LeftButton"] = "Nug Action Button 1"
_G["BINDING_NAME_CLICK NugActionBarButton2:LeftButton"] = "Nug Action Button 2"
_G["BINDING_NAME_CLICK NugActionBarButton3:LeftButton"] = "Nug Action Button 3"
_G["BINDING_NAME_CLICK NugActionBarButton4:LeftButton"] = "Nug Action Button 4"
_G["BINDING_NAME_CLICK NugActionBarButton5:LeftButton"] = "Nug Action Button 5"
_G["BINDING_NAME_CLICK NugActionBarButton6:LeftButton"] = "Nug Action Button 6"
_G["BINDING_NAME_CLICK NugActionBarButton7:LeftButton"] = "Nug Action Button 7"
_G["BINDING_NAME_CLICK NugActionBarButton8:LeftButton"] = "Nug Action Button 8"

local default = {
    hiderighthalf = true,
    movebottomright = true,
    replacedefault = true,
    changeoverlay = false,
    x = 0,
}
local db
local _G = _G
local autocastOverlay
local useTullaRange

function NugActionBar.ADDON_LOADED(self,event,arg1)
    if arg1 ~= "NugActionBar" then return end

    NugActionBarDB_Character = NugActionBarDB_Character or {}
    NugActionBarDB_Global = NugActionBarDB_Global or {}
    db = setmetatable(NugActionBarDB_Global, { __index = default } )
    
    NugActionBar.HideHotkeys()

    if db.movebottomright then
        NugActionBar.MoveBottomRightBar()
        NugActionBar.HideShapeshiftBar()
        NugActionBar.TrimPetBar()
    end

    if db.hiderighthalf then
        NugActionBar.HideRightPart()
    end
    if db.changeoverlay then autocastOverlay = true end
    if db.replacedefault then
        NugActionBar.ReplaceDefauitActionButtons()
    end
    NugActionBar.MoveNewBar(db.x,0)

    SLASH_TPETJOURNAL1 = "/pj"
    SlashCmdList["TPETJOURNAL"] = TogglePetJournal

    SLASH_NAB1= "/nab"
    SlashCmdList["NAB"] = NugActionBar.SlashCmd
end

NugActionBar.SlashCmd = function(msg)
    k,v = string.match(msg, "([%w%+%-%=]+) ?(.*)")
    if not k or k == "help" then print([[Usage:
      |cff00ff00/nab|r movebottomright
      |cff00ff00/nab|r hiderighthalf
      |cff00ff00/nab|r replacedefault
      |cff00ff00/nab|r changeoverlay
      |cff00ff00/nab|r move X]]
    )end
    if k == "movebottomright" then
        db.movebottomright = not db.movebottomright
        NugActionBar.MoveBottomRightBar()
        NugActionBar.HideShapeshiftBar()
        NugActionBar.TrimPetBar()
    end
    if k == "hiderighthalf" then
        db.hiderighthalf = not db.hiderighthalf
        NugActionBar.HideRightPart()
    end
    if k == "replacedefault" then
        db.replacedefault = not db.replacedefault
    end
    if k == "changeoverlay" then
        db.changeoverlay = not db.changeoverlay
    end
    if k == "move" then
        db.x = tonumber(v)
        NugActionBar.MoveNewBar(db.x,0)
    end
    if k == "shortbar" then
        NugActionBarDB_Character.ShortBar = not NugActionBarDB_Character.ShortBar 
    end
end


function NugActionBar.MoveNewBar(xo,yo)
    if db.replacedefault then
        MainMenuBarArtFrame:SetPoint("BOTTOM","UIParent","BOTTOM",xo,yo)
    end
end

local MSQ
local MSQG
function NugActionBar.ReplaceDefauitActionButtons()
    NugActionBar:RegisterEvent("PLAYER_LOGIN")
    NugActionBar:RegisterEvent("ACTIONBAR_SHOWGRID")
    NugActionBar:RegisterEvent("ACTIONBAR_HIDEGRID")
    NugActionBar:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
    -- VehicleMenuBar:Hide()
    -- VehicleMenuBar.Show = function() end
    -- BonusActionBarFrame:Hide()
    -- BonusActionBarFrame.Show = function() end
    UIParent_ManageFramePositions = function() end -- dunno if it'll help with taint or cause it too
    -- MainMenuBar:Hide()
    -- MainMenuBar.Show = function() end
    local prev
    for i=1,5 do
        local boss = _G["Boss"..i.."TargetFrame"]
        if boss then
            boss.ignoreFramePositionManager = true
            boss:ClearAllPoints()
            boss:SetPoint("TOPRIGHT", prev or MinimapCluster, "BOTTOMRIGHT", 0, -50)
            prev = boss
        end
    end
    -- Boss1TargetFrame.ignoreFramePositionManager = true
    -- Boss2TargetFrame.ignoreFramePositionManager = true
    -- Boss3TargetFrame.ignoreFramePositionManager = true
    -- OverrideActionBar:Hide()
    -- OverrideActionBar.Show = function() end
    -- OverrideActionBar.ignoreFramePositionManager = true
    -- OverrideActionBar:ClearAllPoints()
    -- OverrideActionBar:SetPoint("BOTTOM", UIParent, 0, -1000)
    MainMenuBarArtFrame:SetParent(UIParent)

    MainMenuBarArtFrame:ClearAllPoints()
    MainMenuBarArtFrame:SetWidth(1024)
    MainMenuBarArtFrame:SetHeight(53)
    MainMenuBarArtFrame:SetPoint("BOTTOM",UIParent,"BOTTOM",0,0)
    PetActionBarFrame:SetParent(UIParent)

    -- PetBattleFrame.BottomFrame:Hide() -- petbattles are not secure
    -- PetBattleFrame.BottomFrame.Show = function() end
    -- PetBattleFrame.BottomFrame.PetSelectionFrame:SetParent(bBars)
    PetBattleFrame.BottomFrame:SetFrameStrata("HIGH")


    -- MainMenuBar_UpdateArt = function() return true end

    -- IsNormalActionBarState = function() return true end -- taint

    MainMenuBarMaxLevelBar:SetParent(MainMenuBarArtFrame)
    MainMenuBarMaxLevelBar:SetPoint("TOP", MainMenuBarArtFrame, "TOP", 0,-11)
    MainMenuBarMaxLevelBar.SetPoint = function() end
    MainMenuBarMaxLevelBar.SetParent = function() end

    MainMenuExpBar:SetParent(MainMenuBarArtFrame)
    ReputationWatchBar:SetParent(MainMenuBarArtFrame)

    MultiBarBottomLeft:SetParent(UIParent)
    MultiBarBottomRight:SetParent(UIParent)
    MainMenuBarVehicleLeaveButton:SetParent(UIParent)

    local taintfucker = CreateFrame("Frame")
    taintfucker.frames_to_show = {}
    taintfucker.frames_to_hide = {}
    taintfucker:RegisterEvent("PLAYER_LEAVE_COMBAT")
    taintfucker:SetScript("OnEvent", function(self)
            for frame in pairs(self.frames_to_hide) do
                frame:Hide()
            end
            for frame in pairs(self.frames_to_show) do
                frame:Show()
            end
        end)
    local tfHide = function(self)
            if not InCombatLockdown() then
                return self:Hide1()
            else
                taintfucker.frames_to_hide[self] = true
                taintfucker.frames_to_show[self] = nil
            end
        end
    local tfShow = function(self)
            if not InCombatLockdown() then
                return self:Show1()
            else
                taintfucker.frames_to_show[self] = true
                taintfucker.frames_to_hide[self] = nil
            end
        end
    local fucktaint = function(bar)
        bar.Show1 = bar.Show
        bar.Hide1 = bar.Hide
        bar.Show = tfShow
        bar.Hide = tfHide
    end
    fucktaint(MultiBarBottomLeft)
    fucktaint(MultiBarBottomRight)
    fucktaint(MultiBarLeft)
    fucktaint(MultiBarRight)

    NugActionBar.CreateLeaveButton()

    MultiActionBar_ShowAllGrids = function() end
    MultiActionBar_HideAllGrids = function() end

    NugActionBar.headers = {}
    ActionBarButtonEventsFrame:UnregisterAllEvents()
    ActionBarActionEventsFrame:UnregisterAllEvents()
    ActionBarController:UnregisterAllEvents()
    -- ActionBarButtonEventsFrame_UnregisterFrame = function(frame) --it's new, not overriding anything secure
    --     for i, v in ipairs(ActionBarButtonEventsFrame.frames) do
    --         if v == frame then
    --             return table.remove(ActionBarButtonEventsFrame.frames, i)
    --         end
    --     end
    -- end

    -- MSQ = LibStub and LibStub("Masque")
    if MSQ then
        MSQG = MSQ:Group("NugActionBar", "NABGroup") 
    end

    table.insert(NugActionBar.headers, NugActionBar.CreateHeader("ActionButton", 1, true, nil, MSQG))
    table.insert(NugActionBar.headers, NugActionBar.CreateHeader("MultiBarBottomLeftButton", 6, nil, nil, MSQG))
    table.insert(NugActionBar.headers, NugActionBar.CreateHeader("MultiBarBottomRightButton", 5, nil))
    table.insert(NugActionBar.headers, NugActionBar.CreateHeader("MultiBarLeftButton", 4, nil))
    table.insert(NugActionBar.headers, NugActionBar.CreateHeader("MultiBarRightButton", 3, nil))
    local replacebags = true
    NugActionBar.CreateActionButtonRow("NugActionBarButton", replacebags and 12 or 8)
    if replacebags then
        CharacterBag0Slot:ClearAllPoints()
        CharacterBag0Slot:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 1000, 1000)
        local prev
        for i=9,12 do 
            local btn = _G["NugActionBarButton"..i]
            btn:SetScale(0.75)
            if not prev then btn:SetPoint("TOPLEFT", "MainMenuBarBackpackButton", "TOPLEFT", -168,-3)
            else             btn:SetPoint("TOPLEFT",  prev, "TOPRIGHT", 6,0) end
            prev = btn
        end
    end

    local nabb_page = select(2,UnitClass("player")) == "DRUID" and 2 or 10
    table.insert(NugActionBar.headers, NugActionBar.CreateHeader("NugActionBarButton", nabb_page, nil))
    local extra_header = NugActionBar.CreateHeader("ExtraActionButton", 15, nil)
    table.insert(NugActionBar.headers, extra_header)
    NugActionBar:ExtraActionButton(extra_header)

    -- if NugActionBarDB_Character.ShortBar then
        -- NugActionBar.CreateShortBar(4)
        -- table.insert(NugActionBar.headers, NugActionBar.CreateHeader("NugActionBarShortButton", 1, true))
    -- end

end

-- function MultiActionBar_Update()
--     if InCombatLockdown() then return end
--     local leftHeader = NugActionBar.headers[4]
--     local rightHeader = NugActionBar.headers[5]
--     for _,btn in ipairs(leftHeader) do
--         if SHOW_MULTI_ACTIONBAR_3 then
--             btn:Show()
--         else btn:Hide() end
--     end
--     for _,btn in ipairs(rightHeader) do
--         if SHOW_MULTI_ACTIONBAR_4 then
--             btn:Show()
--         else btn:Hide() end
--     end
-- end


-- local allowedSpellsSnippet
-- local _,class = UnitClass("player")
-- if class == "PRIEST" then
--     allowedSpellsSnippet = [[
--         healingSpells = table.new()
--         healingSpells[2050] = true -- Heal
--         healingSpells[2060] = true -- Greater Heal
--         healingSpells[2061] = true -- Flash Heal
--         healingSpells[32546] = true -- Binding Heal
--         healingSpells[47540] = true -- Penance
--         healingSpells[33076] = true -- Prayer of Mending
--         healingSpells[596] = true -- Prayer of Healing
--         healingSpells[17] = true -- Power Word: Shield
--         healingSpells[139] = true -- Renew
--         healingSpells[33206] = true -- Pain Suppression
--         healingSpells[47788] = true -- Guardian Spirit
--         healingSpells[34861] = true -- Circle of Healing
--         healingSpells[527] = true -- Purify
--         healingSpells[73325] = true -- Leap of Faith
--         healingSpells[10060] = true -- Power Infusion
--         healingSpells[88684] = true -- Holy Word: Serenity (it works!)
--     ]]
-- elseif class == "DRUID" then
--     allowedSpellsSnippet = [[
--         healingSpells = table.new()
--         healingSpells[50464] = true -- Nourish
--         healingSpells[774] = true -- Rejuvenation
--         healingSpells[8936] = true -- Regrowth
--         healingSpells[2782] = true -- Remove Corruption
--         healingSpells[33763] = true -- Lifebloom
--         healingSpells[5185] = true -- Healing Touch
--         healingSpells[18562] = true -- Swiftmend
--         healingSpells[48438] = true -- Wild Growth
--     ]]
-- elseif class == "SHAMAN" then
--     allowedSpellsSnippet = [[
--         healingSpells = table.new()
--         healingSpells[331] = true -- Healing Wave
--         healingSpells[51886] = true -- Cleanse Spirit
--         healingSpells[8004] = true -- Healing Surge
--         healingSpells[1064] = true -- Chain Heal
--         healingSpells[974] = true -- Earth Shield
--         healingSpells[61295] = true -- Riptide
--     ]]
-- elseif class == "PALADIN" then
--     allowedSpellsSnippet = [[
--         healingSpells = table.new()
--         healingSpells[635] = true -- Holy Light
--         healingSpells[85673] = true -- Word of Glory
--         healingSpells[19750] = true -- Flash of Light
--         healingSpells[633] = true -- Lay on Hands
--         healingSpells[4987] = true -- Cleanse
--         healingSpells[82326] = true -- Divine Light
--         healingSpells[85222] = true -- Light of Dawn
--         healingSpells[53563] = true -- Beacon of Light
--         healingSpells[20473] = true -- Holy Shock
--     ]]
-- else allowedSpellsSnippet = [[ healingSpells = table.new() ]] end

-- local HeaderRangeCheck = function(self,time)
--     self.OnUpdateCounter = (self.OnUpdateCounter or 0) + time
--     if self.OnUpdateCounter < 0.5 then return end
--     self.OnUpdateCounter = 0

--     for i,btn in ipairs(self) do
--         local runit = btn:GetAttribute("rangeunit")
--         if runit then
--             NugActionBar.ACTIONBAR_UPDATE_USABLE(btn,nil, UnitInRange(runit))
--         else
--             NugActionBar.ACTIONBAR_UPDATE_USABLE(btn,nil, IsActionInRange(GetActionID(btn)))    
--         end
--     end
-- end
function NugActionBar.CreateHeader(rowName, page, doremap, mouseoverHealing, masque_group)
    local header = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
    header:Execute[[ btns = table.new() ]]

    -- header:Execute([[ healbtns = table.new() ]])
    -- header:Execute(allowedSpellsSnippet)


    -- IsActionInRange has 2nd unit arg, and to support range updates on unit change
    -- it is required to patch tullaRange to use it
    -- Or i have to finally make internal range checking
    header:SetAttribute("_onstate-unit",[[
        for healbtn, _ in pairs(healbtns) do
            healbtn:SetAttribute("unit", newstate)
        end
    ]])


    -- header:SetAttribute("check_spell", [[
    --     local action, index = ...
    --     local btn = btns[index]
    --     local actionType, spellID = GetActionInfo(action)
    --     if actionType == "spell" and healingSpells[spellID] then
    --         healbtns[btn] = true
    --     else
    --         btn:SetAttribute("unit", nil)
    --         healbtns[btn] = nil
    --     end
    -- ]])
    -- header:SetAttribute("_onstate-visibility",[[
    --     for i,btn in ipairs(btns) do
    --         print(newstate)
    --         if newstate == "show" then
    --             btn:Show()
    --         else btn:Hide()
    --         end
    --     end
    -- ]])
    header:SetAttribute("_onattributechanged", [[
        if name ~= "showgrid" then return end
        local show = value == 1
        for i,btn in ipairs(btns) do
            if show then 
                btn:CallMethod("ShowGrid")
            else
                btn:CallMethod("HideGrid")
            end
        end
    ]])

    header:SetAttribute("_onstate-remap",[[
        for i,btn in ipairs(btns) do
            newstate = tonumber(newstate)
            --if newstate == 0 then btn:Hide() -- hiding for petbattles
            --else

            btn:SetAttribute("actionpage",newstate)
            local page = btn:GetAttribute("actionpage")-1
            local action = page*12 + btn:GetAttribute("action")
            btn:CallMethod("SetActionID",action)
            -- print("newstate", newstate, action, HasAction(action))
            if HasAction(action) or page >= 11 then
                -- HasAction is still returns nil at the point when remaping for vehicleui occurs
                btn:Show()
                btn:SetAttribute("statehidden", true)
            else
                if self:GetAttribute("showgrid") == 0 then
                    btn:Hide()
                    btn:SetAttribute("statehidden", nil)
                end
            end
            --self:RunAttribute("check_spell", action, i)
            -- local animate = not (newstate >= 2 and newstate <= 6)
            local animate = true
            btn:CallMethod("Update",true,animate)
            --end
        end
    ]])
    header:SetFrameLevel(3)
    -- table.insert(NugActionBar.headers,header)
    -- header:SetWidth(32)
    -- header:SetHeight(32)
    -- header:SetPoint("CENTER",UIParent, "CENTER",0,0)
    
    header:SetAttribute("showgrid", 0)
    for i=1,12 do
        local btn = NugActionBar.CreateButton(header, rowName, page, i)
        if not btn then break end
        header:SetFrameRef("tmpbtn", btn)
        if masque_group then
            masque_group:AddButton(btn)
        end
        header:Execute[[
            local btn = self:GetFrameRef("tmpbtn")
            table.insert(btns,btn)
        ]]
    end

    header.doremap = doremap
    if doremap then RegisterStateDriver(header, "remap", NugActionBar.MakeStateDriverCondition()) end
    -- RegisterStateDriver(header, "visibility", "[petbattle] hide; show")
    -- RegisterStateDriver(header,"unit", "[@mouseover,help,exists,nodead] mouseover; [@target,help,exists,nodead] target; player")

    return header
end

local Mappings = {
    ["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] %s; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
    -- ["WARRIOR"] = "[stance:1] 7; [stance:2] 8; [stance:3] 9;",
    ['MONK'] = '[form:1] %s; [form:2] 7;',
    ["PRIEST"] = "[bonusbar:1] 7;",
    ["ROGUE"] = "[bonusbar:1] 7; [form:3] 8;",
    ["WARLOCK"] = "[form:1] 7;",
    ["BASE"] = "[bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6; [overridebar][possessbar][vehicleui] 12; ", --[petbattle] 0; 
}
function NugActionBar.MakeStateDriverCondition()
    local class = select(2,UnitClass("player"))
    local special
    local spec = GetSpecialization()
    if class == "DRUID" then
        -- Handles prowling, prowling has no real stance, so this is a hack which utilizes the Tree of Life bar for non-resto druids.
        special = string.format(Mappings[class], (spec == 4) and 7 or 8) 
    elseif class == "MONK" then
        special = string.format(Mappings[class], (spec == 1 and 8 or spec == 2 and 9 or spec == 3 and 7 or 9))
    else
        special = Mappings[class] or ''
    end
    return Mappings.BASE .. special .. " 1"
end


function NugActionBar.PLAYER_LOGIN(self,event, arg1)
    useTullaRange = IsAddOnLoaded("tullaRange")
    if useTullaRange then
        hooksecurefunc(tullaRange, 'PLAYER_LOGIN',
                       function(self, event)
                           hooksecurefunc(NugActionBarButton,'ACTIONBAR_UPDATE_USABLE', tullaRange.UpdateButtonUsable)
                           hooksecurefunc(NugActionBarButton,'ACTIONBAR_UPDATE_USABLE', tullaRange.UpdateButtonUsable)
                           for _, hdr in ipairs(NugActionBar.headers) do
                               for i,frame in ipairs(hdr) do
                                   tullaRange.RegisterButton(frame)
                               end
                           end
                       end)
    end
    for _, hdr in ipairs(NugActionBar.headers) do
        for i,frame in ipairs(hdr) do
            NugActionBarButton.UpdateButton(frame, true)
        end
    end
end

local GetActionID = function(self)
    local page = self:GetAttribute("actionpage")-1
    return page*12 + self:GetAttribute("action")
end
NugActionBar.GetActionID = GetActionID


local ButtonOnEvent = function(self,event, ...)
    return NugActionBarButton[event](self, event, ...)
end
local ButtonOnDragStart = function(self)
    if InCombatLockdown() then return end
    local action = GetActionID(self)
    if ( LOCK_ACTIONBAR ~= "1" or IsModifiedClick("PICKUPACTION") ) then
        SpellFlyout:Hide()
        self.isDragging = true
        PickupAction(action)
    end
end
local ButtonOnReceiveDrag = function(self)
    if InCombatLockdown() then return end
    PlaceAction(GetActionID(self))
end
local UpdateTooltip = function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    if GameTooltip:SetAction(GetActionID(self)) then
        self.UpdateTooltip = UpdateTooltip
    else
        self.UpdateTooltip = nil
    end
end
local ButtonOnEnter = function(self)
    UpdateTooltip(self)
    ActionButton_UpdateFlyout(self)
end
local ButtonOnLeave = function(self)
    GameTooltip:Hide()
    ActionButton_UpdateFlyout(self)
end

function NugActionBar.CreateShortBar(n)
    local parent = CreateFrame("Frame","NugActionBarShortFrame",UIParent, "SecureHandlerStateTemplate")
    parent:SetAttribute("_onstate-combat",[[
        if newstate == "combat" then
            self:Show()
            self:SetAttribute("statehidden", true)
        else
            self:Hide()
            self:SetAttribute("statehidden", nil)
        end
    ]])
    RegisterStateDriver(parent, "combat", "[combat] combat; nocombat")
    parent:SetWidth(10)
    parent:SetHeight(10)
    parent:SetScale(0.8)
    parent:SetPoint("CENTER",UIParent,"CENTER",170,-50)
    local prev = parent
    for index=1,n do
        local btn = CreateFrame("CheckButton", "NugActionBarShortButton"..index,parent,
                    "SecureActionButtonTemplate, ActionBarButtonTemplate")
        btn:SetPoint("LEFT",prev,"RIGHT",6,0)
        prev = btn
    end
end

local SetActionID = function(self, action) self.action = action end
local ButtonShowGrid = function(btn)
            local action = GetActionID(btn)
            if not HasAction(action) or btn.isDragging then
                btn:Show()
                btn.normalTexture:SetVertexColor(1.0, 1.0, 1.0, 0.5);
                -- self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot")
            end
            -- btn:SetAttribute("showgrid", 1)
end
local ButtonHideGrid = function(btn)
            local action = GetActionID(btn)
            if not HasAction(action) then
                btn:Hide()
            end
            -- btn:SetAttribute("showgrid", 0)
            btn.normalTexture:SetVertexColor(1.0, 1.0, 1.0, 1);
end

function NugActionBar.ExtraActionButton(self, header)
    header:SetAttribute("_onstate-vata", [[
        for i,btn in ipairs(btns) do
            if newstate == 'show'
                then btn:Show()
                else btn:Hide()
            end
        end
    ]])
    RegisterStateDriver(header, "vata", "[extrabar] show; hide")

    header.isExtra = true

    local ebf = ExtraActionBarFrame
    ebf:SetParent(UIParent)
    ebf:ClearAllPoints()
    ebf:SetPoint("CENTER", UIParent, 0, -250)
    ebf.SetPoint = function() end --this is bad
    ebf.ignoreFramePositionManager = true

    local ppba = PlayerPowerBarAlt
    ppba:ClearAllPoints()
    ppba:SetPoint("CENTER", UIParent, 0, -150)
    ppba.ignoreFramePositionManager = true

    for i, btn in ipairs(header) do
        btn:SetParent(UIParent)
        btn:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")
    end
end

function NugActionBar.CreateActionButtonRow(rowName, n)
    local prev
    for i=1,n do
        local btn = CreateFrame("CheckButton", rowName..i, MainMenuBarArtFrame,
                    "SecureActionButtonTemplate, ActionButtonTemplate")
        if not prev then
            btn:SetPoint("TOPLEFT", MultiBarBottomLeftButton12, "TOPRIGHT", 150,0)
        else
            btn:SetPoint("LEFT", prev, "RIGHT", 6,0)
        end
        prev = btn
    end
end

local show_spark = function(self) self.spark:Show() end
local hide_spark = function(self) self.spark:Hide() end
function NugActionBar.CreateButton(header, rowName, page, index)
    -- local btn = CreateFrame("CheckButton", "NugActionBarButton"..index,header,
                    -- "SecureActionButtonTemplate, ActionButtonTemplate")
    local btn = _G[rowName..index]
    if not btn then return nil end
    -- ActionBarActionEventsFrame_UnregisterFrame(btn)
    -- ActionBarButtonEventsFrame_UnregisterFrame(btn)
    btn:UnregisterAllEvents()
    -- if btn.isExtra then
        -- btn:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")
    -- end

    btn.header = header
    btn:SetAttribute("type", "action");
    btn:SetAttribute("action",index)
    btn:SetAttribute("actionpage", page)
    btn.action = GetActionID(btn)
    btn:RegisterForDrag("LeftButton", "RightButton");
    btn:RegisterForClicks("AnyUp");

    -- local spark = btn:CreateTexture(nil, "ARTWORK")
    -- spark:SetTexture([[Interface\Cooldown\star4]])
    -- spark:Hide()
    -- spark:SetAllPoints(btn)
    -- spark:SetBlendMode("ADD")
    -- spark:SetTexCoord(0.2,0.8,0.2,0.8)
    -- spark:SetVertexColor(0.5,0.5,1)
    -- btn.spark = spark
    -- btn:SetScript("OnKeyDown", show_spark)
    -- btn:SetScript("OnMouseDown", show_spark)
    -- btn:SetScript("OnKeyUp", hide_spark)
    -- btn:SetScript("OnMouseUp", hide_spark)
    -- btn:SetPushedTexture([[Interface\Cooldown\star4]])
    -- btn:GetPushedTexture():SetTexCoord(0.2,0.8,0.2,0.8)
    -- btn:GetPushedTexture():SetVertexColor(0.5,0.5,1)
    btn:SetPushedTexture("Interface\\AddOns\\NugActionBar\\tPushed")
    local t = btn:GetPushedTexture()
    t:SetPoint("TOPLEFT", -15, 15)
    t:SetPoint("BOTTOMRIGHT", 15, -15)

    btn:SetCheckedTexture("Interface\\AddOns\\NugActionBar\\tChecked")
    btn:GetCheckedTexture():SetBlendMode("ADD")

    btn:SetHighlightTexture("Interface\\AddOns\\NugActionBar\\tHighlighted")
    btn:GetHighlightTexture():SetBlendMode("ADD")
    -- local show1 = t.Show
    -- t.Show = function(self) print("ASDADS"); show1(self) end
    -- local spark = btn:CreateTexture(nil, "ARTWORK")
    -- spark:SetParent(t)
    -- spark:SetTexture([[Interface\Cooldown\star4]])
    -- -- spark:Hide()
    -- spark:SetAllPoints(btn)
    -- spark:SetBlendMode("ADD")
    -- spark:SetTexCoord(0.2,0.8,0.2,0.8)
    -- spark:SetVertexColor(0.5,0.5,1)

    btn.count = _G[btn:GetName().."Count"]
    btn.icon = _G[btn:GetName().."Icon"]
    btn.cooldown = _G[btn:GetName().."Cooldown"]
    btn.normalTexture = _G[btn:GetName().."NormalTexture"]

    btn:SetID(index)
    -- local anchor = header[index-1] or header
    -- btn:SetPoint("LEFT",anchor,"RIGHT",6,0)
    header[index] = btn
    btn.index = index
    -- btn:Show()

    btn.icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)

    btn:SetScript("OnDragStart",ButtonOnDragStart)
    btn:SetScript("OnReceiveDrag",ButtonOnReceiveDrag)
    btn:SetScript("OnEnter",ButtonOnEnter)
    btn:SetScript("OnLeave",ButtonOnLeave)
    btn:SetScript("OnUpdate",ActionButton_OnUpdate)
    btn:SetScript("PostClick", NugActionBarButton.ACTIONBAR_UPDATE_STATE )

    btn:SetScript("OnEvent",ButtonOnEvent)
    btn:SetScript("OnAttributeChanged",nil)
    btn.Update = NugActionBarButton.UpdateButton
    btn.SetActionID = SetActionID
    btn.HideGrid = ButtonHideGrid
    btn.ShowGrid = ButtonShowGrid
    btn:HideGrid()

    if autocastOverlay then
        local shine = CreateFrame("Frame", "$parentShine", btn, "AutoCastShineTemplate")
        shine:SetScale(1.4)
        btn.acshine = shine
        shine:SetAllPoints(btn)
        ActionButton_HideOverlayGlow(btn);
    end


    local t = btn:CreateTexture(nil, "BACKGROUND", nil, 1)
    t:SetTexCoord(btn.icon:GetTexCoord())
    t:SetAllPoints(btn.icon)
    t:SetAlpha(0)
    btn.oldicon = t

    local ag = btn.oldicon:CreateAnimationGroup()
    local a1 = ag:CreateAnimation("Alpha")
    a1:SetChange(1)
    a1:SetDuration(0)
    a1:SetOrder(1)
    local a2 = ag:CreateAnimation("Alpha")
    a2:SetChange(-1)
    a2:SetDuration(0.2)
    a2:SetOrder(2)
    ag:SetScript("OnFinished",function(self)
        self:GetParent():SetAlpha(0)
    end)

    btn.anim = ag

    return btn
end

function NugActionBar.CreateLeaveButton(self)
    local f = CreateFrame("Button","NewLeaveButton", UIParent, "ActionButtonTemplate")
    f:SetScale(0.8)
    f.icon:SetTexture([[Interface\ICONS\spell_shadow_sacrificialshield]])
    f:SetPoint("RIGHT",ActionButton1,"LEFT",-10,0)
    f:SetFrameStrata("HIGH")
    f:SetScript("OnClick",VehicleExit)
    if UnitInVehicle("player") then f:Show() else f:Hide() end

    f:SetScript("OnEvent", function(self,event, unit)
        if event == "UNIT_ENTERED_VEHICLE" and unit == "player" then
            self:Show()
        else
            self:Hide()
        end
    end)
    f:RegisterEvent("UNIT_ENTERED_VEHICLE")
    f:RegisterEvent("UNIT_EXITED_VEHICLE")

    MainMenuBarVehicleLeaveButton:Hide()
    MainMenuBarVehicleLeaveButton.Show = function() end
end


----------------------------------------
-- Common event handlers
----------------------------------------
function NugActionBar.ACTIONBAR_SLOT_CHANGED(self,event, slot)
    for _, hdr in ipairs(NugActionBar.headers) do
        for _, btn in ipairs(hdr) do
            local action = GetActionID(btn)
            if action == slot or slot == 0 then
                NugActionBarButton.UpdateButton(btn, InCombatLockdown())
            end
        end
    end
end
function NugActionBar.ACTIONBAR_SHOWGRID(self,event)
    if InCombatLockdown() then return end

    for _, hdr in ipairs(NugActionBar.headers) do
        if not hdr.isExtra then
        hdr:SetAttribute("showgrid", 1)
        for _, btn in ipairs(hdr) do
            btn:ShowGrid()
        end
        end
    end
end
function NugActionBar.ACTIONBAR_HIDEGRID(self,event)
    if InCombatLockdown() then return end

    for _, hdr in ipairs(NugActionBar.headers) do
        if not hdr.isExtra then
        hdr:SetAttribute("showgrid", 0)
        for _, btn in ipairs(hdr) do
            btn:HideGrid()
        end
        end
    end
end
-- function NugActionBar.UPDATE_BINDINGS(self)
    -- if InCombatLockdown() then return end
    -- print("Bindings")
    -- local hdr = _G["NugActionBarHeader"]
    -- for i,frame in ipairs(hdr) do
    --     local key1, key2 = GetBindingKey(frame.originalBinding)
    --     if key1 then SetOverrideBindingClick(frame, false, key1,frame:GetName()) end
    --     if key2 then SetOverrideBindingClick(frame, false, key2,frame:GetName()) end
    -- end
-- end


-------------------------------------------------
--- Button level event handlers and methods
-------------------------------------------------
function NugActionBarButton.ACTIONBAR_UPDATE_STATE(self,event)
    local action = GetActionID(self)
    if ( action and (IsCurrentAction(action) or IsAutoRepeatAction(action)) ) then
        self:SetChecked(1)
    else
        self:SetChecked(0)
    end
end
function NugActionBarButton.ACTIONBAR_UPDATE_COOLDOWN(self,event)
    local action = GetActionID(self)
    local cooldown = self.cooldown
    local start, duration, enable = GetActionCooldown(action);
    CooldownFrame_SetTimer(cooldown, start, duration, enable);
end
function NugActionBarButton.ACTIONBAR_UPDATE_USABLE(self,event, inRange)
    local action = GetActionID(self)
    local name = self:GetName();
    local icon = self.icon
    local normalTexture = self.normalTexture
    local isUsable, notEnoughMana = IsUsableAction(action);
    if ( isUsable ) then
        icon:SetVertexColor(1.0, 1.0, 1.0);
        normalTexture:SetVertexColor(1.0, 1.0, 1.0);
    elseif ( notEnoughMana ) then
        icon:SetVertexColor(0.7, 0.7, 1.0);
        normalTexture:SetVertexColor(0.7, 0.7, 1.0);
    else
        icon:SetVertexColor(0.4, 0.4, 0.4);
        normalTexture:SetVertexColor(1.0, 1.0, 1.0);
    end
end

function NugActionBarButton.PLAYER_ENTER_COMBAT(self,event)
    local action = GetActionID(self)
    if ( IsAttackAction(action) ) then ActionButton_StartFlash(self) end
end
function NugActionBarButton.PLAYER_LEAVE_COMBAT(self,event)
    local action = GetActionID(self)
    if ( IsAttackAction(action) ) then ActionButton_StopFlash(self) end
end
function NugActionBarButton.START_AUTOREPEAT_SPELL(self,event)
    local action = GetActionID(self)
    if ( IsAutoRepeatAction(action) ) then ActionButton_StartFlash(self) end
end
function NugActionBarButton.STOP_AUTOREPEAT_SPELL(self,event)
    local action = GetActionID(self)
    if ( ActionButton_IsFlashing(self) and not IsAttackAction(action) ) then
        ActionButton_StopFlash(self)
    end
end
function NugActionBarButton.SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(self,event, actionID)
    local action = GetActionID(self)
    local actionType, id, subType = GetActionInfo(action);
    if ( actionType == "spell" and id == actionID ) then
        if autocastOverlay then
            AutoCastShine_AutoCastStart(self.acshine)            
        else
            ActionButton_ShowOverlayGlow(self)
        end
    elseif ( actionType == "macro" ) then
            local _, _, spellId = GetMacroSpell(id);
            if ( spellId and spellId == actionID ) then
                if autocastOverlay then
                    AutoCastShine_AutoCastStart(self.acshine)            
                else
                    ActionButton_ShowOverlayGlow(self)
                end
            end
    end
end
function NugActionBarButton.SPELL_UPDATE_CHARGES(self)
    NugActionBarButton.UpdateCount(self)
end

local DefaultExtraActionStyle = "Interface\\ExtraButton\\Default";
function NugActionBarButton.UPDATE_EXTRA_ACTIONBAR(self)
    local texture = GetOverrideBarSkin() or DefaultExtraActionStyle;
    self.style:SetTexture(texture);
    NugActionBarButton.UpdateButton(self, true)
end
function NugActionBarButton.SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(self,event, actionID)
    local action = GetActionID(self)
    local actionType, id, subType = GetActionInfo(action);
    if ( actionType == "spell" and id == actionID ) then
            if autocastOverlay then
                AutoCastShine_AutoCastStop(self.acshine)
            else
                ActionButton_HideOverlayGlow(self);
            end
    elseif ( actionType == "macro" ) then
        local _, _, spellId = GetMacroSpell(id);
        if (spellId and spellId == actionID ) then
            if autocastOverlay then
                AutoCastShine_AutoCastStop(self.acshine)
            else
                ActionButton_HideOverlayGlow(self);
            end
        end
    end
end



function NugActionBarButton.UpdateSpellActivationOverlay(self)
    local action = GetActionID(self)
    local spellType, id, subType  = GetActionInfo(action)
    if ( spellType == "spell" and IsSpellOverlayed(id) ) then
        NugActionBarButton.SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(self,nil,id);
    else
        NugActionBarButton.SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(self,nil,id);
    end
end
function NugActionBarButton.UpdateFlash (self)
    local action = GetActionID(self)
    if ( (IsAttackAction(action) and IsCurrentAction(action)) or IsAutoRepeatAction(action) ) then
        ActionButton_StartFlash(self);
    else
        ActionButton_StopFlash(self);
    end
end

function NugActionBarButton.UpdateCount(self)
    local text = self.count
    local action = GetActionID(self)
    if ( IsConsumableAction(action) or IsStackableAction(action) or (not IsItemAction(action) and GetActionCount(action) > 0) ) then
        local count = GetActionCount(action);
        if ( count > (self.maxDisplayCount or 9999 ) ) then
            text:SetText("*");
        else
            text:SetText(count);
        end
    else
        local charges, maxCharges, chargeStart, chargeDuration = GetActionCharges(action);
        if (maxCharges > 1) then
            text:SetText(charges);
        else
            text:SetText("");
        end
    end
end

function NugActionBarButton.UpdateButton(self, secure, animate)
    -- self should be button object
    if (not secure) and InCombatLockdown() then return end

    if not secure then
        local hdr = self.header
        hdr:SetAttribute("updated_button_index", self.index)
        -- hdr:Execute[[
        --     local i = self:GetAttribute("updated_button_index")
        --     local btn = btns[i]
        --     local page = btn:GetAttribute("actionpage")-1
        --     local action = page*12 + btn:GetAttribute("action")
        --     -- self:RunAttribute("check_spell",action, i)
        -- ]]
    end

    local action = GetActionID(self)

    if HasAction(action) then
        self:RegisterEvent("ACTIONBAR_UPDATE_STATE")
        self:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
        self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
        -- self:RegisterEvent("UPDATE_INVENTORY_ALERTS")
        -- self:RegisterEvent("PLAYER_TARGET_CHANGED")
        self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
        self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")
        self:RegisterEvent("START_AUTOREPEAT_SPELL")
        self:RegisterEvent("STOP_AUTOREPEAT_SPELL")
        self:RegisterEvent("PLAYER_ENTER_COMBAT")
        self:RegisterEvent("PLAYER_LEAVE_COMBAT")
        self:RegisterEvent("SPELL_UPDATE_CHARGES");

        NugActionBarButton.ACTIONBAR_UPDATE_USABLE(self)
        NugActionBarButton.ACTIONBAR_UPDATE_COOLDOWN(self)

        if not secure then self:Show() end
    else
        self:UnregisterEvent("ACTIONBAR_UPDATE_STATE")
        self:UnregisterEvent("ACTIONBAR_UPDATE_USABLE")
        self:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
        -- self:UnregisterEvent("UPDATE_INVENTORY_ALERTS")
        -- self:UnregisterEvent("PLAYER_TARGET_CHANGED")
        self:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
        self:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")
        self:UnregisterEvent("START_AUTOREPEAT_SPELL")
        self:UnregisterEvent("STOP_AUTOREPEAT_SPELL")
        self:UnregisterEvent("PLAYER_ENTER_COMBAT")
        self:UnregisterEvent("PLAYER_LEAVE_COMBAT")
        self:UnregisterEvent("SPELL_UPDATE_CHARGES");

        if not secure and self.header:GetAttribute("showgrid") == 0 then
            self:Hide()
        end
    end

    if animate then
        if not self.anim:IsPlaying() then
            self.oldicon:SetTexture(self.icon:GetTexture())
            self.oldicon:SetVertexColor(self.icon:GetVertexColor())
            self.anim:Play()
        end
    end

    NugActionBarButton.UpdateCount(self)
    NugActionBarButton.ACTIONBAR_UPDATE_STATE(self)
    ActionButton_UpdateFlyout(self)
    NugActionBarButton.UpdateFlash(self)
    NugActionBarButton.UpdateSpellActivationOverlay(self)

    local action = GetActionID(self)
    local icon = self.icon
    local name = self:GetName()
    local buttonCooldown = self.cooldown
    local texture = GetActionTexture(action)
    -- print(action, texture)
    -- if self == ExtraActionButton1 then
    --     print  ("EAB", texture)
    -- end
    if ( texture ) then
        self.icon:SetTexture(texture)
        self.icon:Show()
        -- self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
        self:SetNormalTexture("Interface\\AddOns\\NugActionBar\\tNormal")
    else
        self.icon:SetTexture(nil)
        icon:Hide();
        self.count:SetText("")
        buttonCooldown:Hide();
        self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot")
    end

    -- local actionText = _G[name.."Name"];
    -- if ( not IsConsumableAction(action) and not IsStackableAction(action) ) then
    --     actionText:SetText(GetActionText(action));
    -- else
    --     actionText:SetText("");
    -- end
end
