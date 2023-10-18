local crown = {}

local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local offsetFromRight = 180

function crown:PostPlayerInit(player, playerVariant)

  local save = mod.SaveManager.GetRunSave()
  if save.crownsSpawned == nil then
    return
  else
    save.crownsSpawned = save.crownsSpawned + 1
    print(save.crownsSpawned)
    mod.Schedule(1, function ()
      if player.Parent ~= nil then return end
      crown:spawnCrown(player)
  end,{})
  end

end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, crown.PostPlayerInit, 0)


function crown:PostGameStarted(isContinued)
  if isContinued == true then return end

  local save = mod.SaveManager.GetRunSave()
  save.crownsSpawned = 1
  print(save.crownsSpawned)

  local player = Isaac.GetPlayer()
  crown:spawnCrown(player)
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, crown.PostGameStarted)


function crown:spawnCrown(player)
  local playerType = player:GetPlayerType()
  if playerType == PlayerType.PLAYER_ESAU or
    playerType == PlayerType.PLAYER_THESOUL or
    playerType == PlayerType.PLAYER_THESOUL_B or
    playerType == PlayerType.PLAYER_LAZARUS2 or
    playerType == PlayerType.PLAYER_LAZARUS2_B or
    playerType == PlayerType.PLAYER_JACOB2_B
  then return end
  local tempEffects = player:GetEffects()
  if tempEffects:HasNullEffect(NullItemID.ID_ESAU_JR) then return end

  local room = Game():GetRoom()
  local level = Game():GetLevel()
  local x = room:GetBottomRightPos().X
  local y = room:GetTopLeftPos().Y

  if not (level:GetStage() == LevelStage.STAGE1_1 and level:GetStageType() ~= StageType.STAGETYPE_REPENTANCE and level:GetStageType() ~= StageType.STAGETYPE_REPENTANCE_B) 
  then return end
  if (level:GetCurrentRoomIndex() ~= 84) then return end

  local newOffsetFromRight = offsetFromRight - 40*Game():GetNumPlayers()-1
  local finalVector = Vector(x - newOffsetFromRight, y+10)

  Isaac.Spawn(5, 100, CHAMPION_CROWN, finalVector, Vector.Zero, nil)
end


-- mod.Schedule(1, function ()

-- end,{})

function crown:enterRoom()
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
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, crown.enterRoom)


function crown:respawnCrowns()
  local save = mod.SaveManager.GetRunSave()
  if save.crownsSpawned and save.crownsSpawned < 2 then return end

    mod.Schedule(1, function ()
      for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player.Parent == nil and not player:HasCollectible(CHAMPION_CROWN) then
          crown:spawnCrown(player)
        end
      end
    end,{})


end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, crown.respawnCrowns)
