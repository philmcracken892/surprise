local RSGCore = exports['rsg-core']:GetCoreObject()

RegisterNetEvent('rsg-surprisebox:spawnSurprise')
AddEventHandler('rsg-surprisebox:spawnSurprise', function(surpriseIndex)
    local surprise = Config.Surprises[surpriseIndex]
    if not surprise then return end
    
    -- Get player's position and heading
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    -- Calculate position in front of player
    local forward = surprise.spawnDistance
    local forwardCoords = {
        x = coords.x + forward * math.sin(-math.rad(heading)),
        y = coords.y + forward * math.cos(-math.rad(heading)),
        z = coords.z
    }
    
    
    local modelHash = GetHashKey(surprise.model)
    
    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(10)
        end
    end
    
    
    local animal = CreatePed(modelHash, forwardCoords.x, forwardCoords.y, forwardCoords.z, heading, true, false, false, false)
    Citizen.InvokeNative(0x283978A15512B2FE, animal, true) -- Set random outfit variation
    
    
    if surprise.isAggressive then
        TaskCombatPed(animal, ped, 0, 16)
        SetPedFleeAttributes(animal, 0, false) -- Prevent fleeing
        Citizen.InvokeNative(0xFD6943B6DF77E449, animal, false) -- Disable animal fleeing (RedM specific)
    else
        TaskWanderStandard(animal, 10.0, 10)
    end
    
    -- Add RedM smoke effect
    local smoking = true
    Citizen.CreateThread(function()
        while smoking do
            Citizen.Wait(50)
            Citizen.InvokeNative(0x669655FFB29EF1A9, animal, 0, "Smoke_Effect", 1.0)
        end
    end)
    
    -- Stop smoke effect after 2 seconds
    Citizen.SetTimeout(7000, function()
        smoking = false
    end)
    
    -- Show notification
    TriggerEvent('rNotify:NotifyLeft', surprise.notifyTitle, surprise.notifyMessage, "generic_textures", "tick", 4000)
end)