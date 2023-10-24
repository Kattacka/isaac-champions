IsaacChampions = RegisterMod("isaac-champions", 1)

IsaacChampions.SaveManager = include("champscripts.utility.save_manager")
IsaacChampions.HiddenItemManager = require("champscripts.utility.hidden_item_manager")

IsaacChampions.SaveManager.Init(IsaacChampions)
IsaacChampions.HiddenItemManager:Init(IsaacChampions)

local level = Game():GetLevel()
local seeds = Game():GetSeeds()
local stageSeed = seeds:GetStageSeed(level:GetStage())

local rng = RNG()
rng:SetSeed(stageSeed, 35)

IsaacChampions.Utility = include("champscripts.utility.champ_util")
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
IsaacChampions.ScheduleData = {}
function IsaacChampions.Schedule(delay, func, args)
  table.insert(IsaacChampions.ScheduleData, {
    Time = Game():GetFrameCount(),
    Delay = delay,
    Call = func,
    Args = args
  })
end

IsaacChampions:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
  local time = Game():GetFrameCount()
  for i = #IsaacChampions.ScheduleData, 1, -1 do
    local data = IsaacChampions.ScheduleData[i]
    if data.Time + data.Delay <= time then
      data.Call(table.unpack(data.Args))
      table.remove(IsaacChampions.ScheduleData, i)
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

function IsaacChampions:addTrinkets(player, trinkets)
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

function IsaacChampions:addCollectibles(player, collectibles)
  for i = 1, #collectibles do
    player:AddCollectible(collectibles[i])
    
end

end

function IsaacChampions:getAllChampChars(character)
    local championChars = {}
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        
        if player:GetPlayerType() == character and player:HasCollectible(CHAMPION_CROWN) then
            table.insert(championChars, player)
        end
    end
    return championChars
end

function IsaacChampions:setBlindfold(player, enabled, updateCostume)
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

function IsaacChampions:resetBlindfold()
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
        IsaacChampions:setBlindfold(player, false, true)
        else
          IsaacChampions:setBlindfold(player, true, true)
        end
      end
    end
  end
end
IsaacChampions:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, IsaacChampions.resetBlindfold)


--disable treasure rooms

local hasLoadedRooms = false
local needsToRestart = false
local newTreasureRoom
local gridIndex
function IsaacChampions:loadRooms(isContinued)
  if hasLoadedRooms == true then return end
  hasLoadedRooms = true

  Isaac.ExecuteCommand("goto d." .. 100)
  local roomDescriptor = level:GetRoomByIdx(-3)
  local data = roomDescriptor.Data
  newTreasureRoom = data

  
  needsToRestart = not isContinued
  --Game():StartRoomTransition(gridIndex, Direction.NO_DIRECTION, RoomTransitionAnim.FADE)

end
IsaacChampions:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED,CallbackPriority.IMPORTANT, IsaacChampions.loadRooms)


function IsaacChampions:OnNewRoom()
  if needsToRestart then
    needsToRestart = false
      Isaac.ExecuteCommand("restart")
  end
end
IsaacChampions:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.IMPORTANT, IsaacChampions.OnNewRoom)


function IsaacChampions:RemoveTreasureRooms()
  local level = Game():GetLevel()
  local stageType = level:GetStageType()
  local rooms = level:GetRooms()
  local roomIndex

  if (level:GetStage() == LevelStage.STAGE1_2 and (stageType == StageType.STAGETYPE_REPENTANCE or stageType == StageType.STAGETYPE_REPENTANCE_B)) then return end
  if (level:GetStage() > LevelStage.STAGE5 or level:GetStage() == LevelStage.STAGE4_3) then return end
  local runData = IsaacChampions.SaveManager.GetRunSave()
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
IsaacChampions:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.LATE, IsaacChampions.RemoveTreasureRooms)


function IsaacChampions:PreSave(data)
  -- notice how this callback is provided the entire save file
  local hiddenItemData = IsaacChampions.HiddenItemManager:GetSaveData()
-- Include` hiddenItemData` in your SaveData table!

  local save = IsaacChampions.SaveManager.GetRunSave(nil)
  if save then save.HIDDEN_ITEM_DATA = hiddenItemData end
end

-- also notice that custom callbacks use a special function in the save manager!!!
IsaacChampions.SaveManager.AddCallback(IsaacChampions.SaveManager.Utility.CustomCallback.PRE_DATA_SAVE, IsaacChampions.PreSave)

-- this primarily handles luamod
function IsaacChampions:PostLoad(data)
  local save = IsaacChampions.SaveManager.GetRunSave(nil)
  if save then IsaacChampions.HiddenItemManager:LoadData(save.HIDDEN_ITEM_DATA) end
end
-- also notice that custom callbacks use a special function in the save manager!!!
IsaacChampions.SaveManager.AddCallback(IsaacChampions.SaveManager.Utility.CustomCallback.POST_DATA_LOAD, IsaacChampions.PostLoad)

-- UnlockAPI wipes data on game start, which is later than the initial load, so load it again in that case.
function IsaacChampions:PostLoadGameStart()
  local save = IsaacChampions.SaveManager.GetRunSave(nil)
  if save then IsaacChampions.HiddenItemManager:LoadData(save.HIDDEN_ITEM_DATA) end
end
IsaacChampions:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, IsaacChampions.PostLoadGameStart)
