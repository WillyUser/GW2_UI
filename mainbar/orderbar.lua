local _, GW = ...

local function orderFollower_OnEnter(self)
    if (self.name) then
        GameTooltip:SetOwner(self, "ANCHOR_PRESERVE")
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint("TOPLEFT", self.Count, "BOTTOMRIGHT", -20, -20)
        GameTooltip:AddLine(self.name)
        if (self.description) then
            GameTooltip:AddLine(self.description, 1, 1, 1, true)
        end
        GameTooltip:Show()
    end
end
GW.AddForProfiling("orderbar", "orderFollower_OnEnter", orderFollower_OnEnter)

local function createFollower(self, i)
    local newFrame = CreateFrame("FRAME", "GwOrderHallFollower" .. i, self, "GwOrderHallFollower")
    newFrame.Count:SetFont(UNIT_NAME_FONT, 14)
    newFrame.Count:SetShadowOffset(1, -1)
    newFrame:SetScript("OnEnter", orderFollower_OnEnter)
    newFrame:SetScript("OnLeave", GameTooltip_Hide)
    newFrame:SetParent(self)
    newFrame:ClearAllPoints()
    newFrame:SetPoint("LEFT", self.currency, "RIGHT", 100 * (i - 1), 0)
    return newFrame
end
GW.AddForProfiling("orderbar", "createFollower", createFollower)

local function updateOrderBar(self)
    local categoryInfo = C_Garrison.GetClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)

    for index, category in ipairs(categoryInfo) do
        local categoryInfoFrame = _G["GwOrderHallFollower" .. index]
        if _G["GwOrderHallFollower" .. index] == nil then
            categoryInfoFrame = createFollower(self, index)
        end

        categoryInfoFrame.Icon:SetTexture(category.icon)
        categoryInfoFrame.Icon:SetTexCoord(0, 1, 0.25, 0.75)
        categoryInfoFrame.name = category.name
        categoryInfoFrame.description = category.description

        categoryInfoFrame.Count:SetFormattedText(ORDER_HALL_COMMANDBAR_CATEGORY_COUNT, category.count, category.limit)

        categoryInfoFrame:Show()
    end
end
GW.AddForProfiling("orderbar", "updateOrderBar", updateOrderBar)

local function orderBar_OnEvent(self, event)
    if event ~= "PLAYER_ENTERING_WORLD" and not GW.inWorld then
        return
    end
    if OrderHallCommandBar then
        OrderHallCommandBar:SetShown(false)
        OrderHallCommandBar:UnregisterAllEvents()
        OrderHallCommandBar:SetScript("OnShow", Self_Hide)
    end

    local inOrderHall = C_Garrison.IsPlayerInGarrison(LE_GARRISON_TYPE_7_0)
    self:SetShown(inOrderHall)

    local primaryCurrency, _ = C_Garrison.GetCurrencyTypes(LE_GARRISON_TYPE_7_0)

    local _, amount, _ = GetCurrencyInfo(primaryCurrency)
    amount = BreakUpLargeNumbers(amount)
    self.currency:SetText(amount)

    updateOrderBar(self)
end
GW.AddForProfiling("orderbar", "orderBar_OnEvent", orderBar_OnEvent)

local function LoadOrderBar()
    CreateFrame("FRAME", "GwOrderhallBar", UIParent, "GwOrderhallBar")
    GwOrderhallBar.currency:SetFont(UNIT_NAME_FONT, 14)
    GwOrderhallBar.currency:SetShadowOffset(1, -1)

    GwOrderhallBar:RegisterUnitEvent("UNIT_AURA", "player")
    GwOrderhallBar:RegisterUnitEvent("UNIT_PHASE", "player")
    GwOrderhallBar:RegisterEvent("PLAYER_ALIVE")
    GwOrderhallBar:RegisterEvent("PLAYER_ENTERING_WORLD")

    local inOrderHall = C_Garrison.IsPlayerInGarrison(LE_GARRISON_TYPE_7_0)
    if inOrderHall then
        GwOrderhallBar:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
        GwOrderhallBar:RegisterEvent("DISPLAY_SIZE_CHANGED")
        GwOrderhallBar:RegisterEvent("UI_SCALE_CHANGED")
        GwOrderhallBar:RegisterEvent("GARRISON_TALENT_COMPLETE")
        GwOrderhallBar:RegisterEvent("GARRISON_TALENT_UPDATE")
        GwOrderhallBar:RegisterEvent("GARRISON_FOLLOWER_CATEGORIES_UPDATED")
        GwOrderhallBar:RegisterEvent("GARRISON_FOLLOWER_ADDED")
        GwOrderhallBar:RegisterEvent("GARRISON_FOLLOWER_REMOVED")
        GwOrderhallBar:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
        GwOrderhallBar:RegisterEvent("GARRISON_MISSION_FINISHED")
        GwOrderhallBar:RegisterEvent("UPDATE_BINDINGS")
    end

    GwOrderhallBar:SetScript("OnEvent", orderBar_OnEvent)
    GwOrderhallBar:SetScript(
        "OnShow",
        function()
            GwOrderhallBar:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
            GwOrderhallBar:RegisterEvent("DISPLAY_SIZE_CHANGED")
            GwOrderhallBar:RegisterEvent("UI_SCALE_CHANGED")
            GwOrderhallBar:RegisterEvent("GARRISON_TALENT_COMPLETE")
            GwOrderhallBar:RegisterEvent("GARRISON_TALENT_UPDATE")
            GwOrderhallBar:RegisterEvent("GARRISON_FOLLOWER_CATEGORIES_UPDATED")
            GwOrderhallBar:RegisterEvent("GARRISON_FOLLOWER_ADDED")
            GwOrderhallBar:RegisterEvent("GARRISON_FOLLOWER_REMOVED")
            GwOrderhallBar:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
            GwOrderhallBar:RegisterEvent("GARRISON_MISSION_FINISHED")
            GwOrderhallBar:RegisterEvent("UPDATE_BINDINGS")
        end
    )

    GwOrderhallBar:SetScript(
        "OnHide",
        function()
            GwOrderhallBar:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
            GwOrderhallBar:UnregisterEvent("DISPLAY_SIZE_CHANGED")
            GwOrderhallBar:UnregisterEvent("UI_SCALE_CHANGED")
            GwOrderhallBar:UnregisterEvent("GARRISON_TALENT_COMPLETE")
            GwOrderhallBar:UnregisterEvent("GARRISON_TALENT_UPDATE")
            GwOrderhallBar:UnregisterEvent("GARRISON_FOLLOWER_CATEGORIES_UPDATED")
            GwOrderhallBar:UnregisterEvent("GARRISON_FOLLOWER_ADDED")
            GwOrderhallBar:UnregisterEvent("GARRISON_FOLLOWER_REMOVED")
            GwOrderhallBar:UnregisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
            GwOrderhallBar:UnregisterEvent("GARRISON_MISSION_FINISHED")
            GwOrderhallBar:UnregisterEvent("UPDATE_BINDINGS")
        end
    )

    orderBar_OnEvent(GwOrderhallBar)
end
GW.LoadOrderBar = LoadOrderBar
