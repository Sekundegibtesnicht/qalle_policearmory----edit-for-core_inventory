ESX = exports["es_extended"]:getSharedObject()
local CachedPedState = false

-- Automatische Registrierung aller Munitionstypen
Citizen.CreateThread(function()
    for ammoType, data in pairs(Config.AmmoTypes) do
        ESX.RegisterUsableItem(ammoType, function(source)
            local xPlayer = ESX.GetPlayerFromId(source)
            
            if xPlayer.getInventoryItem(ammoType).count > 0 then
                TriggerClientEvent('ammo:clientUseAmmoItem', source, ammoType)
            else
                TriggerClientEvent('esx:showNotification', source, 'Du hast keine Munition mehr!')
            end
        end)
        
        if Config.Debug then
            print(('[AMMO] Successfully registered usable item: %s'):format(ammoType))
        end
    end
end)

-- Callbacks und Events
ESX.RegisterServerCallback("qalle_policearmory:pedExists", function(source, cb)
    cb(CachedPedState)
    CachedPedState = true
end)

-- Munitions-Handler
RegisterServerEvent("qalle_policearmory:giveammo")
AddEventHandler("qalle_policearmory:giveammo", function(ammotype)
    local playerId = source
    local player = ESX.GetPlayerFromId(playerId)
    
    if not player then 
        if Config.Debug then
            print(('[ARMORY] Player not found: %s'):format(playerId))
        end
        return 
    end

    if Config.OnlyPolicemen and player.job.name ~= 'police' then
        TriggerClientEvent("esx:showNotification", playerId, Config.Locales[Config.Language].notauthorized)
        return
    end

    -- Ammo-Typ Validierung
    local ammoExists = false
    for _, ammo in ipairs(Config.ArmoryAmmo) do
        if ammo.type == ammotype then
            ammoExists = true
            break
        end
    end

    if not ammoExists then
        if Config.Debug then
            print(('[ARMORY] ERROR: Invalid ammo type: %s'):format(ammotype))
        end
        TriggerClientEvent("esx:showNotification", playerId, Config.Locales[Config.Language].ammunitionisnotavailable)
        return
    end

    exports.core_inventory:addItem(
        playerId,
        ammotype,
        1,
        Config.InventoryType
    )
    TriggerClientEvent("esx:showNotification", playerId, (Config.Locales[Config.Language].youreceived):format(ESX.GetItemLabel(ammotype) or ammotype))
end)

-- Attachments-Handler
RegisterServerEvent("qalle_policearmory:giveattachment")
AddEventHandler("qalle_policearmory:giveattachment", function(attachmentName)
    local playerId = source
    local player = ESX.GetPlayerFromId(playerId)
    
    if not player then 
        if Config.Debug then
            print(('[ARMORY] Player not found: %s'):format(playerId))
        end
        return 
    end

    if Config.OnlyPolicemen and player.job.name ~= 'police' then
        TriggerClientEvent("esx:showNotification", playerId, Config.Locales[Config.Language].notauthorized)
        return
    end

    -- Attachment Validierung
    local attachmentExists = false
    local attachmentLabel = ""
    for _, attachment in ipairs(Config.ArmoryAttachments) do
        if attachment.name == attachmentName then
            attachmentExists = true
            attachmentLabel = attachment.label
            break
        end
    end

    if not attachmentExists then
        if Config.Debug then
            print(('[ARMORY] ERROR: Invalid attachment: %s'):format(attachmentName))
        end
        TriggerClientEvent("esx:showNotification", playerId, Config.Locales[Config.Language].attachmentisnotavailable)
        return
    end

    exports.core_inventory:addItem(
        playerId,
        attachmentName,
        1,
        Config.InventoryType
    )
    TriggerClientEvent("esx:showNotification", playerId, (Config.Locales[Config.Language].youreceived):format(attachmentLabel))
end)

-- Waffen-Handler
RegisterServerEvent("qalle_policearmory:giveWeapon")
AddEventHandler("qalle_policearmory:giveWeapon", function(weaponHash)
    local playerId = source
    local player = ESX.GetPlayerFromId(playerId)
    
    if not player then 
        if Config.Debug then
            print(('[ARMORY] Player not found: %s'):format(playerId))
        end
        return 
    end
    
    if Config.OnlyPolicemen and player.job.name ~= 'police' then
        TriggerClientEvent("esx:showNotification", playerId, Config.Locales[Config.Language].notauthorized)
        return
    end
    
    -- Waffen-Daten vorbereiten
    local cleanWeaponHash = weaponHash:gsub("WEAPON_", ""):lower()
    local weaponName = cleanWeaponHash
    local weaponLabel = ESX.GetWeaponLabel(weaponHash) or weaponName
    
    local metadata = {
        serial = GenerateSerialNumber(),
        ammo = Config.ReceiveAmmo,
        components = {},
        registered = player.getName(),
        durability = 100.0
    }
    
    if Config.Debug then
        print(('[ARMORY] Attempting to add weapon: %s to player: %s'):format(weaponName, playerId))
    end
    
    -- Waffen-Validierung
    if not ESX.GetItemLabel(weaponName) then
        if Config.Debug then
            print(('[ARMORY] ERROR: Item does not exist: %s'):format(weaponName))
        end
        TriggerClientEvent("esx:showNotification", playerId, Config.Locales[Config.Language].weaponisnotavailable)
        return
    end
    
    -- Waffe hinzufügen
    local success, reason = exports.core_inventory:addItem(
        playerId,
        weaponName,
        1,
        metadata,
        Config.InventoryType
    )
    
    if success then
        if Config.Debug then
            print(('[ARMORY] Successfully added weapon: %s to player: %s'):format(weaponName, playerId))
        end
        TriggerClientEvent("esx:showNotification", playerId, (Config.Locales[Config.Language].giveammo):format(weaponLabel, Config.ReceiveAmmo))
    else
        if Config.Debug then
            print(('[ARMORY] Failed to add weapon: %s to player: %s. Reason: %s'):format(weaponName, playerId, reason or "unknown"))
        end
        
        -- Fallback-Logik
        local inventory = exports.core_inventory:getInventory(playerId, Config.InventoryType)
        if inventory then
            success, reason = inventory.addItem(weaponName, 1, metadata)
            if success then
                TriggerClientEvent("esx:showNotification", playerId, Config.Locales[Config.Language].addafterretry)
            else
                TriggerClientEvent("esx:showNotification", playerId, (Config.Locales[Config.Language].giveerror):format(reason or "Please try again"))
            end
        else
            TriggerClientEvent("esx:showNotification", playerId, Config.Locales[Config.Language].inverror)
        end
    end
end)

-- Hilfsfunktionen
function GenerateSerialNumber()
    local charset = "ABCDEFGHJKLMNPQRSTUVWXYZ123456789"
    local serial = "PD-"
    for i = 1, 6 do
        local rand = math.random(#charset)
        serial = serial .. string.sub(charset, rand, rand)
    end
    return serial
end