-----------------------
----   Variables   ----
-----------------------
local QBCore = exports['qb-core']:GetCoreObject()
local CasinoInteriorID = GetInteriorAtCoords(943.0232, 35.4403, 71.8337)

local videoWallRenderTarget = nil
local pedestalVehicle = nil
local pedestal = nil
local luckywheel = nil

local inCasino = false
local showBigWin = false
local isRolling = false

-----------------------
----   Threads     ----
-----------------------

-- Inside/Outside Casino state management without polyzone =D
CreateThread(function()
    while true do
        local playerInterior = GetInteriorFromEntity(PlayerPedId())
        if inCasino == false and playerInterior == CasinoInteriorID then
            inCasino = true
            startCasinoThreads()
        elseif inCasino == true and playerInterior ~= CasinoInteriorID then
            inCasino = false
        end
        Wait(1000)
    end
end)

-- Interaction
CreateThread(function()
    if Config.UseThirdEyeInteraction then
        exports['qb-target']:AddBoxZone("CasinoLuckyWheel", vector3(949.6, 44.88, 71.64), 2.8, 0.2, {
            name = "CasinoLuckyWheel",
            heading = 58.0,
            debugPoly = false,
            minZ=70.84,
            maxZ=73.44
            }, {
                options = {
                    {
                        type = "client",
                        event = "qb-luckywheel:spinwheel",
                        icon = "fas fa-redo",
                        label = Lang:t('general.Spin_Wheel', {wheel_amount = Config.Amount}),
                    },
                },
                distance = 2.5
        })
    else
        while true do
            local sleep = 500
            local coords = GetEntityCoords(PlayerPedId())
            if #(coords - vector3(Config.WheelPos.x, Config.WheelPos.y, Config.WheelPos.z)) < 1.5 and not isRolling then
                sleep = 5
                QBCore.Functions.DrawText3D(Config.WheelPos.x, Config.WheelPos.y, Config.WheelPos.z + 1, '[~g~E~w~]'..Lang:t('general.Spin_Wheel', {wheel_amount = Config.Amount}))
                if IsControlJustReleased(0, 38) then
                    doRoll()
                end
            end
            Wait(sleep)
        end
    end
end)

-----------------------
---- Client Events ----
-----------------------

RegisterNetEvent('qb-luckywheel:client:doRoll', function(_priceIndex)
    isRolling = true
    SetEntityRotation(luckywheel, 0.0, 0.0, 0.0, 1, true)
    CreateThread(function()
        local speedIntCnt = 1
        local rollspeed = 1.0
        local _winAngle = (_priceIndex - 1) * 18
        local _rollAngle = _winAngle + (360 * 8)
        local _midLength = (_rollAngle / 2)
        local intCnt = 0
        while speedIntCnt > 0 do
            local retval = GetEntityRotation(luckywheel, 1)
            if _rollAngle > _midLength then
                speedIntCnt = speedIntCnt + 1
            else
                speedIntCnt = speedIntCnt - 1
                if speedIntCnt < 0 then
                    speedIntCnt = 0
                end
            end
            intCnt = intCnt + 1
            rollspeed = speedIntCnt / 10
            local _y = retval.y - rollspeed
            _rollAngle = _rollAngle - rollspeed
            SetEntityRotation(luckywheel, 0.0, _y, -30.9754, 2, true)
            Wait(0)
        end
        showBigWin = true
    end)
end)

RegisterNetEvent('qb-luckywheel:client:rollFinished', function()
    isRolling = false
end)

RegisterNetEvent('qb-luckywheel:spinwheel', function()
    doRoll()
end)

-----------------------
----   Functions   ----
-----------------------

function startCasinoThreads()
    -- Screen Management 
    CreateThread(function()
        local lastUpdatedTvChannel = 0
        RequestStreamedTextureDict('Prop_Screen_Vinewood')

        while not HasStreamedTextureDictLoaded('Prop_Screen_Vinewood') do
            Wait(100)
        end
    
        RegisterNamedRendertarget('casinoscreen_01')
        LinkNamedRendertarget(`vw_vwint01_video_overlay`)
        videoWallRenderTarget = GetNamedRendertargetRenderId('casinoscreen_01')

        while inCasino do
            if videoWallRenderTarget then
                local currentTime = GetGameTimer()
                if showBigWin then
                    setVideoWallTvChannelWin()
                    lastUpdatedTvChannel = GetGameTimer() - 33666
                    showBigWin           = false
                else
                    if (currentTime - lastUpdatedTvChannel) >= 42666 then
                        setVideoWallTvChannel(Config.VideoType)
                        lastUpdatedTvChannel = currentTime
                    end
                end

                SetTextRenderId(videoWallRenderTarget)
                SetScriptGfxDrawOrder(4)
                SetScriptGfxDrawBehindPausemenu(true)
                DrawInteractiveSprite('Prop_Screen_Vinewood', 'BG_Wall_Colour_4x4', 0.25, 0.5, 0.5, 1.0, 0.0, 255, 255, 255, 255)
                DrawTvChannel(0.5, 0.5, 1.0, 1.0, 0.0, 255, 255, 255, 255)
                SetTextRenderId(GetDefaultScriptRendertargetRenderId())
            end
            Wait(0)
        end

        ReleaseNamedRendertarget('casinoscreen_01')
        videoWallRenderTarget = nil
        showBigWin            = false

    end)

    -- Vehicle/Pedestal
    CreateThread(function() 
        while inCasino do
            if DoesEntityExist(pedestalVehicle) then
                local vehHeading = GetEntityHeading(pedestalVehicle)
                local newVehHeading = vehHeading - 0.1
                SetEntityHeading(pedestalVehicle, newVehHeading)
            elseif Config.Vehicle ~= 'none' then
                RequestModel(Config.Vehicle)
                while not HasModelLoaded(Config.Vehicle) do
                    Wait(0)
                end
        
                local vehicle = CreateVehicle(Config.Vehicle, Config.VehPos.x, Config.VehPos.y, Config.VehPos.z, 0.0, false, false)
                SetModelAsNoLongerNeeded(Config.Vehicle)
                SetVehRadioStation(vehicle, 'OFF')

                Wait(1000)
                SetVehicleOnGroundProperly(vehicle)
                FreezeEntityPosition(vehicle, true)
                
                pedestalVehicle = vehicle
            end
    
            if DoesEntityExist(pedestal) and DoesEntityExist(pedestalVehicle) then
                local pedestalHeading = GetEntityHeading(pedestal)
                local newPedestalHeading = pedestalHeading - 0.1
                SetEntityHeading(pedestal, newPedestalHeading)
            else
                local pedCoords = GetEntityCoords(PlayerPedId())
                pedestal = GetClosestObjectOfType(pedCoords, 25.0, GetHashKey("vw_prop_vw_casino_podium_01a"), false)
            end

            Wait(5)
        end

        if pedestalVehicle ~= nil and DoesEntityExist(pedestalVehicle) then
            DeleteEntity(pedestalVehicle)
            pedestalVehicle = nil
        end
    end)

    -- Wheel
    CreateThread(function() 
        if not DoesEntityExist(luckywheel) then
            luckywheel = GetClosestObjectOfType(Config.WheelPos, 10.0, Config.WheelModel, false)
            if luckywheel == 0 then
                RequestModel(Config.WheelModel)
                while not HasModelLoaded(Config.WheelModel) do
                    Wait(0)
                end
                luckywheel = CreateObject(Config.WheelModel, Config.WheelPos.x, Config.WheelPos.y, Config.WheelPos.z, false, false, true)
                SetEntityHeading(luckywheel, 328.0)
                SetModelAsNoLongerNeeded(Config.WheelModel)
            end
        end
    end)
end

exports('setVideoWallTvChannel', setVideoWallTvChannel)
function setVideoWallTvChannel(videoType)
    SetTvChannelPlaylist(0, videoType, true)
    SetTvAudioFrontend(true)
    SetTvVolume(-100.0)
    SetTvChannel(0)
end

function setVideoWallTvChannelWin()
    SetTvChannelPlaylist(0, 'CASINO_WIN_PL', true)
    SetTvAudioFrontend(true)
    SetTvVolume(-100.0)
    SetTvChannel(-1)
    SetTvChannel(0)
end

function doRoll()
    if not isRolling then
        QBCore.Functions.TriggerCallback('qb-luckywheel:CheckCanSpin', function(canSpin, reason)
            print(reason)
            if reason == nil and canSpin then
                isRolling = true
                local playerPed = PlayerPedId()
                local _lib = 'anim_casino_a@amb@casino@games@lucky7wheel@female'
                if IsPedMale(playerPed) then
                    _lib = 'anim_casino_a@amb@casino@games@lucky7wheel@male'
                end
                local lib, anim = _lib, 'enter_right_to_baseidle'
                while (not HasAnimDictLoaded(lib)) do
                    RequestAnimDict(lib)
                    Wait(100)
                end
                local _movePos = vector3(948.32, 45.14, 71.64)
                TaskGoStraightToCoord(playerPed, _movePos.x, _movePos.y, _movePos.z, 1.0, -1, 312.2, 0.0)
                local _isMoved = false
                while not _isMoved do
                    local coords = GetEntityCoords(playerPed)
                    if coords.x >= (_movePos.x - 0.01) and coords.x <= (_movePos.x + 0.01) and coords.y >= (_movePos.y - 0.01) and coords.y <= (_movePos.y + 0.01) then
                        _isMoved = true
                    end
                    Wait(0)
                end
                TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
                while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                    Wait(0)
                    DisableAllControlActions(0)
                end
                TaskPlayAnim(playerPed, lib, 'enter_to_armraisedidle', 8.0, -8.0, -1, 0, 0, false, false, false)
                while IsEntityPlayingAnim(playerPed, lib, 'enter_to_armraisedidle', 3) do
                    Wait(0)
                    DisableAllControlActions(0)
                end
                TriggerServerEvent('qb-luckywheel:server:getLucky')
                TaskPlayAnim(playerPed, lib, 'armraisedidle_to_spinningidle_high', 8.0, -8.0, -1, 0, 0, false, false, false)
            elseif reason == 'chips' then
                    TriggerEvent('QBCore:Notify',Lang:t('error.need_chips', {Chipsamount = Config.Amount}), 'error')
            else
                TriggerEvent('QBCore:Notify', Lang:t('error.time'), 'error')
            end
        end)
    end
end

RegisterNetEvent('qb-luckywheel:client:winCar', function()
    local vehicleProps = QBCore.Functions.GetVehicleProperties(vehicle)
    TriggerServerEvent('qb-luckywheel:server:carRedeem', vehicleProps)
end)

RegisterNetEvent('qb-luckywheel:client:winCarEmail', function()
    local CID = QBCore.Functions.GetPlayer(src).PlayerData.citizenid
    TriggerServerEvent('qb-phone:server:sendNewMail', {
        sender =  Lang:t('general.sender'),
        subject = Lang:t('general.subject'),
        message = Lang:t('general.message'),
    })
end)

