require 'common'
require 'helper'
require 'imguidef'

----------------------------------------------------------------------------------------------------
ItemTrackerItemGui = {
    variables = {['var_itemWindow_show'] = {nil, ImGuiVar_BOOLCPP}}
};
ItemTrackerItemGui.__index = ItemTrackerItemGui;

----------------------------------------------------------------------------------------------------
function ItemTrackerItemGui:create(data)
    local gui = {};
    setmetatable(gui, ItemTrackerItemGui);

    for k, v in pairs(gui.variables) do
        -- Create the variable..
        if (v[2] >= ImGuiVar_CDSTRING) then
            gui.variables[k][1] = imgui.CreateVar(gui.variables[k][2],
                                                  gui.variables[k][3]);
        else
            gui.variables[k][1] = imgui.CreateVar(gui.variables[k][2]);
        end

        -- Set a default value if present..
        if (#v > 2 and v[2] < ImGuiVar_CDSTRING) then
            imgui.SetVarValue(gui.variables[k][1], gui.variables[k][3]);
        end
    end

    gui.data = data

    return gui;
end

----------------------------------------------------------------------------------------------------
function ItemTrackerItemGui:show()
    local window_flags = 0;

    window_flags = bit.bor(window_flags, ImGuiWindowFlags_AlwaysAutoResize);
    window_flags = bit.bor(window_flags, ImGuiWindowFlags_ShowBorders);

    imgui.SetNextWindowSize(550, 680, ImGuiSetCond_FirstUseEver);
    if (imgui.Begin('ItemTracker', self.variables['var_itemWindow_show'][1],
                    window_flags) == false) then
        imgui.End();
        return;
    end

    local hasItemEntries = false;
    for key, item in pairs(self.data.dataManager:getItems()) do
        hasItemEntries = true;

        if (item.mode == "pass") then
            local text = string.format("%-20s -- pass --", item.name)
            imgui.TextColored(0.4, 0.4, 0.4, 1.0, text);
        elseif ((item.mode == "lot") and (item.maxCount ~= 0)) then
            local text = string.format("%-20s %3d / %3d", item.name, item.count,
                                       item.maxCount)

            if (item.count >= item.maxCount) then
                imgui.TextColored(0.0, 1.0, 0.0, 1.0, text);
            else
                imgui.TextColored(1.0, 0.0, 0.0, 1.0, text);
            end
        elseif ((item.mode == "lot") and (item.maxCount == 0)) then
            local text = string.format("%-20s %9d", item.name, item.count)

            imgui.TextColored(1.0, 1.0, 1.0, 1.0, text);
        end
    end

    if (hasItemEntries == true) then imgui.Separator(); end

    local hasKeyItemEntries = false;
    local player = AshitaCore:GetDataManager():GetPlayer();
    for key, item in pairs(self.data.dataManager:getKeyItems()) do
        hasKeyItemEntries = true;

        if (item.count ~= 0) then
            imgui.TextColored(0.0, 1.0, 0.0, 1.0,
                              string.format("%-30s", item.name));
        else
            imgui.TextColored(1.0, 0.0, 0.0, 1.0,
                              string.format("%-30s", item.name));
        end
    end

    if (hasKeyItemEntries == true) then imgui.Separator(); end

    local lotMode = self.data.dataManager:getGenralLotMode();
    local string = string.format("%-20s %9s", "General mode", lotMode);
    imgui.TextColored(1.0, 1.0, 1.0, 1.0, string);

    imgui.Separator();

    local inventoryCount = self.data.dataManager:getInventoryItemCount();
    local inventoryMax = self.data.dataManager:getInventoryMaxItemCount();
    local inventoryString = string.format("%-20s %3d / %3d", "inventory:",
                                          inventoryCount, inventoryMax);

    if (inventoryCount >= inventoryMax) then
        imgui.TextColored(1.0, 0.0, 0.0, 1.0, inventoryString)
    else
        imgui.TextColored(1.0, 1.0, 1.0, 1.0, inventoryString)
    end

    for playerName, playerItems in pairs(self.data.dataManager:getShared()) do
        local hasItems = ((playerItems.items ~= nil) and
                             (table.empty(playerItems.items) == false));
        local hasKeyItems = ((playerItems.keyItems ~= nil) and
                                (table.empty(playerItems.keyItems) == false));

        local inventoryCount = playerItems.inventoryCount;
        if(inventoryCount == nil) then
            inventoryCount = 0;
        end

        local inventoryMaxCount = playerItems.inventoryMaxCount;
        if(inventoryMaxCount == nil) then
            inventoryMaxCount = 0;
        end

        imgui.Separator();

        if (((hasItems == true) or (hasKeyItems == true)) and
            (imgui.CollapsingHeader(playerName..' ('..inventoryCount..' / '..inventoryMaxCount..')', ImGuiTreeNodeFlags_DefaultOpen))) then

            if (hasItems == true) then
                for itemName, item in pairs(playerItems.items) do
                    if (item.maxCount ~= 0) then
                        local text = string.format("%-20s %3d / %3d", itemName,
                                                   item.count, item.maxCount)

                        if (item.count >= item.maxCount) then
                            imgui.TextColored(0.0, 1.0, 0.0, 1.0, text);
                        else
                            imgui.TextColored(1.0, 0.0, 0.0, 1.0, text);
                        end
                    else
                        local text = string.format("%-20s %9d", itemName,
                                                   item.count)

                        imgui.TextColored(1.0, 1.0, 1.0, 1.0, text);
                    end
                end
            end

            if((hasItems == true) and (hasKeyItems == true) ) then
                imgui.Separator();
            end

            if (hasKeyItems == true) then
                for itemName, item in pairs(playerItems.keyItems) do
                    if (item.count ~= 0) then
                        imgui.TextColored(0.0, 1.0, 0.0, 1.0,
                                          string.format("%-30s", itemName));
                    else
                        imgui.TextColored(1.0, 0.0, 0.0, 1.0,
                                          string.format("%-30s", itemName));
                    end
                end
            end
        end
    end

    imgui.End();
end
