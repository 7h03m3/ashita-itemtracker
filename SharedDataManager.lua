require 'common'
require 'helper'

----------------------------------------------------------------------------------------------------
SharedDataManager = {};
SharedDataManager.__index = SharedDataManager;

----------------------------------------------------------------------------------------------------
function SharedDataManager:create(addonPath, dataManager)
    local inst = {};
    setmetatable(inst, SharedDataManager);

    inst.fileDirectory = addonPath .. 'settings\\';
    inst.dataManager = dataManager;
    inst.shared = {};

    return inst;
end

---------------------------------------------------------------------------------------------------
function SharedDataManager:saveData(playerName)
    if ((playerName ~= nil) and (self.dataManager:isMasterSet() == true)) then
        local playerData = {};
        playerData.inventoryCount = self.dataManager:getInventoryItemCount();
        playerData.inventoryMaxCount =
            self.dataManager:getInventoryMaxItemCount();

        playerData.items = {};
        for itemNumber, item in pairs(self.dataManager:getItems()) do
            if (item.share == true) then
                playerData.items[item.name] = {};
                playerData.items[item.name].count = item.count;
                playerData.items[item.name].maxCount = item.maxCount;
            end
        end

        playerData.keyItems = {};
        for itemNumber, item in pairs(self.dataManager:getKeyItems()) do
            if (item.share == true) then
                playerData.keyItems[item.name] = {};
                playerData.keyItems[item.name].count = item.count;
            end
        end

        ashita.settings.save(self:__getSharedFileName(playerName), playerData);
    end
end

---------------------------------------------------------------------------------------------------
function SharedDataManager:loadData(playerName)
    if (playerName ~= nil) then
        self.shared[playerName] = ashita.settings.load(
                                      self:__getSharedFileName(playerName));
    end
end

---------------------------------------------------------------------------------------------------
function SharedDataManager:clearData(playerName)
    if (playerName ~= nil) then
        self.shared[playerName] = {}
        os.remove(self:__getSharedFileName(playerName));
    end
end

---------------------------------------------------------------------------------------------------
function SharedDataManager:getShared() return self.shared; end

---------------------------------------------------------------------------------------------------
function SharedDataManager:sendUpdateCommand(playerName)
    local master = self.dataManager:getMaster();
    if (self.dataManager:isMasterSet() == true) then
        local commandString = '/ms sendto ' .. self.dataManager:getMaster();
        commandString = commandString .. ' /itemtracker share update ' ..
                            playerName;
        AshitaCore:GetChatManager():QueueCommand(commandString,
                                                 CommandInputType.ForceHandle);
    end
end

---------------------------------------------------------------------------------------------------
function SharedDataManager:__getSharedFileName(playerName)
    return self.fileDirectory .. 'sharedData_' .. playerName .. '.json';
end
