_addon.author = '7h03m3';
_addon.name = 'ItemTracker';
_addon.version = '0.0.1';

require 'common'
require 'imguidef'
require 'ItemTrackerSettingsGui'
require 'ItemTrackerItemGui'
require 'TreasurePoolManager'
require 'ItemTrackerDataManager'

----------------------------------------------------------------------------------------------------
local itemTrackerData = {};
itemTrackerData.settingsGui = nil;
itemTrackerData.itemGui = nil;
itemTrackerData.treasurePool = nil;
itemTrackerData.dataManager = nil;
itemTrackerData.loadConfigFirstTime = true;

----------------------------------------------------------------------------------------------------
local function event_load()
    itemTrackerData.dataManager = ItemTrackerDataManager:create(_addon.path);
    itemTrackerData.treasurePool = TreasurePoolManager:create(itemTrackerData);
    itemTrackerData.settingsGui = ItemTrackerSettingsGui:create(itemTrackerData);
    itemTrackerData.itemGui = ItemTrackerItemGui:create(itemTrackerData);

    itemTrackerData.settingsGui:update();
    itemTrackerData.settingsGui:disable();

    itemTrackerData.treasurePool:handlePool();
end

----------------------------------------------------------------------------------------------------
local function event_unload()
    itemTrackerData.dataManager:clearSharedData();
    itemTrackerData.dataManager = nil;
    itemTrackerData.treasurePool = nil;
    itemTrackerData.settingsGui = nil;
    itemTrackerData.itemGui = nil;
end

----------------------------------------------------------------------------------------------------
local lastUpdate = 0;
local function event_render()
    if (itemTrackerData.loadConfigFirstTime == true) then
        local player = GetPlayerEntity();
        if (player ~= nil) then
            itemTrackerData.dataManager:loadConfig(player.Name);
            itemTrackerData.loadConfigFirstTime = false;
        end
    end

    if (os.clock() >= lastUpdate + 1) then
        lastUpdate = os.clock();
        itemTrackerData.dataManager:update();
    end

    if (itemTrackerData.settingsGui ~= nil) then
        itemTrackerData.settingsGui:show();
    end

    if (itemTrackerData.itemGui ~= nil) then itemTrackerData.itemGui:show(); end
end

----------------------------------------------------------------------------------------------------
local function event_command(cmd, ntype)
    local args = cmd:args();
    if (args == nil or #args == 0 or args[1] ~= '/itemtracker') then
        return false;
    end

    if (args[2] == "settings") then
        if (itemTrackerData.settingsGui:isEnabled() == true) then
            itemTrackerData.settingsGui:disable();
        else
            itemTrackerData.settingsGui:enable();
        end
    elseif (args[2] == "share") then
        if (args[3] == "clear") then
            itemTrackerData.dataManager:clearSharedData();
        elseif ((args[3] == "update") and (#args == 4)) then
            local playerName = args[4];

            if (playerName ~= nil)  then
                itemTrackerData.dataManager:updateSharedData(playerName);
            else
                return false;
            end
       
        else
            return false;
        end
    else
        return false;
    end
    return true;
end

----------------------------------------------------------------------------------------------------
local function event_incomingPacket(id, size, packet)

    if (id == 0x00D2) then
        local itemId = struct.unpack('h', packet, 0x10 + 1);
        local itemSlot = struct.unpack('b', packet, 0x14 + 1);

        itemTrackerData.treasurePool:handleItem(itemSlot, itemId);
    end
    return false;
end

----------------------------------------------------------------------------------------------------
ashita.register_event('load', event_load);
ashita.register_event('unload', event_unload);
ashita.register_event('render', event_render);
ashita.register_event('command', event_command);
ashita.register_event('incoming_packet', event_incomingPacket);

