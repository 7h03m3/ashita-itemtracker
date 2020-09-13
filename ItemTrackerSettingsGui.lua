require 'common'
require 'imguidef'
require 'helper'

----------------------------------------------------------------------------------------------------
ItemTrackerSettingsGui = {
    variables = {
        ['var_aboutWindow_show'] = {nil, ImGuiVar_BOOLCPP},
        ['var_settingsWindow_show'] = {nil, ImGuiVar_BOOLCPP},
        ['var_generalLotMode'] = {nil, ImGuiVar_INT32, 0},
        ['var_masterName'] = {nil, ImGuiVar_CDSTRING, 128}
    }
};
ItemTrackerSettingsGui.__index = ItemTrackerSettingsGui;

----------------------------------------------------------------------------------------------------
function ItemTrackerSettingsGui:create(data)
    local gui = {};
    setmetatable(gui, ItemTrackerSettingsGui);

    gui.variables['var_generalLotMode'] = {nil, ImGuiVar_INT32, 0};
    gui.variables['var_masterName'] = {nil, ImGuiVar_CDSTRING, 128};

    local i = 1;
    local maxItems = data.dataManager:getMaxItems();
    while (i <= maxItems) do
        local itemPrefix = 'var_item_' .. i .. '_';
        gui.variables[itemPrefix .. 'name'] = {nil, ImGuiVar_CDSTRING, 128};
        gui.variables[itemPrefix .. 'mode'] = {nil, ImGuiVar_INT32, 2};
        gui.variables[itemPrefix .. 'lotCount'] = {nil, ImGuiVar_INT32, 0};
        gui.variables[itemPrefix .. 'share'] = {nil, ImGuiVar_BOOLCPP, false};

        i = i + 1;
    end

    local i = 1;
    local maxItems = data.dataManager:getMaxKeyItems();
    while (i <= maxItems) do
        local keyItemPrefix = 'var_keyItem_' .. i .. '_';
        gui.variables[keyItemPrefix .. 'name'] = {nil, ImGuiVar_CDSTRING, 128};
        gui.variables[keyItemPrefix .. 'share'] = {nil, ImGuiVar_BOOLCPP, false};

        i = i + 1;
    end

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

    gui.data = data;
    return gui;
end

----------------------------------------------------------------------------------------------------
function ItemTrackerSettingsGui:__showWindow_about()
    imgui.Begin("About ItemTracker", self.variables['var_aboutWindow_show'][1],
                ImGuiWindowFlags_AlwaysAutoResize);
    imgui.Text("By Thomas Stanger (7h03m3)");
    imgui.Text(
        "ItemTracker is licensed under the MIT License, see LICENSE for more information.");
    imgui.End();
end

----------------------------------------------------------------------------------------------------
function ItemTrackerSettingsGui:__updateConfig()
    self.data.dataManager:clear();

    self.data.dataManager:setMaster(imgui.GetVarValue(
                                        self.variables['var_masterName'][1]));

    local generalLotModeNumer = imgui.GetVarValue(
                                    self.variables['var_generalLotMode'][1]);

    local generalLotModeString =
        self.data.dataManager:generalLotModeNumberToString(generalLotModeNumer);
    self.data.dataManager:setGenralLotMode(generalLotModeString);

    local itemNumber = 1;
    local maxItems = self.data.dataManager:getMaxKeyItems();
    while (itemNumber <= maxItems) do
        local variablePrefix = 'var_keyItem_' .. itemNumber .. '_';
        local variableName = variablePrefix .. 'name';
        local variableShare = variablePrefix .. 'share';
        local keyItemName = imgui.GetVarValue(self.variables[variableName][1]);
        if ((keyItemName ~= nil) and (keyItemName ~= "")) then
            local share = imgui.GetVarValue(self.variables[variableShare][1]);
            self.data.dataManager:setKeyItem(itemNumber, keyItemName, share);
        end

        itemNumber = itemNumber + 1;
    end

    local itemNumber = 1;
    local maxItems = self.data.dataManager:getMaxItems();
    while (itemNumber <= maxItems) do
        local variablePrefix = 'var_item_' .. itemNumber;
        local variableName = variablePrefix .. '_name';
        local variableCount = variablePrefix .. '_lotCount';
        local variableMode = variablePrefix .. '_mode';
        local variableShare = variablePrefix .. '_share';
        local name = imgui.GetVarValue(self.variables[variableName][1])

        if ((name ~= nil) and (name ~= "")) then
            local count = imgui.GetVarValue(self.variables[variableCount][1]);
            local mode = imgui.GetVarValue(self.variables[variableMode][1]);
            local share = imgui.GetVarValue(self.variables[variableShare][1]);

            local modeString = "pass";
            if (mode == 1) then modeString = "lot" end

            self.data.dataManager:seItem(itemNumber, name, modeString, count,
                                         share)
        else
            imgui.SetVarValue(self.variables[variableMode][1], 0);
            imgui.SetVarValue(self.variables[variableCount][1], 0);
        end

        itemNumber = itemNumber + 1;
    end

    self.data.dataManager:saveConfig();
end

----------------------------------------------------------------------------------------------------
function ItemTrackerSettingsGui:isEnabled()
    return imgui.GetVarValue(self.variables['var_settingsWindow_show'][1]);
end

----------------------------------------------------------------------------------------------------
function ItemTrackerSettingsGui:enable()
    self:update();
    imgui.SetVarValue(self.variables['var_settingsWindow_show'][1], true);
end

----------------------------------------------------------------------------------------------------
function ItemTrackerSettingsGui:disable()
    imgui.SetVarValue(self.variables['var_settingsWindow_show'][1], false);
end

----------------------------------------------------------------------------------------------------
function ItemTrackerSettingsGui:show()
    if (imgui.GetVarValue(self.variables['var_aboutWindow_show'][1])) then
        self:__showWindow_about()
    end

    if (imgui.GetVarValue(self.variables['var_settingsWindow_show'][1]) == false) then
        return
    end

    local window_flags = 0;

    window_flags = bit.bor(window_flags, ImGuiWindowFlags_AlwaysAutoResize);
    window_flags = bit.bor(window_flags, ImGuiWindowFlags_ShowBorders);
    window_flags = bit.bor(window_flags, ImGuiWindowFlags_MenuBar);

    imgui.SetNextWindowSize(550, 680, ImGuiSetCond_FirstUseEver);
    if (imgui.Begin('ItemTracker settings',
                    self.variables['var_settingsWindow_show'][1], window_flags) ==
        false) then
        imgui.End();
        return;
    end

    if (imgui.BeginMenuBar()) then
        if (imgui.BeginMenu("Help")) then
            imgui.MenuItem("About", nil,
                           self.variables['var_aboutWindow_show'][1]);
            imgui.EndMenu();
        end
        imgui.EndMenuBar();
    end

    if (imgui.Button('Save')) then self:__updateConfig(); end
    imgui.SameLine();
    if (imgui.Button('Clear')) then self:__clear(); end
    imgui.SameLine();
    if (imgui.Button('Close')) then self:disable(); end

    imgui.Separator();
    imgui.Text('General lot mode:');
    imgui.SameLine();
    imgui.PushID(0xFE123);
    imgui.RadioButton('none', self.variables['var_generalLotMode'][1], 0);
    imgui.SameLine();
    imgui.RadioButton('lot all', self.variables['var_generalLotMode'][1], 1);
    imgui.SameLine();
    imgui.RadioButton('pass all', self.variables['var_generalLotMode'][1], 2);

    imgui.Separator();

    if (imgui.CollapsingHeader('Items')) then
        local i = 1
        local maxItems = self.data.dataManager:getMaxItems();
        while (i <= maxItems) do
            self:__addItemConfiguration(i);
            i = i + 1;
        end
    end

    if (imgui.CollapsingHeader('Key items')) then
        local i = 1
        local maxItems = self.data.dataManager:getMaxKeyItems();
        while (i <= maxItems) do
            self:__addKeyItemConfiguration(i);
            i = i + 1;
        end
    end

    if (imgui.CollapsingHeader('Shared data')) then
        imgui.InputText('master name', self.variables['var_masterName'][1], 128);
    end

    imgui.End();
end

----------------------------------------------------------------------------------------------------
function ItemTrackerSettingsGui:__addItemConfiguration(itemNumber)
    local variablePrefix = 'var_item_' .. itemNumber;
    imgui.PushID(itemNumber);
    imgui.InputText('name', self.variables[variablePrefix .. '_name'][1], 128);

    imgui.SameLine();
    imgui.RadioButton('pass', self.variables[variablePrefix .. '_mode'][1], 2);
    imgui.SameLine();
    imgui.RadioButton('lot', self.variables[variablePrefix .. '_mode'][1], 1);
    if (imgui.GetVarValue(self.variables[variablePrefix .. '_mode'][1]) == 1) then
        imgui.InputInt('amount',
                       self.variables[variablePrefix .. '_lotCount'][1]);
        imgui.SameLine();
        imgui.TextDisabled('(?)');
        if (imgui.IsItemHovered()) then imgui.SetTooltip('0 = infinite'); end

        imgui.SameLine();
        imgui.Checkbox('Share', self.variables[variablePrefix .. '_share'][1]);
    end

    imgui.Separator();
end

----------------------------------------------------------------------------------------------------
function ItemTrackerSettingsGui:__addKeyItemConfiguration(itemNumber)
    local variablePrefix = 'var_keyItem_' .. itemNumber .. '_';
    imgui.PushID(itemNumber);
    imgui.InputText('key item name',
                    self.variables[variablePrefix .. 'name'][1], 128);
    imgui.SameLine();
    imgui.Checkbox('Share', self.variables[variablePrefix .. 'share'][1]);

    imgui.Separator();
end

----------------------------------------------------------------------------------------------------
function ItemTrackerSettingsGui:__clear()
    self.data.dataManager:clear();

    imgui.SetVarValue(self.variables['var_generalLotMode'][1], 0);
    imgui.SetVarValue(self.variables['var_masterName'][1], '');

    local maxItems = self.data.dataManager:getMaxKeyItems();
    local itemNumber = 1;
    while (itemNumber <= maxItems) do
        local variablePrefix = 'var_keyItem_' .. itemNumber .. '_';
        imgui.SetVarValue(self.variables[variablePrefix .. 'name'][1], '');
        imgui.SetVarValue(self.variables[variablePrefix .. 'share'][1], false);

        itemNumber = itemNumber + 1;
    end

    local maxItems = self.data.dataManager:getMaxItems();
    local itemNumber = 1;
    while (itemNumber <= maxItems) do
        local variablePrefix = 'var_item_' .. itemNumber;

        imgui.SetVarValue(self.variables[variablePrefix .. '_name'][1], '');
        imgui.SetVarValue(self.variables[variablePrefix .. '_mode'][1], 2);
        imgui.SetVarValue(self.variables[variablePrefix .. '_lotCount'][1], 0);
        imgui.SetVarValue(self.variables[variablePrefix .. '_share'][1], false);

        itemNumber = itemNumber + 1;
    end

    self:__updateConfig();
    self:update();
end

----------------------------------------------------------------------------------------------------
function ItemTrackerSettingsGui:update()
    local master = self.data.dataManager:getMaster();
    imgui.SetVarValue(self.variables['var_masterName'][1], master);

    local modeString = self.data.dataManager:getGenralLotMode();
    local generalLotMode = self.data.dataManager:generalLotModeStringToNumber(
                               modeString);

    imgui.SetVarValue(self.variables['var_generalLotMode'][1], generalLotMode);

    for itemNumber, item in pairs(self.data.dataManager:getConfigKeyItems()) do
        local variablePrefix = 'var_keyItem_' .. itemNumber .. '_';
        imgui.SetVarValue(self.variables[variablePrefix .. 'name'][1], item.name);
        imgui.SetVarValue(self.variables[variablePrefix .. 'share'][1],
                          item.share);
    end

    for itemNumber, item in pairs(self.data.dataManager:getConfigItems()) do
        local variablePrefix = 'var_item_' .. itemNumber;
        local mode = -1

        if (item.mode == "lot") then
            mode = 1
        elseif (item.mode == "pass") then
            mode = 2
        end

        imgui.SetVarValue(self.variables[variablePrefix .. '_name'][1],
                          item.name);
        imgui.SetVarValue(self.variables[variablePrefix .. '_mode'][1], mode);
        imgui.SetVarValue(self.variables[variablePrefix .. '_lotCount'][1],
                          item.maxCount);
        imgui.SetVarValue(self.variables[variablePrefix .. '_share'][1],
                          item.share);

    end
end
