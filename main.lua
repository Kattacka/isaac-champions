mod = RegisterMod("isaac-champions", 1)

mod.SaveManager = include("champscripts.utility.save_manager")
mod.HiddenItemManager = require("champscripts.utility.hidden_item_manager")

mod.SaveManager.Init(mod)
mod.HiddenItemManager:Init(mod)

mod.Utility = include("champscripts.utility.champ_util")

include("champscripts.crown")
include("champscripts.isaac")
include("champscripts.maggy")
include("champscripts.cain")
include("champscripts.judas")
include("champscripts.bluebaby")
include("champscripts.eve")
include("champscripts.samson")
include("champscripts.apollyon")
include("champscripts.azazel")
include("champscripts.eden")
include("champscripts.lilith")
include("champscripts.lost")
include("champscripts.forgotten")
include("champscripts.bethany")
include("champscripts.jacob")
include("champscripts.isaac_b")
include("champscripts.maggy_b")
include("champscripts.cain_b")
include("champscripts.lazarus_b")
include("champscripts.apollyon_b")
include("champscripts.bluebaby_b")
include("champscripts.samson_b")
include("champscripts.bethany_b")


include("champscripts.eden_b")
include("champscripts.jacob_b")

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

local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")

function mod:addTrinkets(player, trinkets)
    for i = 1, #trinkets do
        player:AddTrinket(trinkets[i])
        player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false)
    end
end

function mod:addCollectibles(player, collectibles)
  for i = 1, #collectibles do
    print(collectibles[i])
    player:AddCollectible(collectibles[i])
    
end

end

function mod:getAllChampChars(character)
    local championChars = {}
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        
        if player:GetPlayerType() == character and player:HasCollectible(CHAMPION_CROWN) then
            table.insert(championChars, player)
        end
    end
    return championChars
end

function mod:setBlindfold(player, enabled, addCostume)
  local game = Game()
  local character = player:GetPlayerType()
  local challenge = Isaac.GetChallenge()

  if enabled then
    game.Challenge = Challenge.CHALLENGE_SOLAR_SYSTEM -- This challenge has a blindfold
    player:ChangePlayerType(character)
    game.Challenge = challenge

    if addCostume then
      player:AddNullCostume(NullItemID.ID_BLINDFOLD)
    else
      player:TryRemoveNullCostume(NullItemID.ID_BLINDFOLD)
    end
  else
    game.Challenge = Challenge.CHALLENGE_NULL
    player:ChangePlayerType(character)
    game.Challenge = challenge

    if addCostume then
      player:TryRemoveNullCostume(NullItemID.ID_BLINDFOLD)
    end
  end
end

function mod:resetBlindfold()
  local room = Game():GetRoom()
  local level = Game():GetLevel()

  local blindChampions = {
    PlayerType.PLAYER_APOLLYON_B,
    PlayerType.PLAYER_BLUEBABY_B,
    PlayerType.PLAYER_JACOB_B,
    PlayerType.PLAYER_MAGDALENE_B,
    PlayerType.PLAYER_JUDAS,
    PlayerType.PLAYER_BLACKJUDAS,
  }

  for i = 0, Game():GetNumPlayers() - 1 do
    local player = Isaac.GetPlayer(i)

    for i = 1, #blindChampions do 
      if player:GetPlayerType() == blindChampions[i] and player:HasCollectible(CHAMPION_CROWN) then
        mod:setBlindfold(player, true, true)
      end
    end
  end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.resetBlindfold)


--disable treasure rooms
function mod:preFloorTransition()
  local runData = mod.SaveManager.GetRunSave()
  print(runData.noTreasureRooms)
  if runData then
    if runData.noTreasureRooms == true then
      runData.challenge = Isaac.GetChallenge()
      Game().Challenge = Challenge.CHALLENGE_PURIST
    end
  end
end
mod:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, mod.preFloorTransition)


function mod:postFloorTransition()
  local runData = mod.SaveManager.GetRunSave()
  if runData then
    if runData.noTreasureRooms == true then
      runData.challenge = Isaac.GetChallenge()
      Game().Challenge = runData.challenge
    end
  end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.postFloorTransition)



function mod:PreSave(data)
  -- notice how this callback is provided the entire save file
  local hiddenItemData = mod.HiddenItemManager:GetSaveData()
-- Include` hiddenItemData` in your SaveData table!

  local save = mod.SaveManager.GetRunSave(nil)
  save.HIDDEN_ITEM_DATA = hiddenItemData
end

-- also notice that custom callbacks use a special function in the save manager!!!
mod.SaveManager.AddCallback(mod.SaveManager.Utility.CustomCallback.PRE_DATA_SAVE, mod.PreSave)

-- this primarily handles luamod
function mod:PostLoad(data)
  local save = mod.SaveManager.GetRunSave(nil)
  mod.HiddenItemManager:LoadData(save.HIDDEN_ITEM_DATA)
end
-- also notice that custom callbacks use a special function in the save manager!!!
mod.SaveManager.AddCallback(mod.SaveManager.Utility.CustomCallback.POST_DATA_LOAD, mod.PostLoad)

-- UnlockAPI wipes data on game start, which is later than the initial load, so load it again in that case.
function mod:PostLoadGameStart()
  local save = mod.SaveManager.GetRunSave(nil)
  mod.HiddenItemManager:LoadData(save.HIDDEN_ITEM_DATA)
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.PostLoadGameStart)
