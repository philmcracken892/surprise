local RSGCore = exports['rsg-core']:GetCoreObject()
local placedBox = nil
local lastSpawnTime = 0
local spawnCooldown = 1000
local spawnedAnimals = {}


RegisterNetEvent('RSGCore:Notify')
AddEventHandler('RSGCore:Notify', function(msg, type, duration)
    RSGCore.Functions.Notify(msg, type, duration)
end)



local function CreateSmokeEffect(coords, scale)
    if not coords then return end
    
    -- Use the known working effect details with larger scale
    local fx_group = "scr_dm_ftb"
    local fx_name = "scr_mp_chest_spawn_smoke"
    local fx_scale = 1.0 * (scale or 1.0)  -- Increased from 0.3 to 1.0 for larger smoke
    
    -- Request and load the particle effect
    RequestNamedPtfxAsset(fx_group)
    while not HasNamedPtfxAssetLoaded(fx_group) do
        Wait(10)
    end
    
    -- Use the particle effect asset and start the non-looped effect
    UseParticleFxAsset(fx_group)
    local smoke = StartParticleFxNonLoopedAtCoord(
        fx_name,
        coords.x,
        coords.y,
        coords.z,  -- Removed +0.5 to ensure smoke is at ground level
        0.0, 0.0, 0.0,
        fx_scale,
        false, false, false, true
    )
    
    return smoke
end

local function SpawnSurpriseBox(coords)
    local modelHash = GetHashKey(Config.BoxProp.model)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end
    
    local box = CreateObject(modelHash, coords.x, coords.y, coords.z - 1.0, true, false, false)
    SetEntityAsMissionEntity(box, true, true)
    
    local netId = ObjToNet(box)
    
    if netId then
        SetNetworkIdExistsOnAllMachines(netId, true)
    end
    
    PlaceObjectOnGroundProperly(box)
    FreezeEntityPosition(box, true)
    
    SetModelAsNoLongerNeeded(modelHash)
    
    return box, netId
end


RegisterNetEvent('rsg-surprisebox:syncAnimal')
AddEventHandler('rsg-surprisebox:syncAnimal', function(animalCoords, modelName, heading, isAggressive, targetServerId)
    -- Check if enough time has passed since last spawn
    local currentTime = GetGameTimer()
    if currentTime - lastSpawnTime < spawnCooldown then
        return
    end
    lastSpawnTime = currentTime

    if not animalCoords or not animalCoords.x or not animalCoords.y or not animalCoords.z then
        return
    end
    
    local ped = PlayerPedId()
    if not ped then return end
    
    local playerCoords = GetEntityCoords(ped)
    if not playerCoords then return end
    
    local distance = #(playerCoords - vector3(animalCoords.x, animalCoords.y, animalCoords.z))
    if not distance or distance > (Config.BoxProp.syncDistance or 50.0) then
        return
    end
    
    
    CreateSmokeEffect(animalCoords, 1.0)
    
    
    Wait(100)
    
    local modelHash = GetHashKey(modelName)
    if not modelHash then return end
    
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end
    
    
    CreateSmokeEffect(animalCoords, 1.0)
    
    local animal = CreatePed(modelHash, animalCoords.x, animalCoords.y, animalCoords.z, heading or 0.0, true, false, false, false)
    
    if not DoesEntityExist(animal) then return end
    
    
    table.insert(spawnedAnimals, animal)
    
    Citizen.InvokeNative(0x283978A15512B2FE, animal, true)
    
    local netId = PedToNet(animal)
    
    if netId then
        SetNetworkIdExistsOnAllMachines(netId, true)
    end
    
    if isAggressive then
        local targetPlayer = GetPlayerFromServerId(targetServerId)
        if targetPlayer then
            local targetPed = GetPlayerPed(targetPlayer)
            if DoesEntityExist(targetPed) then
                TaskCombatPed(animal, targetPed, 0, 16)
                SetPedFleeAttributes(animal, 0, false)
                Citizen.InvokeNative(0xFD6943B6DF77E449, animal, false)
            end
        end
    else
        TaskWanderStandard(animal, 10.0, 10)
    end
    
    
    Wait(100)
    CreateSmokeEffect(animalCoords, 0.8)
    
    SetModelAsNoLongerNeeded(modelHash)
end)

local function DeleteAllAnimals()
    for i, animal in ipairs(spawnedAnimals) do
        if DoesEntityExist(animal) then
            DeleteEntity(animal)
        end
    end
    spawnedAnimals = {} 
end





RegisterNetEvent('rsg-surprisebox:spawnSurprise')
AddEventHandler('rsg-surprisebox:spawnSurprise', function(surpriseIndex)
    local surprise = Config.Surprises[surpriseIndex]
    if not surprise then return end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    local boxCoords = {
        x = coords.x + Config.BoxProp.placementDistance * math.sin(-math.rad(heading)),
        y = coords.y + Config.BoxProp.placementDistance * math.cos(-math.rad(heading)),
        z = coords.z
    }
    
    local animalCoords = {
        x = coords.x + surprise.spawnDistance * math.sin(-math.rad(heading)),
        y = coords.y + surprise.spawnDistance * math.cos(-math.rad(heading)),
        z = coords.z
    }
    
    local box, boxNetId = SpawnSurpriseBox(boxCoords)
    placedBox = box
    
    TriggerServerEvent('rsg-surprisebox:syncToPlayers', boxCoords, animalCoords, surprise, boxNetId, GetPlayerServerId(PlayerId()))
    
    local anim = `WORLD_HUMAN_CROUCH_INSPECT`
    TaskStartScenarioInPlace(ped, anim, 0, true)
    
    if lib.progressBar({
        duration = 2000,
        label = 'Opening Surprise Box...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            sprint = true
        }
    }) then
        TriggerEvent('rNotify:NotifyLeft', surprise.notifyTitle, surprise.notifyMessage, "generic_textures", "tick", 4000)
        
        SetTimeout(Config.BoxProp.deleteDelay, function()
            if placedBox and DoesEntityExist(placedBox) then
                DeleteEntity(placedBox)
                placedBox = nil
            end
        end)
    else
        if placedBox and DoesEntityExist(placedBox) then
            DeleteEntity(placedBox)
            placedBox = nil
        end
    end
    
    ClearPedTasks(ped)
end)


AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    if placedBox and DoesEntityExist(placedBox) then
        DeleteEntity(placedBox)
		DeleteAllAnimals()
        placedBox = nil
    end
    RemoveNamedPtfxAsset("core")
end)

AddEventHandler('playerSpawned', function()
    if placedBox and DoesEntityExist(placedBox) then
        DeleteEntity(placedBox)
		DeleteAllAnimals()
        placedBox = nil
    end
end)
