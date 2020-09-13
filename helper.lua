require 'common'

----------------------------------------------------------------------------------------------------
function logMessage(string, object)
    local txt = ""
    if (object ~= nil) then
        txt = '\31\200[\31\05' .. _addon.name .. '\31\200]\31\130 ' .. string ..
                  '\31\158 ' .. object;
    else
        txt = '\31\200[\31\05' .. _addon.name .. '\31\200]\31\130 ' .. string;
    end
    print(txt);
end

----------------------------------------------------------------------------------------------------
function getItemCount(itemName)
    local total = 0

    local inventory = AshitaCore:GetDataManager():GetInventory();

    for x = Containers.Inventory, Containers.Wardrobe4 do
        local maxSpace = inventory:GetContainerMax(x)
        for y = 0, maxSpace do
            local inventoryItem = inventory:GetItem(x, y);
            if (inventoryItem ~= nil) then
                local item = AshitaCore:GetResourceManager():GetItemById(
                                 inventoryItem.Id);

                if ((item ~= nil) and (string.lower(item.Name[0]) == string.lower(itemName))) then
                    total = total + inventoryItem.Count
                end
            end
        end
    end

    return total;
end

----------------------------------------------------------------------------------------------------
local keyItemsMap = nil;
function getKeyItemId(name)
    name = string.lower(name);

    if (keyItemsMap == nil) then
        keyItemsMap = {};
        for x = 0, 65535 do
            local keyName = string.lower(
                                AshitaCore:GetResourceManager():GetString(
                                    'keyitems', x));
            keyItemsMap[keyName] = {}
            keyItemsMap[keyName].id = x;
        end
    end

    if (keyItemsMap[name] ~= nil) then return keyItemsMap[name].id; end

    return nil;
end

----------------------------------------------------------------------------------------------------
function getInventoryMax()
    local inventory = AshitaCore:GetDataManager():GetInventory();
    return inventory:GetContainerMax(0) - 1;
end

----------------------------------------------------------------------------------------------------
function getInventoryItemCount()
    local inventory = AshitaCore:GetDataManager():GetInventory();
    local uinv = 0;
    for i = 1, inventory:GetContainerMax(0) do
        local item = inventory:GetItem(0, i - 1);
        if (item ~= nil and item.Id ~= 0) then uinv = uinv + 1; end
    end
    return uinv;
end

----------------------------------------------------------------------------------------------------
function table.empty (self)
    for _, _ in pairs(self) do
        return false
    end
    return true
end
