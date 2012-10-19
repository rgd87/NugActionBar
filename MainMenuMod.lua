function NugActionBar.HideHotkeys()
    local bars = {"ActionButton","MultiBarBottomLeftButton","MultiBarBottomRightButton","MultiBarLeftButton","MultiBarRightButton"}
    for _,bar in ipairs(bars) do
        for i = 1,12 do
            local btn = getglobal(bar..i)
            local name = getglobal(bar..i.."Name")
            local hotkey = getglobal(bar..i.."HotKey")
            local border = getglobal(bar..i.."Border")
            name:Hide();  name.Show = function() end;
            hotkey:Hide();  hotkey.Show = function() end;
            border:Hide();  border.Show = function() end;   -- green item border
            
            -- pushed state flash
            -- btn:SetPushedTexture([[Interface\Cooldown\star4]])
            -- btn:GetPushedTexture():SetBlendMode("ADD")
            -- btn:GetPushedTexture():SetTexCoord(0.2,0.8,0.2,0.8)
            -- btn:GetPushedTexture():SetVertexColor(0.5,0.5,1)
        end
    end
end

function NugActionBar.HideRightPart()
    MainMenuBarTexture2:Hide();
    MainMenuBarTexture3:Hide();
    
    
    local MicroButtons = {
        CharacterMicroButton,
        SpellbookMicroButton,
        TalentMicroButton,
        AchievementMicroButton,
        QuestLogMicroButton,
        GuildMicroButton,
        PVPMicroButton,
        LFDMicroButton,
        CompanionsMicroButton,
        EJMicroButton,
        MainMenuMicroButton,
        HelpMicroButton,
        RaidMicroButton,
    }
    for _,mbtn in ipairs(MicroButtons) do
        hooksecurefunc(mbtn,"Show",function(self)
            self:Hide()
        end)
        mbtn:Hide()
    end
    
    
    --disable exp bar
    ReputationWatchBar:UnregisterAllEvents()
    ExhaustionTick:UnregisterAllEvents()
    MainMenuExpBar:Hide();
    MainMenuExpBar.pauseUpdates = true;
    MainMenuBarMaxLevelBar:Show();
    ExhaustionTick:Hide();
    
--~     -- short expbar
--~     MainMenuExpBar_SetWidth(512)
--~     MainMenuExpBar:ClearAllPoints()
--~     MainMenuExpBar:SetPoint("TOPLEFT",0,0)
    
    MainMenuBar:EnableMouse(false)
    MainMenuBarBackpackButton:ClearAllPoints();
    MainMenuBarBackpackButton:SetPoint("BOTTOMLEFT", "UIParent","BOTTOM" , 0, -200);
    
    ActionBarDownButton:Hide()
    ActionBarUpButton:Hide()
    MainMenuBarPageNumber:Hide()
--~     MainMenuBarLeftEndCap:Hide()
--~     MainMenuBarRightEndCap:Hide()
    MainMenuBarRightEndCap:SetPoint("BOTTOMLEFT", MainMenuBarArtFrame,"BOTTOMRIGHT" , -543, 0) 
    
    MainMenuMaxLevelBar2:Hide()
    MainMenuMaxLevelBar3:Hide()
end

function NugActionBar.TrimPetBar()
    -- local ShowPetActionBar1 = ShowPetActionBar
    -- ShowPetActionBar = function() return ShowPetActionBar1(false) end
    -- for i=1,12 do
        -- local petbtn = _G["PetActionButton"..i]
        -- if not petbtn then break end
        -- petbtn:SetParent(MainMenu
    -- end
    --hide attack follow stay buttons
    PetActionButton1:ClearAllPoints()
    PetActionButton1:SetPoint("TOPLEFT", "ActionButton1", "BOTTOMLEFT", -90, -500);
    
    -- 4 spell buttons
    PetActionButton4:ClearAllPoints()
    PetActionButton4:SetPoint("BOTTOMLEFT", "MultiBarBottomLeftButton1", "TOPLEFT", 15, 7);
    
    --hide agressive button
    PetActionButton8:ClearAllPoints()
    PetActionButton8:SetPoint("TOPLEFT", "ActionButton1", "BOTTOMLEFT", -90, -500);
    
    PetActionButton8:ClearAllPoints()
    PetActionButton8:SetPoint("TOPLEFT", "ActionButton1", "BOTTOMLEFT", -90, -500);
    
--~ for 4 buttons
    PetActionButton9:ClearAllPoints()
    PetActionButton9:SetPoint("BOTTOMRIGHT", PetActionButton4, "BOTTOMLEFT", -8, 0);    
    PetActionButton9:SetScale(0.7)
    
    PetActionButton10:ClearAllPoints()
    --PetActionButton10:SetPoint("BOTTOMRIGHT", PetActionButton4, "BOTTOMLEFT", -20, 0);    
    PetActionButton10:SetPoint("BOTTOMRIGHT", PetActionButton9, "BOTTOMLEFT", -8, 0);    
    PetActionButton10:SetScale(0.7)
end

function NugActionBar.MoveBottomRightBar()
    MultiBarBottomRight:SetScale(0.8)
    MultiBarBottomRightButton1:ClearAllPoints()
    MultiBarBottomRightButton1:SetPoint("BOTTOMLEFT","MultiBarBottomLeftButton1","TOPLEFT",120,10)
end

function NugActionBar.HideShapeshiftBar()
    local dummyframe = CreateFrame("Frame")
    StanceBarFrame:SetParent(dummyframe)
    dummyframe:Hide()
end