local judas = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_JUDAS
local CHARACTER2 = PlayerType.PLAYER_BLACKJUDAS

function judas:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_DAMAGE then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER and player:GetPlayerType() ~= CHARACTER2 then return end


    if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = player.Damage * 0.6 - 1 end

    local save = IsaacChampions.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtained == true then return end
        save.ItemObtained = true
    end

    if player:GetPlayerType() ~= CHARACTER2 then
      player:ChangePlayerType(CHARACTER2)
    end

    player:AddBlackHearts(1)

    IsaacChampions:setBlindfold(player, true, true)

    local trinkets = {
        TrinketType.TRINKET_DAEMONS_TAIL
    }
    IsaacChampions:addTrinkets(player, trinkets)

    local collectibles = {
      CollectibleType.COLLECTIBLE_MY_SHADOW,
      CollectibleType.COLLECTIBLE_BIRTHRIGHT,
    }
    IsaacChampions:addCollectibles(player, collectibles)

    player:RemoveCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL)
    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_URN_OF_SOULS)

    player:AddWisp(CollectibleType.COLLECTIBLE_VENGEFUL_SPIRIT, player.Position)

end

IsaacChampions:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, judas.onCache)

function judas:PostNewLevelWisp()
  -- give the player a Vengeful Spirit wisp. It despawns at the start of each floor, so you also respawn it at the start of each floor.
  local champions = IsaacChampions:getAllChampChars(CHARACTER2)
  if (next(champions) == nil) then return end
  for i = 1, #champions do
      local player = champions[i]
      player:AddWisp(CollectibleType.COLLECTIBLE_VENGEFUL_SPIRIT, player.Position)
  end
end

IsaacChampions:AddCallback( ModCallbacks.MC_POST_NEW_LEVEL, judas.PostNewLevelWisp )

local SOUL_COLLECT_RANGE = 45

local storedSouls = {}

-- Spawns a soul
-- player EntityPlayer: The player spawning a soul
-- position Vector: The position the soul is initially at
-- countTowardsUrn boolean?: Optional. If set to true it will count towards the Urn of Souls charges.
function judas:spawnSoul(player, position, countTowardsUrn)
  local soul = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ENEMY_SOUL, 0, position, Vector(0, 0), player):ToEffect()
  soul.Target = player

  if not countTowardsUrn then
    table.insert(storedSouls, soul)
  end

  return soul
end


--// We cannot use MC_POST_EFFECT_UPDATE or MC_POST_UPDATE as if the player is moving fast it will cause bugs.
function judas:SoulPostRender()
  for i, v in pairs(storedSouls) do
    local spawner = v.SpawnerEntity

    if spawner and spawner.Position:Distance(v.Position) <= SOUL_COLLECT_RANGE then
      v.SpawnerEntity = nil
      v.Parent = nil
      v.Target = nil
      v:GetSprite():Play("Collect", false)
      SFXManager():Play(SoundEffect.SOUND_SOUL_PICKUP, 1)
    end
  end
end


--// We reset the storedSouls table to prevent memory leaks every time the room is reloaded.
IsaacChampions:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function() 
  storedSouls = {}
end)

IsaacChampions:AddCallback(ModCallbacks.MC_POST_RENDER, judas.SoulPostRender)


function judas:onWormDie(entity)
  if not (entity.Type == 23 and entity.Variant == 0 and entity.SubType == 1) then return end

  local champions = IsaacChampions:getAllChampChars(CHARACTER2)
  if champions == nil or champions == {} then return end
  for i = 1, #champions do
      local player = champions[i]
      judas:spawnSoul(player:ToPlayer(), entity.Position, true)
  end
end

IsaacChampions:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, judas.onWormDie)

if EID then
  local function crownPlayerCondition(descObj)
      if descObj and descObj.ObjType == 5 and descObj.ObjVariant == 100 and descObj.ObjSubType == CHAMPION_CROWN then
        if (descObj.Entity ~= nil) then
          if (Game():GetNearestPlayer(descObj.Entity.Position)):GetPlayerType() == CHARACTER or (Game():GetNearestPlayer(descObj.Entity.Position)):GetPlayerType() == CHARACTER2 then return true end
      else
          if EID.holdTabPlayer and EID.holdTabPlayer:ToPlayer():GetPlayerType() == CHARACTER or EID.holdTabPlayer and EID.holdTabPlayer:ToPlayer():GetPlayerType() == CHARACTER2 then return true end
      end
      end
  end
  local function crownPlayerCallback(descObj)

      descObj.Description =
      "#{{Player".. CHARACTER .."}} {{ColorGray}}Judas" ..
      "#{{Player".. CHARACTER2 .."}} {{ColorMaroon}}Transforms you into Dark Judas" ..
      "#{{Trinket" .. TrinketType.TRINKET_BLIND_RAGE .. "}} {{ColorSilver}}Applies Blindfold" ..
      "#{{Plus}} Adds Collectibles: " ..
      "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_URN_OF_SOULS .. "}} {{ColorSilver}}Pocket Urn of Souls" ..
      "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_BIRTHRIGHT .. "}} {{ColorSilver}}Birthright" ..
      "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_MY_SHADOW .. "}} {{ColorSilver}}My Shadow" ..
      "#{{Collectible" .. CollectibleType.COLLECTIBLE_SMELTER .. "}} Smelts Trinkets:" ..
      "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_DAEMONS_TAIL .. "}} {{ColorSilver}}Daemon's Tail" ..
      "#{{Collectible" .. CollectibleType.COLLECTIBLE_VENGEFUL_SPIRIT .. "}} Grants permanent Vengeful Spirit Wisp"
      return descObj
  end
  EID:addDescriptionModifier("CrownJudas", crownPlayerCondition, crownPlayerCallback)
end