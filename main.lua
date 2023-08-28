mod = RegisterMod("isaac-champions", 1)

local saveManager = include("mod.scripts.utility.save_manager") -- the path to the save manager, with different directories/folders separated by dots
saveManager.Init(mod)

-- In this example, the library file would be located at `...\The Binding of Isaac Rebirth\mods\<Your Mod's Folder>\myMod\lib\hidden_item_manager.lua`
-- But replace "myMod" with a different folder name, unique to your mod, to avoid collisions with other mods!
local hiddenItemManager = require("mod.scripts.utility.hidden_item_manager")

-- Make sure to call the Init function ONCE, before using any of the library's functions, and pass your mod reference to it.
hiddenItemManager:Init(mod)


include("scripts.isaac")
include("scripts.maggy")
include("scripts.judas")
include("scripts.bluebaby")
include("scripts.eve")
include("scripts.samson")
include("scripts.azazel")
include("scripts.eden")
include("scripts.lilith")
include("scripts.forgotten")
include("scripts.apollyon_b")
include("scripts.jacob_b")

local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local offsetFromRight = 180

--- Delay a function by an amount of frames
--- Provided by Xalum
---@param delay number
---@param func function
---@param args any
mod.ScheduleData = {}
function mod.Schedule(delay, func, args)
  table.insert(mod.ScheduleData, {
    Time = Game():GetFrameCount(),
    Delay = delay,
    Call = func,
    Args = args
  })
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
  local time = Game():GetFrameCount()
  for i = #mod.ScheduleData, 1, -1 do
    local data = mod.ScheduleData[i]
    if data.Time + data.Delay <= time then
      data.Call(table.unpack(data.Args))
      table.remove(mod.ScheduleData, i)
    end
  end
end)

function mod:PostPlayerInit(player, playerVariant)

    mod.Schedule(1, function ()
        --code to run in 1 frame

    if player.Parent ~= nil then return end
    local startingRoom = Game():GetRoom()
    local level = Game():GetLevel()
    local x = startingRoom:GetBottomRightPos().X
    local y = startingRoom:GetTopLeftPos().Y

    local finalVector = Vector(x - offsetFromRight, y)

    if (level:GetCurrentRoomIndex() ~= 84) then return end
        for i = 0, Game():GetNumPlayers()-2 do
            offsetFromRight = offsetFromRight - 20
            finalVector = Vector(x - offsetFromRight, y)
          end
        Isaac.Spawn(5, 100, CHAMPION_CROWN, finalVector, Vector.Zero, nil)
    end,{})

end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.PostPlayerInit, 0)


function mod:PostGameStart(isContinued)
    if isContinued == true then return end
    offsetFromRight = 180
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.PostGameStart)



function mod:enterRoom()
    local room = Game():GetRoom()
    local level = Game():GetLevel()

    if (room:IsFirstVisit() == true) then return end
    if (level:GetCurrentRoomIndex() ~= 84) then return end

    local entities = Isaac.GetRoomEntities()

    for i = 1, #entities do
    local entity = entities[i]

    if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE and entity.SubType == CHAMPION_CROWN then
        entity:Remove()
    end
end
    
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.enterRoom)


--    if (player:GetPlayerType() == PlayerType.PLAYER_JUDAS or player:GetPlayerType() == PlayerType.PLAYER_BLACKJUDAS) and
--not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
--    player:RemoveCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL)
--    player:AddCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
--end