ESX = nil

-- Initialisation ESX
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(100)
    end
end)

-- Événement pour appliquer l'amende
RegisterNetEvent('esx_radars:finePlayer')
AddEventHandler('esx_radars:finePlayer', function(speed, fineAmount, plate)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return
    end

    -- Vérifier si le joueur a un métier
    if not xPlayer.job then
        return
    end

    -- Vérifier si c'est un métier exclu
    local jobName = xPlayer.job.name

    if jobName == 'police' or jobName == 'ambulance' then
        return
    end

    print('^2[INFO]^0 Flash radar pour ' .. xPlayer.getName() ..
          ' | Vitesse: ' .. speed .. ' mph | Amende: $' .. fineAmount ..
          ' | Plaque: ' .. plate)

    -- Tentative 1: Retirer de la banque
    local bankMoney = xPlayer.getAccount('bank').money

    if bankMoney >= fineAmount then
        xPlayer.removeAccountMoney('bank', fineAmount)

        -- Notification au joueur
        TriggerClientEvent('esx:showNotification', src, '~r~Amende~s~\n$' .. fineAmount .. ' retirés de votre compte bancaire')
        return
    end

    -- Tentative 2: Retirer de l'argent liquide
    local cashMoney = xPlayer.getMoney()

    if cashMoney >= fineAmount then
        xPlayer.removeMoney(fineAmount)

        -- Notification au joueur
        TriggerClientEvent('esx:showNotification', src, '~r~Amende~s~\n$' .. fineAmount .. ' retirés de votre argent liquide')
        return
    end

    -- Pas assez d'argent
    TriggerClientEvent('esx:showNotification', src, '~r~Amende impayée~s~\nVous n\'avez pas assez d\'argent pour payer l\'amende de $' .. fineAmount)
end)
