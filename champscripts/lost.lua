local lost = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_THELOST

function lost:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_LUCK then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    player:RemoveCollectible(CollectibleType.COLLECTIBLE_ETERNAL_D6)
    
    player:AddCollectible(CollectibleType.COLLECTIBLE_RUNE_BAG)
    player:AddCollectible(CollectibleType.COLLECTIBLE_HEARTBREAK)
    player:AddCollectible(CollectibleType.COLLECTIBLE_CLEAR_RUNE, 4, false)
    player:AddCard(Card.RUNE_ALGIZ)
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, lost.onCache)


function lost:onPerfectUpdate(player)
    if player == nil then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end
    if player:HasTrinket(TrinketType.TRINKET_WOODEN_CROSS) then
        if Game():GetRoom():GetFrameCount() ~= 1 then return end
    else
        if Game():GetRoom():GetFrameCount() ~= 0 then return end
    end
    local tempEffects = player:GetEffects()
    if tempEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE) then
        tempEffects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, 1)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, lost.onPerfectUpdate)

---lost.lua
lost.HourglassIcon = Sprite()
lost.HourglassIcon:Load("resources-dlc3/gfx/ui/ui_hearts.anm2", true)
lost.HourglassIcon:SetFrame("BrokenHeart", 1)
-- lost.HourglassIcon:LoadGraphics()

lost.HourglassText = Font()
lost.HourglassText:Load("font/pftempestasevencondensed.fnt")

---main.lua
---RENDER--
function mod:PostRender()
    local player = Isaac.GetPlayer(0)
    if player == nil then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end
    local level = Game():GetLevel()

    if level:GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN > 0 then return end

    local data = player:GetData()

        local pos = Vector(47, 13) + Options.HUDOffset*Vector(24, 12)
        lost.HourglassIcon:Render(pos)
        lost.HourglassText:DrawString("x" .. player:GetBrokenHearts(), 55 + Options.HUDOffset * 24 , 5 + Options.HUDOffset *10, KColor(1 ,1 ,1 ,1), 0, true)
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.PostRender)