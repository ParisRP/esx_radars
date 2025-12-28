--===============================================
--= Stationary radars pour ESX Legacy avec ox_lib
--===============================================

local ESX = nil
local PlayerData = {}

-- Initialisation ESX
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(100)
    end

    PlayerData = ESX.GetPlayerData()
end)

-- Récupération des données joueur
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

-- Positions des radars
local radars = {
    {x = 379.68807983398, y = -1048.3527832031, z = 29.250692367554},
    {x = -253.10794067383, y = -630.20385742188, z = 33.002685546875},
}

-- Cooldown pour éviter les flashs multiples
local cooldown = false

-- Vérification des radars
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Vérifier toutes les secondes

        if PlayerData.job then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)

            for k, v in pairs(radars) do
                local distance = #(coords - vector3(v.x, v.y, v.z))

                if distance < 20.0 and not cooldown then
                    -- Vérifier si c'est un métier exclu
                    local jobName = PlayerData.job.name

                    if jobName ~= 'police' and jobName ~= 'ambulance' then
                        checkSpeed()
                        cooldown = true

                        -- Cooldown de 5 secondes
                        Citizen.SetTimeout(5000, function()
                            cooldown = false
                        end)
                    end
                end
            end
        end
    end
end)

function checkSpeed()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    -- Vérifier si le joueur est dans un véhicule
    if vehicle == 0 then
        return
    end

    -- Vérifier si le joueur est le conducteur
    local driver = GetPedInVehicleSeat(vehicle, -1)
    if driver ~= ped then
        return
    end

    -- Calculer la vitesse
    local speed = GetEntitySpeed(vehicle)
    local mphSpeed = math.ceil(speed * 2.236936) -- Convertir en MPH
    local maxSpeed = 45 -- Limite de vitesse
    local plate = GetVehicleNumberPlateText(vehicle)

    -- Vérifier si le joueur dépasse la limite
    if mphSpeed > maxSpeed then
        local fineAmount = 0
        local fineLevel = ""

        -- Déterminer l'amende selon la vitesse
        if mphSpeed >= 50 and mphSpeed <= 60 then
            fineAmount = Config.Fine
            fineLevel = '10mph Over Limit'
        elseif mphSpeed >= 61 and mphSpeed <= 70 then
            fineAmount = Config.Fine2
            fineLevel = '20mph Over Limit'
        elseif mphSpeed >= 71 and mphSpeed <= 80 then
            fineAmount = Config.Fine3
            fineLevel = '30mph Over Limit'
        elseif mphSpeed >= 81 then
            fineAmount = Config.Fine4
            fineLevel = '40mph Over Limit'
        else
            return -- Vitesse hors plage
        end

        -- Envoyer l'événement au serveur
        TriggerServerEvent('esx_radars:finePlayer', mphSpeed, fineAmount, plate)

        -- Notification au joueur
        --ESX.ShowNotification("~r~Flash!~s~\nVous avez été flashé à " .. mphSpeed .. " mph!\nAmende: $" .. fineAmount)
        -- Si ox_lib est installé
        if lib then
            lib.notify({
                title = '📸 Radar',
                description = 'Vous avez été flashé à ' .. mphSpeed .. ' mph!\nAmende: $' .. fineAmount,
                type = 'error',
                duration = 5000,
                position = 'top-left'
            })
        end
    end

end
