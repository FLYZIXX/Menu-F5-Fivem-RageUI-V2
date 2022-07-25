ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--------- Menu -------

local Xperso = {
    ItemSelected = {},
    ItemSelected2 = {},
}

function CheckQuantity(number)
    number = tonumber(number)

    if type(number) == 'number' then
        number = ESX.Math.Round(number)

        if number > 0 then
            return true, number
        end
    end

    return false, number

end

local function XpersonalmenuKeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMCC_KEY_TIP1', TextEntry)
    DisplayOnscreenKeyboard(1, "FMMC_KEYTIP1" , "", ExampleText, "", "", "", MaxStringLenght)
    blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(0)
        blockinput = false
        return result
    else
        Citizen.Wait(0)
        blockinput = false
        return nil
    end
    
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RMenu.Add('flyzixxf5', 'main', RageUI.CreateMenu("Pealife", "Menu Interaction"))
RMenu.Add('flyzixxf5', 'inventaire', RageUI.CreateSubMenu(RMenu:Get('flyzixxf5', 'main'), "Inventaire", "Inventaire"))
RMenu.Add('flyzixxf5', 'inventaire2', RageUI.CreateSubMenu(RMenu:Get('flyzixxf5', 'main'), "Inventaire", "Inventaire"))
RMenu.Add('flyzixxf5', 'portefeuille', RageUI.CreateSubMenu(RMenu:Get('flyzixxf5', 'main'), "Portefeuille", "Portefeuille"))

Citizen.CreateThread(function()
    while true do
        RageUI.IsVisible(RMenu:Get('flyzixxf5', 'main'), true, true, true, function()

            RageUI.Separator("~b~ Pealife ~w~| discord.gg/~b~pealife")
            RageUI.Separator("Votre ID : ~b~"..GetPlayerServerId(PlayerId()))

            RageUI.ButtonWithStyle("Inventaire", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
            end, RMenu:Get('flyzixxf5', 'inventaire'))

            RageUI.ButtonWithStyle("Portefeuille", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
            end, RMenu:Get('flyzixxf5', 'portefeuille'))

        end, function()
        end)

            RageUI.IsVisible(RMenu:Get('flyzixxf5', 'inventaire'), true, true, true, function()

                ESX.PlayerData = ESX.GetPlayerData()
                local elements, currentWeight = {}, 0
                local playerPed = PlayerPedId()
                for k,v in ipairs(ESX.PlayerData.inventory) do
                    if v.count > 0 then 
                        currentWeight = currentWeight + (v.weight * v.count)
                        table.insert(elements, {
                            label = ('%s x%s'):format(v.label, v.count),
                            count = v.count,
                            type = 'item_standard',
                            value = v.name,
                            usable = v.usable,
                            rare = v.rare,
                            canRemove = v.canRemove,
                        })
                    end
                end

                RageUI.Separator("~b~↓ Poids : "..currentWeight.. " ~b~sur 50 kg ↓")

                ESX.PlayerData = ESX.GetPlayerData()
                for i = 1, #ESX.PlayerData.inventory do
                    if ESX.PlayerData.inventory[i].count > 0 then
                        RageUI.ButtonWithStyle('[' ..ESX.PlayerData.inventory[i].count.. '] - ~s~' ..ESX.PlayerData.inventory[i].label, nil, {RightLabel = "→" }, true, function(Hovered, Active, Selected)
                            if (Selected) then
                                Xperso.ItemSelected = ESX.PlayerData.inventory[i]
                            end
                        end, RMenu:Get('flyzixxf5', 'inventaire2'))
                    end
                end
            end, function()
            end)

            RageUI.IsVisible(RMenu:Get('flyzixxf5', 'inventaire2'), true, true, true, function()

                RageUI.ButtonWithStyle("Utiliser", nil, {RightBadge = RageUI.BadgeStyle.Heart}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        if Xperso.ItemSelected.usable then
                            TriggerServerEvent('esx:useItem', Xperso.ItemSelected.name)
                        else
                            ESX.ShowNotification('L\'item n\'est pas utilisable', Xperso0.ItemSelected.label)
                        end
                    end
                end)

                RageUI.ButtonWithStyle("Jeter", nil, {RightBadge = RageUI.BadgeStyle.Alert}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        if Xperso.ItemSelected.canRemove then
                            local post,quantity = CheckQuantity(XpersonalmenuKeyboardInput("Nombres d'items que vous voulez jeter", '', '', 100))
                            if post then
                                if not IsPedSittingInAnyVehicle(PlayerPedId()) then
                                    TriggerServerEvent('esx:removeInventoryItem', 'item_standard', Xperso.ItemSelected.name, quantity)
                                else
                                    ESX.ShowNotification("Vous ne pouvez pas faire ceci dans un véhicule !")
                                end
                            end
                        end
                    end
                end)

                RageUI.ButtonWithStyle("Donner", nil, {RightBadge = RageUI.BadgeStyle.Tick}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        local sonner,quantity = CheckQuantity(XpersonalmenuKeyboardInput("Nombres d'items que vous voulez donner", '', '', 100))
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        local pPed = GetPlayerPed(-1)
                        local coords = GetEntityCoords(pPed)
                        local x,y,z = table.unpack(coords)
                        DrawMarker(2, x, y, z+1.5, 0, 0, 0, 180.0,nil,nil, 0.5, 0.5, 0.5, 0, 0, 255, 120, true, tru, p19, true)

                        if sonner then
                            if closestDistance ~= -1 and closestDistance <= 3 then
                                local closestPed = GetPlayerPed(closestPlayer)

                                if IsPedOnFoot(closestPed) then
                                    TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_standard', Xperso.ItemSelected.name, quantity)
                                else
                                    ESX.ShowNotification("Nombres d'items invalide !")
                                end
                            else
                                ESX.ShowNotification("Aucun Joueur ~b~Proche ~w~!")
                            end
                        end
                    end
                end)
            end, function()
            end)

            RageUI.IsVisible(RMenu:Get('flyzixxf5', 'portefeuille'), true, true, true, function()

                RageUI.Separator("~b~↓ ~w~Informations : ~b~↓")

                RageUI.Separator("~w~Job :~b~ " .. ESX.PlayerData.job.label .. "~w~ | ~b~" .. ESX.PlayerData.job.grade_label.. " ~w~|")

                RageUI.Separator("~w~Organisation :~b~ " .. ESX.PlayerData.job2.label .. "~w~ | ~b~" .. ESX.PlayerData.job2.grade_label .. " ~w~|")
   
                RageUI.Separator("~b~↓ ~w~Finance : ~b~↓")

                for i = 1, #ESX.PlayerData.accounts, 1 do
                    if ESX.PlayerData.accounts[i].name == 'bank'  then
                        RageUI.ButtonWithStyle('Banque', nil, {RightLabel = "~b~$"..ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money.."~s~")}, true, function(Hovered, Active, Selected) 
                            if (Selected) then 
                            end 
                        end)
                    end
                end

                RageUI.ButtonWithStyle('Liquide', nil, {RightLabel = "~g~$"..ESX.Math.GroupDigits(ESX.PlayerData.money.."~s~ →")}, true, function(Hovered, Active, Selected) 
                    if (Selected) then 
                        end 
                    end, RMenu:Get('inventory', 'portefeuille_money'))

                    RageUI.IsVisible(RMenu:Get('inventory', 'portefeuille_money'), true, true, true, function()
                        RageUI.ButtonWithStyle('Donner argent', nil, {RightLabel = "→→"}, true, function(_,a,s)
                            if a then
                                PlayerMarker();
                            end
                            if s then
                                local quantity = KeyboardInput('Quantité d\'argent liquide à donner :', "", 25)
                                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer();
                                if tonumber(quantity) then
                                    if closestDistance ~= -1 and closestDistance <= 3 then
                                        local cPed = GetPlayerPed(closestPlayer)
                                        if IsPedOnFoot(cPed) then
                                            TriggerServerEvent('esx_personalmenu:TransferCashMoney', GetPlayerServerId(closestPlayer), tonumber(quantity));
                                            Citizen.Wait(150);
                                            RageUI:GoBack();
                                            TriggerServerEvent('esx_personalmenu:logTransferCashMoney', tonumber(quantity), GetPlayerName(closestPlayer));
                                        else
                                            ESX.ShowNotification('~r~Cette action est impossible dans un véhicule !', true, true, 50);
                                        end
                                    else
                                        ESX.ShowNotification('~r~Aucun joueur à proximité !', true, true, 50);
                                    end
                                else
                                    ESX.ShowNotification('~r~Les champs sont incorrects !', true, true, 50);
                                end
                            end
                        end)
                    

                    for i = 1, #ESX.PlayerData.accounts, 1 do
                        if ESX.PlayerData.accounts[i].name == 'black_money'  then
                            RageUI.ButtonWithStyle('Non déclaré', nil, {RightLabel = "~r~$"..ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money.."~s~ →")}, true, function(Hovered, Active, Selected) 
                                if (Selected) then 
                                end 
                            end, RMenu:Get('inventory', 'portefeuille_use'))
                        end
                    end

                RageUI.Separator("~b~↓ ~w~Vos license ~b~↓")

                RageUI.ButtonWithStyle('Regarder sa carte d\'identité', nil, {RightLabel = nil }, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
                    end
                end)

                RageUI.ButtonWithStyle('Montrer sa carte d\'identité', nil, {RightLabel = nil }, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestDistance ~= -1 and closestDistance <= 3.0 then
                        TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
                        else
                            ESX.ShowNotification(('Personne à proximité de vous !'))
                        end
                    end
                end)
            end, function()
            end)
            Citizen.Wait(0)
        end
    end)


    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if IsControlJustPressed(1, 327) then
                RageUI.Visible(RMenu:Get('flyzixxf5', 'main'), not RageUI.Visible(RMenu:Get('menu-tuto', 'main')))
            end
        end
    end)