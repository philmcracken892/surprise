local RSGCore = exports['rsg-core']:GetCoreObject()
local playerCooldowns = {}
local COOLDOWN_TIME = 30 * 60 * 1000 -- 30 minutes in milliseconds


local function NotifyPlayer(playerId, message, type)
    TriggerClientEvent('RSGCore:Notify', playerId, message, type)  
end

local function isOnCooldown(playerId)
    local lastUse = playerCooldowns[playerId]
    if not lastUse then return false end
    
    local currentTime = GetGameTimer()
    local timeSinceLastUse = currentTime - lastUse
    
    return timeSinceLastUse < COOLDOWN_TIME
end

local function getRemainingCooldown(playerId)
    local lastUse = playerCooldowns[playerId]
    if not lastUse then return 0, 0 end
    
    local currentTime = GetGameTimer()
    local remaining = COOLDOWN_TIME - (currentTime - lastUse)
    
    if remaining <= 0 then return 0, 0 end
    
    local minutes = math.floor(remaining / 60000)
    local seconds = math.floor((remaining % 60000) / 1000)
    
    return minutes, seconds
end

RegisterServerEvent('rsg-surprisebox:syncToPlayers')
AddEventHandler('rsg-surprisebox:syncToPlayers', function(boxCoords, animalCoords, surpriseData, boxNetId, sourcePlayerId)
    local src = source
    
    TriggerClientEvent('rsg-surprisebox:syncEffects', -1, boxCoords, animalCoords, surpriseData, boxNetId)
    
    SetTimeout(2000, function()
        TriggerClientEvent('rsg-surprisebox:syncAnimal', -1, animalCoords, surpriseData.model, GetEntityHeading(GetPlayerPed(src)), surpriseData.isAggressive, sourcePlayerId)
    end)
end)

RSGCore.Functions.CreateUseableItem("surprise_box", function(source)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return end
    
    
    if isOnCooldown(source) then
        local minutes, seconds = getRemainingCooldown(source)
        
        TriggerClientEvent('rNotify:NotifyLeft', source, "Surprise Box on Cooldown", minutes .. "m " .. seconds .. "s remaining", "generic_textures", "tick", 4000)
        return
    end
    
   
    playerCooldowns[source] = GetGameTimer()
    
    
    Player.Functions.RemoveItem('surprise_box', 1)
    TriggerClientEvent('inventory:client:ItemBox', source, RSGCore.Shared.Items['surprise_box'], "remove")
    
    
    local surpriseIndex = math.random(1, #Config.Surprises)
    
    
    TriggerClientEvent('rsg-surprisebox:spawnSurprise', source, surpriseIndex)
end)

RegisterServerEvent('rsg-surprisebox:giveReward')
AddEventHandler('rsg-surprisebox:giveReward', function(animalName)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local animalData = nil
    for _, surprise in pairs(Config.Surprises) do
        if surprise.name == animalName then
            animalData = surprise
            break
        end
    end
    
    if animalData and animalData.rewards then
        local reward = animalData.rewards[math.random(#animalData.rewards)]
        Player.Functions.AddItem(reward.item, reward.amount)
        NotifyPlayer(src, 'You received ' .. reward.amount .. 'x ' .. reward.item, 'success')
    end
end)

RegisterServerEvent('rsg-surprisebox:lootAnimal')
AddEventHandler('rsg-surprisebox:lootAnimal', function(animalName)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local rarity = "common"
    local rand = math.random(100)
    local cumulative = 0
    for rarityType, chance in pairs(Config.RarityChances) do
        cumulative = cumulative + chance
        if rand <= cumulative then
            rarity = rarityType
            break
        end
    end
    
    local loot = {
        common = {
            {item = "raw_meat", amount = 1},
            {item = "pelt_poor", amount = 1}
        },
        uncommon = {
            {item = "raw_meat", amount = 2},
            {item = "pelt_good", amount = 1}
        },
        rare = {
            {item = "raw_meat", amount = 3},
            {item = "pelt_perfect", amount = 1}
        },
        legendary = {
            {item = "legendary_pelt", amount = 1},
            {item = "raw_meat", amount = 2}
        }
    }
    
    local selectedLoot = loot[rarity]
    for _, item in pairs(selectedLoot) do
        Player.Functions.AddItem(item.item, item.amount)
    end
    
    NotifyPlayer(src, 'You found ' .. rarity .. ' quality loot!', 'success')
end)

RSGCore.Commands.Add('cooldown', 'Check surprise box cooldown', {}, false, function(source)
    if isOnCooldown(source) then
        local minutes, seconds = getRemainingCooldown(source)
        NotifyPlayer(source, 'Surprise Box Cooldown: ' .. minutes .. ' minutes ' .. seconds .. ' seconds remaining', 'primary')
    else
        NotifyPlayer(source, 'You can use a surprise box now!', 'success')
    end
end)

AddEventHandler('playerDropped', function(reason)
    local source = source
    playerCooldowns[source] = nil
end)
