local QBCore = exports['qb-core']:GetCoreObject()
local firstAlarm = false
local smashing = false
local npcCopsSpawned = false
local guardsHash = 1972614767
local policeHash = 2046537925
local othersHash = 1403091332

-- Functions

local function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local function loadParticle()
	if not HasNamedPtfxAssetLoaded("scr_jewelheist") then
		RequestNamedPtfxAsset("scr_jewelheist")
    end
    while not HasNamedPtfxAssetLoaded("scr_jewelheist") do
		Wait(0)
    end
    SetPtfxAssetNextCall("scr_jewelheist")
end

local function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(3)
    end
end

local function validWeapon()
    local ped = PlayerPedId()
    local pedWeapon = GetSelectedPedWeapon(ped)

    for k, _ in pairs(Config.WhitelistedWeapons) do
        if pedWeapon == k then
            return true
        end
    end
    return false
end

local function IsWearingHandshoes()
    local armIndex = GetPedDrawableVariation(PlayerPedId(), 3)
    local model = GetEntityModel(PlayerPedId())
    local retval = true
    if model == `mp_m_freemode_01` then
        if Config.MaleNoHandshoes[armIndex] ~= nil and Config.MaleNoHandshoes[armIndex] then
            retval = false
        end
    else
        if Config.FemaleNoHandshoes[armIndex] ~= nil and Config.FemaleNoHandshoes[armIndex] then
            retval = false
        end
    end
    return retval
end

local function smashVitrine(k)
    if not firstAlarm then
        TriggerServerEvent('police:server:policeAlert', 'Suspicious Activity')
        firstAlarm = true
    end

    QBCore.Functions.TriggerCallback('qb-jewellery:server:getCops', function(cops)
        if cops >= Config.RequiredCops then
            local animDict = "missheist_jewel"
            local animName = "smash_case"
            local ped = PlayerPedId()
            local plyCoords = GetOffsetFromEntityInWorldCoords(ped, 0, 0.6, 0)
            local pedWeapon = GetSelectedPedWeapon(ped)
            if math.random(1, 100) <= 80 and not IsWearingHandshoes() then
                TriggerServerEvent("evidence:server:CreateFingerDrop", plyCoords)
            elseif math.random(1, 100) <= 5 and IsWearingHandshoes() then
                TriggerServerEvent("evidence:server:CreateFingerDrop", plyCoords)
                QBCore.Functions.Notify(Lang:t('error.fingerprints'), "error")
            end
            smashing = true
            QBCore.Functions.Progressbar("smash_vitrine", Lang:t('info.progressbar'), Config.WhitelistedWeapons[pedWeapon]["timeOut"], false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- Done
                TriggerServerEvent('qb-jewellery:server:vitrineReward', k)
                TriggerServerEvent('qb-jewellery:server:setTimeout')
                TriggerServerEvent('police:server:policeAlert', 'Robbery in progress')
                smashing = false
                TaskPlayAnim(ped, animDict, "exit", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
            end, function() -- Cancel
                TriggerServerEvent('qb-jewellery:server:setVitrineState', "isBusy", false, k)
                smashing = false
                TaskPlayAnim(ped, animDict, "exit", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
            end)
            TriggerServerEvent('qb-jewellery:server:setVitrineState', "isBusy", true, k)

            CreateThread(function()
                while smashing do
                    loadAnimDict(animDict)
                    TaskPlayAnim(ped, animDict, animName, 3.0, 3.0, -1, 2, 0, 0, 0, 0 )
                    Wait(500)
                    TriggerServerEvent("InteractSound_SV:PlayOnSource", "breaking_vitrine_glass", 0.25)
                    loadParticle()
                    StartParticleFxLoopedAtCoord("scr_jewel_cab_smash", plyCoords.x, plyCoords.y, plyCoords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
                    Wait(2500)
                end
            end)
        else
            if not npcCopsSpawned then
                TriggerEvent('qb-jewel:spawnNPCs')
                npcCopsSpawned = true
            end
            local animDict = "missheist_jewel"
            local animName = "smash_case"
            local ped = PlayerPedId()
            local plyCoords = GetOffsetFromEntityInWorldCoords(ped, 0, 0.6, 0)
            local pedWeapon = GetSelectedPedWeapon(ped)
            if math.random(1, 100) <= 80 and not IsWearingHandshoes() then
                TriggerServerEvent("evidence:server:CreateFingerDrop", plyCoords)
            elseif math.random(1, 100) <= 5 and IsWearingHandshoes() then
                TriggerServerEvent("evidence:server:CreateFingerDrop", plyCoords)
                QBCore.Functions.Notify(Lang:t('error.fingerprints'), "error")
            end
            smashing = true
            QBCore.Functions.Progressbar("smash_vitrine", Lang:t('info.progressbar'), Config.WhitelistedWeapons[pedWeapon]["timeOut"], false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- Done
                TriggerServerEvent('qb-jewellery:server:vitrineReward', k)
                TriggerServerEvent('qb-jewellery:server:setTimeout')
                TriggerServerEvent('police:server:policeAlert', 'Robbery in progress')
                smashing = false
                TaskPlayAnim(ped, animDict, "exit", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
            end, function() -- Cancel
                TriggerServerEvent('qb-jewellery:server:setVitrineState', "isBusy", false, k)
                smashing = false
                TaskPlayAnim(ped, animDict, "exit", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
            end)
            TriggerServerEvent('qb-jewellery:server:setVitrineState', "isBusy", true, k)

            CreateThread(function()
                while smashing do
                    loadAnimDict(animDict)
                    TaskPlayAnim(ped, animDict, animName, 3.0, 3.0, -1, 2, 0, 0, 0, 0 )
                    Wait(500)
                    TriggerServerEvent("InteractSound_SV:PlayOnSource", "breaking_vitrine_glass", 0.25)
                    loadParticle()
                    StartParticleFxLoopedAtCoord("scr_jewel_cab_smash", plyCoords.x, plyCoords.y, plyCoords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
                    Wait(2500)
                end
            end)
            -- QBCore.Functions.Notify(Lang:t('error.minimum_police', {value = Config.RequiredCops}), 'error')
        end
    end)
end

-- Events

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	QBCore.Functions.TriggerCallback('qb-jewellery:server:getVitrineState', function(result)
		Config.Locations = result
	end)
end)

RegisterNetEvent('qb-jewellery:client:setVitrineState', function(stateType, state, k)
    Config.Locations[k][stateType] = state
    if stateType == "isOpened" then
        local loc = Config.Locations[k]['coords']
        local item = Config.Locations[k]
        if state == true then

            CreateModelSwap(loc.x, loc.y, loc.z, 0.1, GetHashKey(item['before']), GetHashKey(item['after']), false)    
        else
            RemoveModelSwap(loc.x, loc.y, loc.z, 0.1, GetHashKey(item['before']), GetHashKey(item['after']), false)
        end
    end
end)

RegisterNetEvent('qb-jewellery:client:enteredArea', function()
    for k,v in pairs(Config.Locations) do
        if v.isOpened == true then
            local loc = Config.Locations[k]['coords']
            local item = Config.Locations[k]
            CreateModelSwap(loc.x, loc.y, loc.z, 0.1, GetHashKey(item['before']), GetHashKey(item['after']), false)
        end
    end
end)

RegisterNetEvent('qb-jewellery:client:leftArea', function()
    for k,v in pairs(Config.Locations) do
        if v.isOpened == true then
            local loc = Config.Locations[k]['coords']
            local item = Config.Locations[k]
            RemoveModelSwap(loc.x, loc.y, loc.z, 0.1, GetHashKey(item['before']), GetHashKey(item['after']), false)
        end
    end
end)

-- Threads
local inArea = false
local HasTriggered = false
Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local loc = GetEntityCoords(ped)
        local store = vector3(-625.18, -232.19, 38.06)

        if #(loc - store) < 30.0 then
            inArea = true
        else
            inArea = false
        end

        if inArea and not HasTriggered then
            HasTriggered = true
            TriggerEvent('qb-jewellery:client:enteredArea')
        end

        if not inArea and HasTriggered then
            HasTriggered = false
            TriggerEvent('qb-jewellery:client:leftArea')
        end
        Wait(5000)
    end
end)

CreateThread(function()
    local Dealer = AddBlipForCoord(Config.JewelleryLocation["coords"]["x"], Config.JewelleryLocation["coords"]["y"], Config.JewelleryLocation["coords"]["z"])
    SetBlipSprite (Dealer, 617)
    SetBlipDisplay(Dealer, 4)
    SetBlipScale  (Dealer, 0.7)
    SetBlipAsShortRange(Dealer, true)
    SetBlipColour(Dealer, 3)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Vangelico Jewelry")
    EndTextCommandSetBlipName(Dealer)

    AddRelationshipGroup("guards")
    AddRelationshipGroup("police")
    AddRelationshipGroup("others")
    SetRelationshipBetweenGroups(5, guardsHash, othersHash)
    SetRelationshipBetweenGroups(0, guardsHash, policeHash)
end)

local jewelCenter = vector3(-624.26, -232.07, 38.06)
Citizen.CreateThread(function()
    while true do
        local pos = GetEntityCoords(PlayerPedId())
        local sleep = 5000
        if #(jewelCenter- pos) < 20.0 then
            sleep = 1
        end
        for k,v in pairs(Config.Locations) do
            if #(pos - v.coords) < 1.0 then
                DrawText3Ds(v.coords.x, v.coords.y, v.coords.z, '[E] Smash the display case')
                if IsControlJustPressed(0, 38) then
                    if not Config.Locations[k]["isBusy"] and not Config.Locations[k]["isOpened"] then
                        if validWeapon() then
                            smashVitrine(k)
                        else
                            QBCore.Functions.Notify(Lang:t('error.wrong_weapon'), 'error')
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)


local npc = { 
	{a = nil, x= -611.8546, y= -280.2901, z= 38.7895, h = 38.7582, m = 0x2EFEAFD5, r = 1, w = "weapon_pistol"},
	{a = nil, x= -613.0334, y= -284.0859, z= 38.0113, h = 255.80, m = 0x2EFEAFD5, r = 1, w = "weapon_pistol"},
	{a = nil, x= -672.6677, y= -231.9794, z= 36.9187, h = 263.8721, m = 0x2EFEAFD5, r = 1, w = "weapon_pumpshotgun"},
    {a = nil, x= -672.6677, y= -231.9794, z= 36.9187, h = 263.8721, m = 0x2EFEAFD5, r = 1, w = "weapon_carbinerifle"}
	-- {a = nil, x= -665.7512, y= -217.7860, z= 37.1198, h = 232.7494, m = 0x2EFEAFD5, r = 1, w = "weapon_pistol"},
}

RegisterNetEvent('qb-jewel:spawnNPCs')
AddEventHandler('qb-jewel:spawnNPCs', function()
	Wait(90000)
	local pos = GetEntityCoords(PlayerPedId())
	local store = vector3(-623.2161, -231.6691, 38.0567)
	if GetDistanceBetweenCoords(pos, store) < 15 then
		NPCSpawn()
	end
	Wait(30000)
	npcCopsSpawned = false
end)

function NPCSpawn(...)
    RequestModel(0x2EFEAFD5)
    while not HasModelLoaded(0x2EFEAFD5) do
        Citizen.Wait(5)
    end
    for i = 1, #npc, 1 do
        npc[i].a = CreatePed(26, npc[i].m, npc[i].x, npc[i].y, npc[i].z, npc[i].h, 1, 1)
        SetPedRelationshipGroupHash(npc[i].a, 1972614767)
        SetPedCombatAttributes(npc[i].a, 1, true)
        SetPedCombatAttributes(npc[i].a, 2, true)
        SetPedCombatAttributes(npc[i].a, 5, true)
        SetPedCombatAttributes(npc[i].a, 16, true)
        SetPedCombatAttributes(npc[i].a, 26, true)
        SetPedCombatAttributes(npc[i].a, 46, true)
        SetPedCombatAttributes(npc[i].a, 52, true)
        SetPedFleeAttributes(npc[i].a, 0, 0)
        SetPedDiesWhenInjured(npc[i].a, false)
        TaskStandGuard(npc[i].a, npc[i].x, npc[i].y, npc[i].z, npc[i].h, "Standing")
        SetPedArmour(npc[i].a, 2500)
        SetPedAlertness(npc[i].a, 3)
        SetPedAccuracy(npc[i].a, 70)
        SetPedToInformRespectedFriends(npc[i].a, 200, 100)
        GiveWeaponToPed(npc[i].a, npc[i].w, 900, false, true)
        SetPedCombatRange(npc[i].a, npc[i].r)
        SetPedHighlyPerceptive(npc[i].a, true)
        SetPedDropsWeaponsWhenDead(npc[i].a, false)
		TaskPutPedDirectlyIntoMelee(npc[i].a, PlayerPedId(), 0.0, -1.0, 0.0, 0)
		-- TaskArrestPed(npc[i].a, PlayerPedId())
        Citizen.CreateThread(function()
            local sleep = 1000
            local spawnpos = vector3(npc[i].x, npc[i].y, npc[i].z)
            while (not IsPedDeadOrDying(npc[i].a) or GetEntityHealth(npc[i].a) > 5) and #(GetEntityCoords(npc[i].a) - spawnpos) < 45 do
                Wait(sleep)
                -- print(#(GetEntityCoords(npc[i].a) - spawnpos))
            end
            -- print("ENTITY TOO FAR, DELETE IT")
            DeleteEntity(npc[i].a)
            npc[i].a = nil
        end)
    end
    SetModelAsNoLongerNeeded(0x2EFEAFD5)
    TriggerServerEvent("jewel:handlePlayers")
    
end

function HandlePlayers()
    if PlayerData.job.name == "police" or PlayerData.job.name == 'ambulance' or PlayerData.job.name == 'security' then
        SetPedRelationshipGroupHash(PlayerPedId(), 2046537925)
    else
        local pos = GetEntityCoords(PlayerPedId())
        local store = vector3(-623.2161, -231.6691, 38.0567)
        local dist = #(pos - store)
        if dist < 15 then
            SetPedRelationshipGroupHash(PlayerPedId(), 1403091332)
        end
    end
end

RegisterNetEvent("jewel:handlePlayers_c")
AddEventHandler("jewel:handlePlayers_c", function()
    HandlePlayers()
end)
