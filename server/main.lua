local QBCore = exports['qb-core']:GetCoreObject()
local isRoll = false
local car = false
local spinTable = {}

QBCore.Functions.CreateCallback('qb-luckywheel:CheckCanSpin', function(source, cb)
    local source = source
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local chips = xPlayer.Functions.GetItemByName('casinochips')

    if chips and chips.amount >= Config.Amount and isRoll == false then
        if spinTable[xPlayer.PlayerData.citizenid] then
            if spinTable[xPlayer.PlayerData.citizenid] <= os.time() - (Config.SpinCooldown * 60) then
                spinTable[xPlayer.PlayerData.citizenid] = os.time()
                cb(true, nil)
            else
                cb(false, 'time')
            end
        else
            spinTable[xPlayer.PlayerData.citizenid] = os.time()
            cb(true, nil)
        end
    else
        cb(false, 'chips')
    end
end)

RegisterNetEvent('qb-luckywheel:server:getLucky', function()
    local source = source
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if not isRoll then
        if xPlayer then
            local chips = xPlayer.Functions.GetItemByName('casinochips')
            if chips and chips.amount >= Config.Amount then
                xPlayer.Functions.RemoveItem('casinochips', Config.Amount)
                isRoll = true

                local _randomPrice = math.random(1, 100)
                if _randomPrice == 1 then
                    -- Win car
                    local _subRan = math.random(1,1000)
                    if _subRan <= 1 then
                        _priceIndex = 19
                    else
                        _priceIndex = 3
                    end
                elseif _randomPrice > 1 and _randomPrice <= 6 then
                    -- Win skin AK Gold
                    _priceIndex = 12
                    local _subRan = math.random(1,20)
                    if _subRan <= 2 then
                        _priceIndex = 12
                    else
                        _priceIndex = 7
                    end
                elseif _randomPrice > 6 and _randomPrice <= 15 then
                    -- Black money
                    -- 4, 8, 11, 16
                    local _sRan = math.random(1, 4)
                    if _sRan == 1 then
                        _priceIndex = 4
                    elseif _sRan == 2 then
                        _priceIndex = 8
                    elseif _sRan == 3 then
                        _priceIndex = 11
                    else
                        _priceIndex = 16
                    end
                elseif _randomPrice > 15 and _randomPrice <= 25 then
                    -- Win 300,000$
                    -- _priceIndex = 5
                    local _subRan = math.random(1,20)
                    if _subRan <= 2 then
                        _priceIndex = 5
                    else
                        _priceIndex = 20
                    end
                elseif _randomPrice > 25 and _randomPrice <= 40 then
                    -- 1, 9, 13, 17
                    local _sRan = math.random(1, 4)
                    if _sRan == 1 then
              
                        _priceIndex = 1
                    elseif _sRan == 2 then
                        _priceIndex = 9
                    elseif _sRan == 3 then
                        _priceIndex = 13
                    else
                        _priceIndex = 17
                    end
                elseif _randomPrice > 40 and _randomPrice <= 60 then
                    local _itemList = {}
                    _itemList[1] = 2
                    _itemList[2] = 6
                    _itemList[3] = 10
                    _itemList[4] = 14
                    _itemList[5] = 18
                    _priceIndex = _itemList[math.random(1, 5)]
                elseif _randomPrice > 60 and _randomPrice <= 100 then
                    local _itemList = {}
                    _itemList[1] = 3
                    _itemList[2] = 7
                    _itemList[3] = 15
                    _itemList[4] = 20
                    _priceIndex = _itemList[math.random(1, 4)]
                end
                SetTimeout(6000, function()
                    isRoll = false
                    -- Give Price
                    if _priceIndex == 1 or _priceIndex == 9 or _priceIndex == 13 or _priceIndex == 17 then
                        xPlayer.Functions.AddItem('casinochips', 250)
                        TriggerClientEvent('QBCore:Notify', source, Lang:t('success.You_Won', {prize = Lang:t('general.chips')}), 'success')
                    elseif _priceIndex == 2 or _priceIndex == 6 or _priceIndex == 10 or _priceIndex == 14 or _priceIndex == 18 then
                        xPlayer.Functions.AddItem('sandwich', 10)
                        xPlayer.Functions.AddItem('water_bottle', 24)
                        TriggerClientEvent('QBCore:Notify', source, Lang:t('success.You_Won', {prize = Lang:t('general.sandwich_water')}), 'success')
                    elseif _priceIndex == 3 or _priceIndex == 7 or _priceIndex == 15 or _priceIndex == 20 then
                        local _money = 0
                        if _priceIndex == 3 then
                            _money = 2000
                        elseif _priceIndex == 7 then
                            _money = 3000
                        elseif _priceIndex == 15 then
                            _money = 4000
                        elseif _priceIndex == 20 then
                            _money = 5000
                        end
                        xPlayer.Functions.AddMoney('cash', _money)
                        TriggerClientEvent('QBCore:Notify', source, Lang:t('success.You_Won', {prize = Lang:t('general.money', {money_amount = _money})}), 'success')
                    elseif _priceIndex == 4 or _priceIndex == 8 or _priceIndex == 11 or _priceIndex == 16 then
                        local _blackMoney = 0
                        if _priceIndex == 4 then
                            _blackMoney = 10000
                        elseif _priceIndex == 8 then
                            _blackMoney = 15000
                        elseif _priceIndex == 11 then
                            _blackMoney = 20000
                        elseif _priceIndex == 16 then
                            _blackMoney = 25000
                        end
                        xPlayer.Functions.AddItem('markedbills', _blackMoney * 10)
                        TriggerClientEvent('QBCore:Notify', source, Lang:t('success.You_Won', {prize = Lang:t('general.Marked')}), 'success')
                    elseif _priceIndex == 5 then
                        xPlayer.Functions.AddMoney('cash', 30000)
                        TriggerClientEvent('QBCore:Notify', source, Lang:t('success.You_Won', {prize = Lang:t('general.cash')}), 'success')
                    elseif _priceIndex == 12 then
                        xPlayer.Functions.AddItem('weapon_pistol50', 1)
                        TriggerClientEvent('QBCore:Notify', source, Lang:t("success.You_Won", {prize = Lang:t('general.pistol')}), 'success')
                    elseif _priceIndex == 19 then
                        if Config.GiveCarOnWin then 
                            TriggerClientEvent('qb-luckywheel:client:winCar', source)
                            car = true
                        else
                            TriggerClientEvent('qb-luckywheel:client:winCarEmail', source)
                        end
                    end
                    TriggerClientEvent('qb-luckywheel:client:rollFinished', -1)
                end)
                TriggerClientEvent('qb-luckywheel:client:doRoll', -1, _priceIndex)
            else
                TriggerClientEvent('QBCore:Notify', source, Lang:t('error.need_chips', {Chipsamount = Config.Amount}), 'error')
            end
        end
    end
end)

RegisterNetEvent('qb-luckywheel:server:carRedeem', function(vehicleProps)
    local source = source

    local xPlayer = QBCore.Functions.GetPlayer(source)
    local plate = 'CSNO'
    local getPlate = true
    local plateAvailable = ''
    while getPlate do
        Citizen.Wait(0)
        local plateNumbers = math.random(1000,9999)
        local testplate = plate..plateNumbers
        local result = exports.oxmysql:scalarSync('SELECT * from player_vehicles WHERE plate=  = ?', {plate})
            plateAvailable = result[1]
        if plateAvailable == nil then
            vehicleProps.plate = testplate
            getPlate = false
        end
    end
    local vehiclePropsjson = json.encode(vehicleProps)
    if car then
        car = false 
        TriggerClientEvent('QBCore:Notify', source,  Lang:t('success.You_Won', {prize = Lang:t('general.car')}), 'success')
        TriggerClientEvent('qb-luckywheel:client:winCarEmail', source)
        exports.oxmysql:insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
            xPlayer.PlayerData.license,
            xPlayer.PlayerData.citizenid,
            Config.Vehicle,
            `Config.Vehicle`,
            vehiclePropsjson,
            vehicleProps.plate,
            'motelgarage',
            1
        })
    else
        --can ban here, would be a modder triggering event to get a free car
    end
end)
