require 'common'
require 'helper'
require 'SharedDataManager'

----------------------------------------------------------------------------------------------------
ItemTrackerDataManager = {maxItems = 10, maxKeyItems = 10};
ItemTrackerDataManager.__index = ItemTrackerDataManager;

local default_config = {generalLotMode = 'none', masterName='', items = {}, keyItems = {}};

----------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:create(addonPath)
    local inst = {};
    setmetatable(inst, ItemTrackerDataManager);

    inst.items = {};
    inst.keyItems = {};

    inst.addonPath = addonPath;
    inst.items = {};
    inst.keyItems = {};
    inst.inventoryItemCount = 0;
    inst.inventoryMaxItemCount = 0;
    inst.configPath = inst.addonPath .. 'settings/settings.json';
    inst.config = ashita.settings.load_merged(inst.configPath, default_config);

    inst.sharedData = SharedDataManager:create(addonPath, inst);

    return inst;
end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:update()
    local sharedDataChanged = false;

    for itemNumber, item in pairs(self.items) do
        local countBefore = item.count;
        local count = getItemCount(item.name);

        self.items[itemNumber].count = count;

        if ((item.share == true) and (countBefore ~= count)) then
            sharedDataChanged = true;
        end
    end

    local player = AshitaCore:GetDataManager():GetPlayer();
    for itemNumber, item in pairs(self.keyItems) do
        local countBefore = item.count;
        local keyItemId = getKeyItemId(item.name);

        local count = 0;
        if ((keyItemId ~= nil) and (player:HasKeyItem(keyItemId))) then
            count = 1;
        end

        self.keyItems[itemNumber].count = count

        if ((item.share == true) and (countBefore ~= count)) then
            sharedDataChanged = true;
        end
    end

    local itemCountBefore = self.inventoryItemCount;
    self.inventoryItemCount = getInventoryItemCount();
    self.inventoryMaxItemCount = getInventoryMax();

    if(itemCountBefore ~= self.inventoryItemCount ) then
        sharedDataChanged = true;
    end

    if ((self.playerName ~= nil) and (sharedDataChanged == true)) then
        self.sharedData:saveData(self.playerName);
        self.sharedData:sendUpdateCommand(self.playerName);
    end
end

----------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:isInventoryFull()
    local inventoryCount = self:getInventoryItemCount();
    local inventoryMax = self:getInventoryMaxItemCount();
    return (inventoryCount >= inventoryMax);
end

----------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:updateSharedData(playerName)
    if (playerName ~= self.playerName) then
        self.sharedData:loadData(playerName);
    end
end

----------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:clearSharedData()
    self.sharedData:clearData(self.playerName);
    self.sharedData:sendUpdateCommand(self.playerName);
end

----------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:loadConfig(playerName)
    self.playerName = playerName;
    self.configPath = self.addonPath .. 'settings/settings_' .. playerName ..
                          '.json';
    self:__loadConfig();
    self.sharedData:saveData(self.playerName);
end

----------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:__loadConfig()
    self.config = ashita.settings.load_merged(self.configPath, default_config);

    self.items = {};
    for itemNumber, item in pairs(self.config.items) do
        self.items[itemNumber] = {};
        self.items[itemNumber].name = item.name;
        self.items[itemNumber].mode = item.mode;
        self.items[itemNumber].share = item.share;
        self.items[itemNumber].count = 0;
        self.items[itemNumber].maxCount = item.maxCount;        
    end

    self.keyItems = {};
    for itemNumber, item in pairs(self.config.keyItems) do
        self.keyItems[itemNumber] = {};
        self.keyItems[itemNumber].name = item.name;
        self.keyItems[itemNumber].share = item.share;
        self.keyItems[itemNumber].count = 0;
    end
end

----------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:saveConfig()
    ashita.settings.save(self.configPath, self.config);
    self:__loadConfig();
    self.sharedData:saveData(self.playerName);
end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:clear(playerName)
    self.items = {};
    self.keyItems = {};

    self.config.masterName = '';
    self.config.generalLotMode = 'none';
    self.config.keyItems = {};
    self.config.items = {};
end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:getShared() return self.sharedData:getShared(); end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:getMaxItems() return self.maxItems; end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:getMaxKeyItems() return self.maxKeyItems; end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:setMaster(playerName)
    self.config.masterName = playerName;
end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:getMaster()
    return self.config.masterName;
end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:isMasterSet()
    return ((self.config.masterName ~= nil) and (self.config.masterName ~= ''));
end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:setGenralLotMode(modeString)
    self.config.generalLotMode = modeString;
end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:getGenralLotMode()
    return self.config.generalLotMode;
end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:generalLotModeStringToNumber(string)
    if (string == "lotAll") then
        return 1;
    elseif (string == "passAll") then
        return 2;
    end

    return 0;
end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:generalLotModeNumberToString(number)
    if (number == 1) then
        return "lotAll";
    elseif (number == 2) then
        return "passAll";
    end

    return "none";
end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:setKeyItem(listNumber, name, share)
    self.config.keyItems[listNumber] = {};
    self.config.keyItems[listNumber].name = name;
    self.config.keyItems[listNumber].share = share;
end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:getKeyItemName(listNumber)
    return self.config.keyItems[listNumber].name;
end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:getKeyItemCount(listNumber)
    return self.keyItems[listNumber].count;
end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:seItem(listNumber, name, modeString, maxCount,
                                       share)
    self.config.items[listNumber] = {};
    self.config.items[listNumber].name = name;
    self.config.items[listNumber].mode = modeString;
    self.config.items[listNumber].share = share;
    self.config.items[listNumber].maxCount = maxCount;
end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:getItemName(listNumber)
    return self.config.items[listNumber].name;
end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:getItemMode(listNumber)
    return self.config.items[listNumber].mode;
end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:getItemCount(listNumber)
    return self.items[listNumber].count;
end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:getItemMaxCount(listNumber)
    return self.config.items[listNumber].maxCount;
end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:getInventoryItemCount()
    return self.inventoryItemCount;
end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:getInventoryMaxItemCount()
    return self.inventoryMaxItemCount;
end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:getItems() return self.items; end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:getKeyItems() return self.keyItems; end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:getConfigItems() return self.config.items; end

---------------------------------------------------------------------------------------------------
function ItemTrackerDataManager:getConfigKeyItems() return self.config.keyItems; end
