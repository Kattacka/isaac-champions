mod = RegisterMod("isaac-champions", 1)

mod.SaveManager = include("champscripts.utility.save_manager")
mod.HiddenItemManager = require("champscripts.utility.hidden_item_manager")

mod.SaveManager.Init(mod)
mod.HiddenItemManager:Init(mod)

local level = Game():GetLevel()
local seeds = Game():GetSeeds()
local stageSeed = seeds:GetStageSeed(level:GetStage())

local rng = RNG()
rng:SetSeed(stageSeed, 35)

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
--include("champscripts.forgotten")
include("champscripts.bethany")
include("champscripts.jacob")
--include("champscripts.isaac_b")
include("champscripts.maggy_b")
include("champscripts.cain_b")
include("champscripts.lazarus_b")
include("champscripts.apollyon_b")
include("champscripts.bluebaby_b")
include("champscripts.samson_b")
--include("champscripts.bethany_b")

--include("champscripts.keeper_b")
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

if EID then

  EID:setModIndicatorName("Isaac Champions ")
  EID:setModIndicatorIcon("Collectible"..CHAMPION_CROWN .."")

  EID:addCollectible(CHAMPION_CROWN,
  "{{TreasureRoomChance}} Has a different effect per character" ..
    "#{{Warning}} Effect not yet implemented for current character!"
  )


  local function remQualCon(descObj)
	  if descObj and descObj.ObjType == 5 and descObj.ObjVariant == 100 and descObj.ObjSubType == CHAMPION_CROWN then return true end
  end

  local function remQualCall(descObj)
	  descObj.Quality = nil
	  return descObj
  end
  EID:addDescriptionModifier("Remove Quality", remQualCon, remQualCall)

  local mySprite = Sprite()
  mySprite:Load("gfx/custom_ui/plus_minus.anm2", true)
  EID:addIcon("Plus", "plus", 1, 4, 4, 5, 5, mySprite)
  EID:addIcon("Minus", "minus", 1, 4, 4, 5, 5, mySprite)
end

function mod:addTrinkets(player, trinkets)
  local heldTrinket = player:GetTrinket(0)
  if not (heldTrinket == 0 or heldTrinket == nil) then
      player:TryRemoveTrinket(heldTrinket)
  end

  local heldTrinket2 = player:GetTrinket(0)
  if not (heldTrinket2 == 0 or heldTrinket2 == nil) then
      player:TryRemoveTrinket(heldTrinket2)
  end

  for i = 1, #trinkets do
      player:AddTrinket(trinkets[i])
      player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false)
  end

  if not (heldTrinket == 0 or heldTrinket == nil) then
    player:AddTrinket(heldTrinket)
  end

  if not (heldTrinket2 == 0 or heldTrinket2 == nil) then
    player:AddTrinket(heldTrinket2)
  end
end

function mod:addCollectibles(player, collectibles)
  for i = 1, #collectibles do
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

function mod:setBlindfold(player, enabled, updateCostume)
  local game = Game()
  local character = player:GetPlayerType()
  local challenge = Isaac.GetChallenge()

  if enabled then
    game.Challenge = Challenge.CHALLENGE_SOLAR_SYSTEM -- This challenge has a blindfold
    player:ChangePlayerType(character)
    game.Challenge = challenge

    if updateCostume then
      player:AddNullCostume(NullItemID.ID_BLINDFOLD)
    else
      player:TryRemoveNullCostume(NullItemID.ID_BLINDFOLD)
    end
  else
    game.Challenge = Challenge.CHALLENGE_NULL
    player:ChangePlayerType(character)
    game.Challenge = challenge

    if updateCostume then
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
        if player:HasCurseMistEffect() then
        mod:setBlindfold(player, false, true)
        else
          mod:setBlindfold(player, true, true)
        end
      end
    end
  end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.resetBlindfold)


--disable treasure rooms

local hasLoadedRooms = false
local needsToRestart = false
local newTreasureRoom
local gridIndex
function mod:loadRooms(isContinued)
  if hasLoadedRooms == true then return end
  hasLoadedRooms = true

  Isaac.ExecuteCommand("goto d." .. 100)
  local roomDescriptor = level:GetRoomByIdx(-3)
  local data = roomDescriptor.Data
  newTreasureRoom = data

  
  needsToRestart = not isContinued
  --Game():StartRoomTransition(gridIndex, Direction.NO_DIRECTION, RoomTransitionAnim.FADE)

end
mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED,CallbackPriority.IMPORTANT, mod.loadRooms)


function mod:OnNewRoom()
  if needsToRestart then
    needsToRestart = false
      Isaac.ExecuteCommand("restart")
  end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.IMPORTANT, mod.OnNewRoom)


function mod:RemoveTreasureRooms()
  local level = Game():GetLevel()
  local stageType = level:GetStageType()
  local rooms = level:GetRooms()
  local roomIndex

  if (level:GetStage() == LevelStage.STAGE1_2 and (stageType == StageType.STAGETYPE_REPENTANCE or stageType == StageType.STAGETYPE_REPENTANCE_B)) then return end
  if (level:GetStage() > LevelStage.STAGE5 or level:GetStage() == LevelStage.STAGE4_3) then return end
  local runData = mod.SaveManager.GetRunSave()
  if runData and runData.noTreasureRooms == true then
    for i = 0, rooms.Size-2, 1 do
      local room = rooms:Get(i)
      local data = room.Data
      if data.Type == RoomType.ROOM_TREASURE then
        roomIndex = room.GridIndex
        break
      end
    end
    if not roomIndex then return end
    local data = newTreasureRoom
    local writeableRoom = level:GetRoomByIdx(roomIndex, -1)
    writeableRoom.Data = data

    local room = Game():GetRoom()
    for i = 1, 7, 1 do
      local door = room:GetDoor(i)
      if door and door.TargetRoomType == RoomType.ROOM_TREASURE then
        door:SetRoomTypes(door.CurrentRoomType, RoomType.ROOM_DEFAULT)
        door:SetLocked(false)
      end
    end
  end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.LATE, mod.RemoveTreasureRooms)


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
