NugActionBar = CreateFrame("Frame", "NugActionBar", UIParent)

NugActionBar:SetScript("OnEvent", function(self, event, ...)
    self[event](self, event, ...)
end)

local UpdateUsable
NugActionBar:RegisterEvent("ADDON_LOADED")

local default = {
    hiderighthalf = true,
    movebottomright = true,
    replacedefault = true,
    changeoverlay = falsess,
    x = 0,
}
local db
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

function NugActionBar.ReplaceDefauitActionButtons()
    NugActionBar:RegisterEvent("PLAYER_LOGIN")

    -- VehicleMenuBar:Hide()
    -- VehicleMenuBar.Show = function() end
    -- BonusActionBarFrame:Hide()
    -- BonusActionBarFrame.Show = function() end
    MainMenuBar:Hide()
    MainMenuBar.Show = function() end
    MainMenuBarArtFrame:SetParent(UIParent)

    MainMenuBarArtFrame:ClearAllPoints()
    MainMenuBarArtFrame:SetWidth(1024)
    MainMenuBarArtFrame:SetHeight(53)
    MainMenuBarArtFrame:SetPoint("BOTTOM",UIParent,"BOTTOM",0,0)
    PetActionBarFrame:SetParent(UIParent)

    -- PetBattleFrame.BottomFrame:Hide()
    -- PetBattleFrame.BottomFrame.Show = function() end
    -- PetBattleFrame.BottomFrame.PetSelectionFrame:SetParent(bBars)
    PetBattleFrame.BottomFrame:SetFrameStrata("HIGH")


    MainMenuBar_UpdateArt = function() return true end

    IsNormalActionBarState = function() return true end

    MainMenuBarMaxLevelBar:SetParent(MainMenuBarArtFrame)
    MainMenuBarMaxLevelBar:SetPoint("TOP", MainMenuBarArtFrame, "TOP", 0,-11)
    MainMenuBarMaxLevelBar.SetPoint = function() end
    MainMenuBarMaxLevelBar.SetParent = function() end

    MainMenuExpBar:SetParent(MainMenuBarArtFrame)
    ReputationWatchBar:SetParent(MainMenuBarArtFrame)

    MultiBarBottomLeft:SetParent(UIParent)
    MultiBarBottomRight:SetParent(UIParent)
    MainMenuBarVehicleLeaveButton:SetParent(UIParent)

    NugActionBar.CreateLeaveButton()

    MultiActionBar_HideAllGrids = function() end

    NugActionBar.headers = {}
    ActionBarButtonEventsFrame:UnregisterAllEvents()
    table.insert(NugActionBar.headers, NugActionBar.CreateHeader("ActionButton", 1, true))
    table.insert(NugActionBar.headers, NugActionBar.CreateHeader("MultiBarBottomLeftButton", 6, nil))
    table.insert(NugActionBar.headers, NugActionBar.CreateHeader("MultiBarBottomRightButton", 5, nil))

    if NugActionBarDB_Character.ShortBar then
        NugActionBar.CreateShortBar(4)
        table.insert(NugActionBar.headers, NugActionBar.CreateHeader("NugActionBarShortButton", 1, true))
    end
end


local allowedSpellsSnippet
local _,class = UnitClass("player")
if class == "PRIEST" then
    allowedSpellsSnippet = [[
        healingSpells = table.new()
        healingSpells[2050] = true -- Heal
        healingSpells[2060] = true -- Greater Heal
        healingSpells[2061] = true -- Flash Heal
        healingSpells[32546] = true -- Binding Heal
        healingSpells[47540] = true -- Penance
        healingSpells[33076] = true -- Prayer of Mending
        healingSpells[596] = true -- Prayer of Healing
        healingSpells[17] = true -- Power Word: Shield
        healingSpells[139] = true -- Renew
        healingSpells[33206] = true -- Pain Suppression
        healingSpells[47788] = true -- Guardian Spirit
        healingSpells[34861] = true -- Circle of Healing
        healingSpells[527] = true -- Dispel
        healingSpells[528] = true -- Cure Disease        
        ----healingSpells[88684] = true -- Holy Word: Serenity
        healingSpells[73325] = true -- Leap of Faith
        healingSpells[10060] = true -- Power Infusion
    ]]
elseif class == "DRUID" then
    allowedSpellsSnippet = [[
        healingSpells = table.new()
        healingSpells[50464] = true -- Nourish
        healingSpells[774] = true -- Rejuvenation
        healingSpells[8936] = true -- Regrowth
        healingSpells[2782] = true -- Remove Corruption
        healingSpells[33763] = true -- Lifebloom
        healingSpells[5185] = true -- Healing Touch
        healingSpells[18562] = true -- Swiftmend
        healingSpells[48438] = true -- Wild Growth
    ]]
elseif class == "SHAMAN" then
    allowedSpellsSnippet = [[
        healingSpells = table.new()
        healingSpells[331] = true -- Healing Wave
        healingSpells[51886] = true -- Cleanse Spirit
        healingSpells[8004] = true -- Healing Surge
        healingSpells[1064] = true -- Chain Heal
        healingSpells[974] = true -- Earth Shield
        healingSpells[61295] = true -- Riptide
    ]]
elseif class == "PALADIN" then
    allowedSpellsSnippet = [[
        healingSpells = table.new()
        healingSpells[635] = true -- Holy Light
        healingSpells[85673] = true -- Word of Glory
        healingSpells[19750] = true -- Flash of Light
        healingSpells[633] = true -- Lay on Hands
        healingSpells[4987] = true -- Cleanse
        healingSpells[82326] = true -- Divine Light
        healingSpells[85222] = true -- Light of Dawn
        healingSpells[53563] = true -- Beacon of Light
        healingSpells[20473] = true -- Holy Shock
    ]]
else allowedSpellsSnippet = [[ healingSpells = table.new() ]] end

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
function NugActionBar.CreateHeader(rowName, page, doremap, mouseoverHealing)
    local header = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
    header:Execute[[ btns = table.new() ]]

    header:Execute([[ healbtns = table.new() ]])
    header:Execute(allowedSpellsSnippet)


    -- IsActionInRange has 2nd unit arg, and to support range updates on unit change
    -- it is required to patch tullaRange to use it
    -- Or i have to finally make internal range checking
    header:SetAttribute("_onstate-unit",[[
        for healbtn, _ in pairs(healbtns) do
            -- print("newunit", newstate, healbtn:GetName())
            healbtn:SetAttribute("unit", newstate)
            -- healbtn:CallMethod("UpdateUsableInRange",true)
        end
    ]])


    header:SetAttribute("check_spell", [[
        local action, index = ...
        local btn = btns[index]
        if HasAction(action) then
            local actionType, spellID = GetActionInfo(action)
            if actionType == "spell" and healingSpells[spellID] then
                print("adding "..btn:GetName().."to healbtns")
                healbtns[btn] = true
            end
        else
            btn:SetAttribute("unit", nil)
            healbtns[btn] = nil
        end
    ]])
    -- header:SetAttribute("_onstate-visibility",[[
    --     for i,btn in ipairs(btns) do
    --         print(newstate)
    --         if newstate == "show" then
    --             btn:Show()
    --         else btn:Hide()
    --         end
    --     end
    -- ]])

    header:SetAttribute("_onstate-remap",[[
        for i,btn in ipairs(btns) do
            newstate = tonumber(newstate)
            --if newstate == 0 then btn:Hide() -- hiding for petbattles
            --else

            btn:SetAttribute("actionpage",newstate)
            local page = btn:GetAttribute("actionpage")-1
            local action = page*12 + btn:GetAttribute("action")
            btn:CallMethod("SetActionID",action)
            if HasAction(action) then
                btn:Show()
            else
                if btn:GetAttribute("showgrid") == 0 then
                    btn:Hide()
                end
            end
            -- self:RunAttribute("check_spell",action, i)
            local animate = not (newstate >= 2 and newstate <= 6)
            btn:CallMethod("Update",true,animate)
            --end
        end
    ]])
    header:SetFrameLevel(3)
    -- table.insert(NugActionBar.headers,header)
    -- header:SetWidth(32)
    -- header:SetHeight(32)
    -- header:SetPoint("CENTER",UIParent, "CENTER",0,0)
    
    for i=1,12 do
        local btn = NugActionBar.CreateButton(header, rowName, page, i)
        if not btn then break end
        header:SetFrameRef("tmpbtn", btn)
        header:Execute[[
            local btn = self:GetFrameRef("tmpbtn")
            table.insert(btns,btn)
        ]]
    end

    header.doremap = doremap
    if doremap then RegisterStateDriver(header, "remap", NugActionBar.MakeStateDriverCondition()) end
    -- RegisterStateDriver(header, "visibility", "[petbattle] hide; show")
    RegisterStateDriver(header,"unit", "[@mouseover,help,exists,nodead] mouseover; [@target,help,exists,nodead] target; player")

    return header
end

local Mappings = {
    ["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] %s; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
    ["WARRIOR"] = "[stance:1] 7; [stance:2] 8; [stance:3] 9;",
    ['MONK'] = '[form:1] %s; [form:2] 7;',
    ["PRIEST"] = "[bonusbar:1] 7;",
    ["ROGUE"] = "[bonusbar:1] 7; [form:3] 8;",
    ["WARLOCK"] = "[form:2] 7;",
    ["BASE"] = "[bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6; [possessbar][vehicleui] 12; ", --[petbattle] 0; 
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
                           hooksecurefunc(NugActionBar,'ACTIONBAR_UPDATE_USABLE', tullaRange.UpdateButtonUsable)
                           hooksecurefunc(NugActionBar,'ACTIONBAR_UPDATE_USABLE', tullaRange.UpdateButtonUsable)
                           for _, hdr in ipairs(NugActionBar.headers) do
                               for i,frame in ipairs(hdr) do
                                   tullaRange.RegisterButton(frame)
                                   frame.UpdateUsableInRange = tullaRange.UpdateButtonUsable
                               end
                           end
                       end)
    end
    for _, hdr in ipairs(NugActionBar.headers) do
        for i,frame in ipairs(hdr) do
            NugActionBar.UpdateButton(frame, true)
        end
    end
end

local GetActionID = function(self)
    local page = self:GetAttribute("actionpage")-1
    return page*12 + self:GetAttribute("action")
end


local ButtonOnEvent = function(self,event, ...)
    if NugActionBar[event] then return NugActionBar[event](self, event, ...) end
end
local ButtonOnDragStart = function(self)
    local action = GetActionID(self)
    if ( LOCK_ACTIONBAR ~= "1" or IsModifiedClick("PICKUPACTION") ) then
        SpellFlyout:Hide()
        self.isDragging = true
        PickupAction(action)
    end
end
local ButtonOnReceiveDrag = function(self)
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
        else
            self:Hide()
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
function NugActionBar.CreateButton(header, rowName, page, index)
    -- local btn = CreateFrame("CheckButton", "NugActionBarButton"..index,header,
                    -- "SecureActionButtonTemplate, ActionButtonTemplate")
    local btn = _G[rowName..index]
    if not btn then return nil end
    btn:UnregisterAllEvents()
    btn.header = header
    btn:SetAttribute("type", "action");
    btn:SetAttribute("action",index)
    btn:SetAttribute("actionpage", page)
    btn.action = GetActionID(btn)
    btn:RegisterForDrag("LeftButton", "RightButton");
    btn:RegisterForClicks("AnyUp");

    btn:SetPushedTexture([[Interface\Cooldown\star4]])
    btn:GetPushedTexture():SetBlendMode("ADD")
    btn:GetPushedTexture():SetTexCoord(0.2,0.8,0.2,0.8)
    btn:GetPushedTexture():SetVertexColor(0.5,0.5,1)

    btn:SetID(index)
    -- local anchor = header[index-1] or header
    -- btn:SetPoint("LEFT",anchor,"RIGHT",6,0)
    header[index] = btn
    btn.index = index
    -- btn:Show()

    btn:SetScript("OnDragStart",ButtonOnDragStart)
    btn:SetScript("OnReceiveDrag",ButtonOnReceiveDrag)
    btn:SetScript("OnEnter",ButtonOnEnter)
    btn:SetScript("OnLeave",ButtonOnLeave)
    btn:SetScript("OnUpdate",ActionButton_OnUpdate)
    btn:SetScript("PostClick", NugActionBar.ACTIONBAR_UPDATE_STATE )

    btn:SetScript("OnEvent",ButtonOnEvent)
    btn:SetScript("OnAttributeChanged",nil)
    btn.Update = NugActionBar.UpdateButton
    -- btn.UpdateUsableInRange = function() end
    btn.SetActionID = SetActionID
    btn:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
    btn:RegisterEvent("ACTIONBAR_SHOWGRID")
    btn:RegisterEvent("ACTIONBAR_HIDEGRID")
    NugActionBar.ACTIONBAR_HIDEGRID(btn)

    if autocastOverlay then
        local shine = CreateFrame("Frame", "$parentShine", btn, "AutoCastShineTemplate")
        shine:SetScale(1.4)
        btn.acshine = shine
        shine:SetAllPoints(btn)
    end


    local t = header:CreateTexture(nil, "BACKGROUND", nil, 1)
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
    a2:SetDuration(0.4)
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

function NugActionBar.ACTIONBAR_UPDATE_STATE(self,event)
    local action = GetActionID(self)
    if ( action and (IsCurrentAction(action) or IsAutoRepeatAction(action)) ) then
        self:SetChecked(1)
    else
        self:SetChecked(0)
    end
end
function NugActionBar.ACTIONBAR_UPDATE_COOLDOWN(self,event)
    local action = GetActionID(self)
    local cooldown = _G[self:GetName().."Cooldown"];
    local start, duration, enable = GetActionCooldown(action);
    CooldownFrame_SetTimer(cooldown, start, duration, enable);
end
function NugActionBar.ACTIONBAR_UPDATE_USABLE(self,event, inRange)
    local action = GetActionID(self)
    local name = self:GetName();
    local icon = _G[name.."Icon"];
    local normalTexture = _G[name.."NormalTexture"];
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
UpdateUsable = NugActionBar.ACTIONBAR_UPDATE_USABLE
-- function NugActionBar.UPDATE_INVENTORY_ALERTS(self,event)
    -- print(event)
-- end
-- function NugActionBar.PLAYER_TARGET_CHANGED(self,event)
    -- print(event)
-- end
function NugActionBar.ACTIONBAR_SLOT_CHANGED(self,event, slot)
    local action = GetActionID(self)
    if action == slot or slot == 0 then
        NugActionBar.UpdateButton(self, InCombatLockdown() and true or false)
    end
end
function NugActionBar.ACTIONBAR_SHOWGRID(self,event)
    if InCombatLockdown() then return end

    local action = GetActionID(self)
    if not HasAction(action) or self.isDragging then
        self:Show()
        _G[self:GetName().."NormalTexture"]:SetVertexColor(1.0, 1.0, 1.0, 0.5);
        -- self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot")
    end
    self:SetAttribute("showgrid", 1)
end
function NugActionBar.ACTIONBAR_HIDEGRID(self,event)
    if InCombatLockdown() then return end

    local action = GetActionID(self)
    if not HasAction(action) then
        self:Hide()
    end
    self:SetAttribute("showgrid", 0)
    _G[self:GetName().."NormalTexture"]:SetVertexColor(1.0, 1.0, 1.0, 1);
end

function NugActionBar.UpdateSpellActivationOverlay(self)
    local action = GetActionID(self)
    local spellType, id, subType  = GetActionInfo(action)
    if ( spellType == "spell" and IsSpellOverlayed(id) ) then
        NugActionBar.SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(self,nil,id);
    else
        NugActionBar.SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(self,nil,id);
    end
end
function NugActionBar.UpdateFlash (self)
    local action = GetActionID(self)
    if ( (IsAttackAction(action) and IsCurrentAction(action)) or IsAutoRepeatAction(action) ) then
        ActionButton_StartFlash(self);
    else
        ActionButton_StopFlash(self);
    end
end

function NugActionBar.UpdateCount(self)
    local text = _G[self:GetName().."Count"];
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


function NugActionBar.PLAYER_ENTER_COMBAT(self,event)
    local action = GetActionID(self)
    if ( IsAttackAction(action) ) then ActionButton_StartFlash(self) end
end
function NugActionBar.PLAYER_LEAVE_COMBAT(self,event)
    local action = GetActionID(self)
    if ( IsAttackAction(action) ) then ActionButton_StopFlash(self) end
end
function NugActionBar.START_AUTOREPEAT_SPELL(self,event)
    local action = GetActionID(self)
    if ( IsAutoRepeatAction(action) ) then ActionButton_StartFlash(self) end
end
function NugActionBar.STOP_AUTOREPEAT_SPELL(self,event)
    local action = GetActionID(self)
    if ( ActionButton_IsFlashing(self) and not IsAttackAction(action) ) then
        ActionButton_StopFlash(self)
    end
end
function NugActionBar.SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(self,event, actionID)
    local action = GetActionID(self)
    local actionType, id, subType = GetActionInfo(action);
    if ( actionType == "spell" and id == actionID ) then
        if autocastOverlay then
            AutoCastShine_AutoCastStart(self.acshine)            
        else
            ActionButton_ShowOverlayGlow(self)
        end
    end
end
function NugActionBar.SPELL_UPDATE_CHARGES(self)
    NugActionBar.UpdateCount(self)
end
function NugActionBar.SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(self,event, actionID)
    local action = GetActionID(self)
    local actionType, id, subType = GetActionInfo(action);
    if autocastOverlay and ( actionType == "spell" and id == actionID ) then
        AutoCastShine_AutoCastStop(self.acshine)
    else
        ActionButton_HideOverlayGlow(self);
    end
end

function NugActionBar.UpdateButton(self, secure, animate)
    if not secure and InCombatLockdown() then return end

    -- if not secure then
        local hdr = self.header
        hdr:SetAttribute("updated_button_index", self.index)
        hdr:Execute[[
            local i = self:GetAttribute("updated_button_index")
            local btn = btns[i]
            local page = btn:GetAttribute("actionpage")-1
            local action = page*12 + btn:GetAttribute("action")
            self:RunAttribute("check_spell",action, i)
        ]]
    -- end

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

        NugActionBar.ACTIONBAR_UPDATE_USABLE(self)
        NugActionBar.ACTIONBAR_UPDATE_COOLDOWN(self)

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

        if not secure and self:GetAttribute("showgrid") == 0 then
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

    local action = GetActionID(self)
    local icon = self.icon
    local name = self:GetName()
    local buttonCooldown = _G[name.."Cooldown"]
    local texture = GetActionTexture(action)
    if ( texture ) then
        self.icon:SetTexture(texture)
        self.icon:Show()
        self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
    else
        self.icon:SetTexture(nil)
        icon:Hide();
        buttonCooldown:Hide();
        self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot")
    end

    -- local actionText = _G[name.."Name"];
    -- if ( not IsConsumableAction(action) and not IsStackableAction(action) ) then
    --     actionText:SetText(GetActionText(action));
    -- else
    --     actionText:SetText("");
    -- end
    NugActionBar.UpdateCount(self)

    NugActionBar.ACTIONBAR_UPDATE_STATE(self)

    ActionButton_UpdateFlyout(self)
    NugActionBar.UpdateFlash(self)

    NugActionBar.UpdateSpellActivationOverlay(self)

end
