local RSGCore = exports['rsg-core']:GetCoreObject()

RSGCore.Functions.CreateUseableItem("surprise_box", function(source)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return end
    
    -- Remove the item when used
    Player.Functions.RemoveItem('surprise_box', 1)
    
    -- Select random surprise
    local surpriseIndex = math.random(1, #Config.Surprises)
    
    -- Trigger client event to spawn the surprise
    TriggerClientEvent('rsg-surprisebox:spawnSurprise', source, surpriseIndex)
end)