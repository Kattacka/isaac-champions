local judas = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")


function judas:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_DAMAGE then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= PlayerType.PLAYER_JUDAS and player:GetPlayerType() ~= PlayerType.PLAYER_BLACKJUDAS then return end


    if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = player.Damage * 0.6 - 1 end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    if player:GetPlayerType() ~= PlayerType.PLAYER_BLACKJUDAS then
      player:ChangePlayerType(PlayerType.PLAYER_BLACKJUDAS)
    end

    player:AddBlackHearts(1)

    local challenge = Isaac.GetChallenge()
    Game().Challenge = Challenge.CHALLENGE_SOLAR_SYSTEM
    player:UpdateCanShoot()
    Game().Challenge = challenge



    local trinkets = {
        TrinketType.TRINKET_DAEMONS_TAIL
    }

    for i = 1, #trinkets do
        if not player:HasTrinket(trinkets[i]) then
            player:AddTrinket(trinkets[i])
            player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false)
        end
    end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL) then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_URN_OF_SOULS) then
        player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_URN_OF_SOULS)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_MY_SHADOW) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_MY_SHADOW)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
    end
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, judas.onCache)


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
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function() 
  storedSouls = {}
end)

mod:AddCallback(ModCallbacks.MC_POST_RENDER, judas.SoulPostRender)


function judas:onWormDie(entity)
    local finalPlayer = nil
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:GetPlayerType() == PlayerType.PLAYER_BLACKJUDAS then
            finalPlayer = player
        end
      end

    if finalPlayer == nil then return end
    if finalPlayer:GetPlayerType() ~= PlayerType.PLAYER_BLACKJUDAS then return end
    if not finalPlayer:HasCollectible(CHAMPION_CROWN) then return end
    if entity.Type == 23 and entity.Variant == 0 and entity.SubType == 1 then
        judas:spawnSoul(finalPlayer:ToPlayer(), entity.Position, true)
    end

end

mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, judas.onWormDie)