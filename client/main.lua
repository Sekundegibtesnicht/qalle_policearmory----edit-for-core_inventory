ESX = exports["es_extended"]:getSharedObject()

-- Player Load Handlers
Citizen.CreateThread(function()
    if ESX.IsPlayerLoaded() then
        ESX.PlayerData = ESX.GetPlayerData()
        RefreshPed()
    end
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(response)
    ESX.PlayerData = response
    RefreshPed()
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(response)
    ESX.PlayerData["job"] = response
end)

-- Main Armory Thread
Citizen.CreateThread(function()
    Citizen.Wait(100)

    while true do
        local sleepThread = 500

        if not Config.OnlyPolicemen or (Config.OnlyPolicemen and ESX.PlayerData["job"] and ESX.PlayerData["job"]["name"] == "police") then
            local ped = PlayerPedId()
            local pedCoords = GetEntityCoords(ped)
            local dstCheck = GetDistanceBetweenCoords(pedCoords, Config.Armory["x"], Config.Armory["y"], Config.Armory["z"], Config.Armory["h"], true)

            if dstCheck <= 5.0 then
                sleepThread = 5
                local text = Config.Locales[Config.Language].Armory

                if dstCheck <= 0.5 then
                    text = "[~g~E~s~] " .. text

                    if IsControlJustPressed(0, 38) then
                        OpenPoliceArmory()
                    end
                end

                ESX.Game.Utils.DrawText3D(Config.Armory, text, 0.6)
            end
        end

        Citizen.Wait(sleepThread)
    end
end)

-- Armory Menu Functions
function OpenPoliceArmory()
    PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)

    local elements = {
        { label = Config.Locales[Config.Language].Weaponstorage, action = "weapon_storage" },
        { label = Config.Locales[Config.Language].Ammunition, action = "ammo_storage" },
        { label = Config.Locales[Config.Language].Attachments, action = "attachment_storage" }
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), "police_armory_menu", {
        title = Config.Locales[Config.Language].maintitle,
        align = "center",
        elements = elements
    }, function(data, menu)
        local action = data.current.action

        if action == "weapon_storage" then
            OpenWeaponStorage()
        elseif action == "ammo_storage" then
            OpenAmmoStorage()
        elseif action == "attachment_storage" then
            OpenAttachmentStorage()
        end
    end, function(data, menu)
        PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)
        menu.close()
    end, function(data, menu)
        PlaySoundFrontend(-1, 'NAV', 'HUD_AMMO_SHOP_SOUNDSET', false)
    end)
end

function OpenWeaponStorage()
    PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)

    local elements = {}
    local Location = Config.Armory
    local PedLocation = Config.ArmoryPed

    for i = 1, #Config.ArmoryWeapons do
        local weapon = Config.ArmoryWeapons[i]
        table.insert(elements, { label = ESX.GetWeaponLabel(weapon.hash), weapon = weapon })
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), "police_armory_weapon_menu", {
        title = "Police Weapon Armory",
        align = "center",
        elements = elements
    }, function(data, menu)
        local anim = data.current.weapon.type
        local weaponHash = data.current.weapon.hash

        ESX.UI.Menu.CloseAll()
        local closestPed, closestPedDst = ESX.Game.GetClosestPed(PedLocation)

        if (DoesEntityExist(closestPed) and closestPedDst >= 5.0) or IsPedAPlayer(closestPed) then
            RefreshPed(true)
            ESX.ShowNotification(Config.Locales[Config.Language].tryagain)
            return
        end

        if IsEntityPlayingAnim(closestPed, "mp_cop_armoury", "pistol_on_counter_cop", 3) or 
           IsEntityPlayingAnim(closestPed, "mp_cop_armoury", "rifle_on_counter_cop", 3) then
            ESX.ShowNotification(Config.Locales[Config.Language].Pleasewait)
            return
        end

        if not NetworkHasControlOfEntity(closestPed) then
            NetworkRequestControlOfEntity(closestPed)
            Citizen.Wait(1000)
        end

        SetEntityCoords(closestPed, PedLocation.x, PedLocation.y, PedLocation.z - 0.985)
        SetEntityHeading(closestPed, PedLocation.h)
        SetEntityCoords(PlayerPedId(), Location.x, Location.y, Location.z - 0.985)
        SetEntityHeading(PlayerPedId(), Location.h)
        SetCurrentPedWeapon(PlayerPedId(), GetHashKey("weapon_unarmed"), true)

        local animLib = "mp_cop_armoury"
        LoadModels({ animLib })

        if DoesEntityExist(closestPed) and closestPedDst <= 5.0 then
            TaskPlayAnim(closestPed, animLib, anim .. "_on_counter_cop", 1.0, -1.0, 1.0, 0, 0, 0, 0, 0)
            Citizen.Wait(1100)

            GiveWeaponToPed(closestPed, GetHashKey(weaponHash), 1, false, true)
            SetCurrentPedWeapon(closestPed, GetHashKey(weaponHash), true)

            TaskPlayAnim(PlayerPedId(), animLib, anim .. "_on_counter", 1.0, -1.0, 1.0, 0, 0, 0, 0, 0)
            Citizen.Wait(3100)

            RemoveWeaponFromPed(closestPed, GetHashKey(weaponHash))
            Citizen.Wait(15)

            GiveWeaponToPed(PlayerPedId(), GetHashKey(weaponHash), Config.ReceiveAmmo, false, true)
            SetCurrentPedWeapon(PlayerPedId(), GetHashKey(weaponHash), true)
            Citizen.Wait(3100)
            RemoveWeaponFromPed(PlayerPedId(), GetHashKey(weaponHash))
            ClearPedTasks(closestPed)

            TriggerServerEvent("qalle_policearmory:giveWeapon", weaponHash)
        end

        UnloadModels()
    end, function(data, menu)
        PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)
        menu.close()
    end, function(data, menu)
        PlaySoundFrontend(-1, 'NAV', 'HUD_AMMO_SHOP_SOUNDSET', false)
    end)
end

function OpenAmmoStorage()
    PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)

    local elements = {}
    
    for i = 1, #Config.ArmoryAmmo do
        local ammo = Config.ArmoryAmmo[i]
        table.insert(elements, {
            label = ammo.label,
            ammoType = ammo.type,
            amount = ammo.amount,
            prop = ammo.prop
        })
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), "police_armory_ammo_menu", {
        title = Config.Locales[Config.Language].Ammunitiontitle,
        align = "center",
        elements = elements
    }, function(data, menu)
        local prop = data.current.prop
        local animDict = "mp_cop_armoury"
        
        ESX.UI.Menu.CloseAll()
        LoadModels({ animDict, GetHashKey(prop) })
        
        local closestPed, closestPedDst = ESX.Game.GetClosestPed(Config.ArmoryPed)
        
        if (DoesEntityExist(closestPed) and closestPedDst >= 5.0) or IsPedAPlayer(closestPed) then
            RefreshPed(true)
            closestPed, closestPedDst = ESX.Game.GetClosestPed(Config.ArmoryPed)
            ESX.ShowNotification(Config.Locales[Config.Language].tryagain)
            return
        end

        if not DoesEntityExist(closestPed) then
            ESX.ShowNotification(Config.Locales[Config.Language].officernotavailable)
            return
        end

        if IsEntityPlayingAnim(closestPed, animDict, "pistol_on_counter_cop", 3) then
            ESX.ShowNotification(Config.Locales[Config.Language].Pleasewait)
            return
        end

        if not NetworkHasControlOfEntity(closestPed) then
            NetworkRequestControlOfEntity(closestPed)
            Citizen.Wait(1000)
        end

        SetEntityCoords(closestPed, Config.ArmoryPed.x, Config.ArmoryPed.y, Config.ArmoryPed.z - 0.985)
        SetEntityHeading(closestPed, Config.ArmoryPed.h)
        SetEntityCoords(PlayerPedId(), Config.Armory.x, Config.Armory.y, Config.Armory.z - 0.985)
        SetEntityHeading(PlayerPedId(), Config.Armory.h)
        SetCurrentPedWeapon(PlayerPedId(), GetHashKey("weapon_unarmed"), true)

        TaskPlayAnim(closestPed, animDict, "pistol_on_counter_cop", 1.0, -1.0, 1.0, 0, 0, 0, 0, 0)
        TaskPlayAnim(PlayerPedId(), animDict, "pistol_on_counter", 1.0, -1.0, 1.0, 0, 0, 0, 0, 0)
        
        local propEntity = CreateObject(GetHashKey(prop), Config.ArmoryPed.x, Config.ArmoryPed.y, Config.ArmoryPed.z + 0.2, true, true, true)
        AttachEntityToEntity(propEntity, closestPed, GetPedBoneIndex(closestPed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        
        Citizen.Wait(2000)
        DetachEntity(propEntity, true, true)
        AttachEntityToEntity(propEntity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        Citizen.Wait(2000)
        
        DeleteObject(propEntity)
        ClearPedTasks(closestPed)
        ClearPedTasks(PlayerPedId())
        TriggerServerEvent('qalle_policearmory:giveammo', data.current.ammoType)
        UnloadModels()
    end, function(data, menu)
        PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)
        menu.close()
    end, function(data, menu)
        PlaySoundFrontend(-1, 'NAV', 'HUD_AMMO_SHOP_SOUNDSET', false)
    end)
end

function OpenAttachmentStorage()
    PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)

    local elements = {}
    
    for i = 1, #Config.ArmoryAttachments do
        local attachment = Config.ArmoryAttachments[i]
        table.insert(elements, {
            label = attachment.label,
            name = attachment.name,
            prop = attachment.prop
        })
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), "police_armory_attachment_menu", {
        title = Config.Locales[Config.Language].Attachmentstitle,
        align = "center",
        elements = elements
    }, function(data, menu)
        local prop = data.current.prop
        local animDict = "mp_cop_armoury"
        
        ESX.UI.Menu.CloseAll()
        LoadModels({ animDict, GetHashKey(prop) })
        
        local closestPed, closestPedDst = ESX.Game.GetClosestPed(Config.ArmoryPed)
        
        if (DoesEntityExist(closestPed) and closestPedDst >= 5.0) or IsPedAPlayer(closestPed) then
            RefreshPed(true)
            closestPed, closestPedDst = ESX.Game.GetClosestPed(Config.ArmoryPed)
            ESX.ShowNotification(Config.Locales[Config.Language].tryagain)
            return
        end

        if not DoesEntityExist(closestPed) then
            ESX.ShowNotification(Config.Locales[Config.Language].officernotavailable)
            return
        end

        if IsEntityPlayingAnim(closestPed, animDict, "pistol_on_counter_cop", 3) then
            ESX.ShowNotification(Config.Locales[Config.Language].Pleasewait)
            return
        end

        if not NetworkHasControlOfEntity(closestPed) then
            NetworkRequestControlOfEntity(closestPed)
            Citizen.Wait(1000)
        end

        SetEntityCoords(closestPed, Config.ArmoryPed.x, Config.ArmoryPed.y, Config.ArmoryPed.z - 0.985)
        SetEntityHeading(closestPed, Config.ArmoryPed.h)
        SetEntityCoords(PlayerPedId(), Config.Armory.x, Config.Armory.y, Config.Armory.z - 0.985)
        SetEntityHeading(PlayerPedId(), Config.Armory.h)
        SetCurrentPedWeapon(PlayerPedId(), GetHashKey("weapon_unarmed"), true)

        TaskPlayAnim(closestPed, animDict, "pistol_on_counter_cop", 1.0, -1.0, 1.0, 0, 0, 0, 0, 0)
        TaskPlayAnim(PlayerPedId(), animDict, "pistol_on_counter", 1.0, -1.0, 1.0, 0, 0, 0, 0, 0)
        
        local propEntity = CreateObject(GetHashKey(prop), Config.ArmoryPed.x, Config.ArmoryPed.y, Config.ArmoryPed.z + 0.2, true, true, true)
        AttachEntityToEntity(propEntity, closestPed, GetPedBoneIndex(closestPed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        
        Citizen.Wait(2000)
        DetachEntity(propEntity, true, true)
        AttachEntityToEntity(propEntity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        Citizen.Wait(2000)
        
        DeleteObject(propEntity)
        ClearPedTasks(closestPed)
        ClearPedTasks(PlayerPedId())
        TriggerServerEvent('qalle_policearmory:giveattachment', data.current.name)
        UnloadModels()
    end, function(data, menu)
        PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)
        menu.close()
    end, function(data, menu)
        PlaySoundFrontend(-1, 'NAV', 'HUD_AMMO_SHOP_SOUNDSET', false)
    end)
end

-- Ped Management
function RefreshPed(spawn)
    local Location = Config.ArmoryPed

    ESX.TriggerServerCallback("qalle_policearmory:pedExists", function(Exists)
        if Exists and not spawn then
            return
        else
            LoadModels({ GetHashKey(Location.hash) })

            local pedId = CreatePed(5, Location.hash, Location.x, Location.y, Location.z - 0.985, Location.h, true)

            SetPedCombatAttributes(pedId, 46, true)                     
            SetPedFleeAttributes(pedId, 0, 0)                      
            SetBlockingOfNonTemporaryEvents(pedId, true)
            SetEntityAsMissionEntity(pedId, true, true)
            SetEntityInvincible(pedId, true)
            FreezeEntityPosition(pedId, true)
        end
    end)
end

-- Model Management
local CachedModels = {}

function LoadModels(models)
    for modelIndex = 1, #models do
        local model = models[modelIndex]
        
        local alreadyLoaded = false
        for _, cachedModel in ipairs(CachedModels) do
            if cachedModel == model then
                alreadyLoaded = true
                break
            end
        end
        
        if not alreadyLoaded then
            table.insert(CachedModels, model)

            if IsModelValid(model) then
                while not HasModelLoaded(model) do
                    RequestModel(model)
                    Citizen.Wait(10)
                end
            else
                while not HasAnimDictLoaded(model) do
                    RequestAnimDict(model)
                    Citizen.Wait(10)
                end    
            end
        end
    end
end

function UnloadModels()
    while #CachedModels > 0 do
        local model = CachedModels[1]

        if IsModelValid(model) then
            SetModelAsNoLongerNeeded(model)
        else
            RemoveAnimDict(model)   
        end

        table.remove(CachedModels, 1)
    end
end