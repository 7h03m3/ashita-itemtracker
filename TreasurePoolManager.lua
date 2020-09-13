require 'common'
require 'helper'

----------------------------------------------------------------------------------------------------
TreasurePoolManager = {};
TreasurePoolManager.__index = TreasurePoolManager;

----------------------------------------------------------------------------------------------------
function TreasurePoolManager:create(data)
    local inst = {};
    setmetatable(inst, TreasurePoolManager);

    self.data = data;

    return inst;
end

----------------------------------------------------------------------------------------------------
function TreasurePoolManager:handlePool()
    local inventory = AshitaCore:GetDataManager():GetInventory();

    for slot = 0, 9 do
        local treasureItem = AshitaCore:GetDataManager():GetInventory()
                                 :GetTreasureItem(slot);
        if ((treasureItem ~= nil) and (treasureItem.ItemId ~= 0)) then
            self:handleItem(slot, treasureItem.ItemId);
        end
    end
end

----------------------------------------------------------------------------------------------------
function TreasurePoolManager:handleItem(itemSlot, itemId)
    local treasureItem = AshitaCore:GetResourceManager():GetItemById(itemId);

    if (treasureItem ~= nil) then
        logMessage('dropped item', treasureItem.Name[0]);

        for itemNumber, item in pairs(self.data.dataManager:getItems()) do
            if (string.lower(item.name) == string.lower(treasureItem.Name[0])) then
                if ((item.mode == "lot") and (item.maxCount == 0)) then
                    self:__lotItem(itemSlot, treasureItem.Name[0]);
                    return false;
                elseif (item.mode == "lot") then
                    local itemCount = getItemCount(treasureItem.Name[0])
                    if (itemCount < item.maxCount) then
                        self:__lotItem(itemSlot);
                        return false;
                    else
                        self:__passItem(itemSlot, treasureItem.Name[0]);
                        return false;
                    end
                elseif (item.mode == "pass") then
                    self:__passItem(itemSlot, treasureItem.Name[0]);
                    return false;
                end
            end
        end

        local generalLotMode = self.data.dataManager:getGenralLotMode();
        if (generalLotMode == "lotAll") then
            self:__lotItem(itemSlot, treasureItem.Name[0]);
            return false;
        elseif (generalLotMode == "passAll") then
            self:__passItem(itemSlot, treasureItem.Name[0]);
            return false;
        end
    end
end

----------------------------------------------------------------------------------------------------
function TreasurePoolManager:__passItem(itemSlot, itemName)
    local passItem = struct.pack("bbbbbbb", 0x42, 0x04, 0x00, 0x00, itemSlot,
                                 0x00, 0x00, 0x00):totable();
    AddOutgoingPacket(0x42, passItem);
    logMessage('pass item', itemName);
end

----------------------------------------------------------------------------------------------------
function TreasurePoolManager:__lotItem(itemSlot, itemName)
    if(self.data.dataManager:isInventoryFull() == false) then
        local lootItem = struct.pack("bbbbbbb", 0x41, 0x04, 0x00, 0x00, itemSlot,
                                     0x00, 0x00, 0x00):totable();
        AddOutgoingPacket(0x41, lootItem);
        logMessage('lot item', itemName);
    end

end
