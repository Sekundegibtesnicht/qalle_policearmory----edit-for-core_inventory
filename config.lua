



Config = {
    Debug = false,
    ReceiveAmmo = 60, -- Default ammo count
    OnlyPolicemen = true, -- Restrict to police job
    InventoryType = 'player', -- Standard inventory type
    Armory = {x = 75.432891845703, y = -391.15060424805, z = 41.624782562256, h = 66.46060943603516}, -- Position des Armory-Menüs
    ArmoryPed = {x = 73.74, y = -390.46, z = 41.624774932861, h = 254.70895385742, hash = "s_m_y_cop_01"}, -- Position und Model des NPC
    
    ArmoryWeapons = {
        {hash = "weapon_pistol", type = "pistol"},
        {hash = "weapon_combatpistol", type = "pistol"},
        {hash = "weapon_carbinerifle", type = "rifle"}
    },
    
    ArmoryAmmo = {
        {label = "Pistol Ammo", type = "9mm_ammo", amount = 50, prop = "prop_ld_ammo_pack_01"},
        {label = "Rifle Ammo", type = "AMMO_RIFLE", amount = 60, prop = "prop_ld_ammo_pack_02"},
        {label = "SMG Ammo", type = "AMMO_SMG", amount = 100, prop = "prop_ld_ammo_pack_03"}
    },
    
    ArmoryAttachments = {
        {label = "Flashlight", name = "at_flashlight", prop = "w_me_flashlight"},
        {label = "Scope", name = "at_scope_small_3", prop = "w_at_scope_small"},
        {label = "Suppressor", name = "suppressor", prop = "w_at_ar_supp"}
    },


    
}

Config.Locales = {
    ['en'] = {
        --Notify
        tryagain = "Please try again.",
        officernotavailable = "Armory officer is not available.",
        Pleasewait = "Please wait your turn.",
        youreceived = "You received",
        notauthorized = "You are not authorized to access the armory!",
        attachmentisnotavailable = "This attachment is not available",
        weaponisnotavailable = "This weapon is not available",
        ammunitionisnotavailable = "This ammunition is not available",
        inverror = "Inventory system error - please try again",
        giveammo = "Received %s with %d rounds",
        addafterretry = "Weapon added after retry",
        giveerror = "Failed to receive weapon: %s",



        --point
        Armory = "Armory",

        --Main menu
        maintitle = "Police Armory",
        Weaponstorage = "Weapon Storage",
        Ammunition = "Ammunition",
        Attachments = "Attachments",

        --other title
        Ammunitiontitle = "Police Ammunition",
        Attachmentstitle = "Police Attachments",

    },
    ['de'] = {
        --Notify
        tryagain = "Bitte versuche es erneut.",
        officernotavailable = "Waffenkammeroffizier ist nicht verfügbar.",
        Pleasewait = "Bitte warte, bis du an der Reihe bist.",
        youreceived = "Du hast erhalten",
        notauthorized = "Du bist nicht berechtigt, auf die Waffenkammer zuzugreifen!",
        attachmentisnotavailable = "Dieses Zubehör ist nicht verfügbar",
        weaponisnotavailable = "Diese Waffe ist nicht verfügbar",
        ammunitionisnotavailable = "Diese Munition ist nicht verfügbar",
        inverror = "Inventarsystemfehler - bitte versuche es erneut",
        giveammo = "Du hast eine %s mit %d Schuss Bekommen",
        addafterretry = "Waffe nach Wiederholung hinzugefügt",
        giveerror = "Waffe konnte nicht erhalten werden: %s",

        --point
        Armory = "Waffenkammer",

        --Main menu
        maintitle = "Polizei-Waffenkammer",
        Weaponstorage = "Waffenlager",
        Ammunition = "Munition",
        Attachments = "Zubehör",

        --other title
        Ammunitiontitle = "Polizei-Munition",
        Attachmentstitle = "Polizei-Zubehör",
    }
}

Config.Language = 'en'