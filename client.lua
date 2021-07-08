vRPin = {}
Tunnel.bindInterface("adobe_showroom",vRPin)
vRPserver = Tunnel.getInterface("vRP","adobe_showroom")
server = Tunnel.getInterface("adobe_showroom","adobe_showroom")
vRP = Proxy.getInterface("vRP")

local nowx, nowy, nowz, nowcam, nowveh

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        for i=1, #Config.Showroom do
            local v1 = vector3(Config.Showroom[i].x, Config.Showroom[i].y+0.1, Config.Showroom[i].z)
            DrawMarker(1, Config.Showroom[i].x, Config.Showroom[i].y+0.1, Config.Showroom[i].z-1, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 2.0, 2.0, 0.3, 0, 132, 255, 140, false, false, 10, false, false, false, false)
            if Vdist2(GetEntityCoords(PlayerPedId(), false), v1) < 3 then
                DisplayHelpText("~INPUT_PICKUP~ 키를 눌러 ~g~차량상점~w~ 을 엽니다.")
                if IsControlJustPressed(1, 38) then
                    open('showroom')
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        for i=1, #Config.Garage do
            local v1 = vector3(Config.Garage[i].x, Config.Garage[i].y+0.1, Config.Garage[i].z)
            DrawMarker(1, Config.Garage[i].x, Config.Garage[i].y+0.1, Config.Garage[i].z-1, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 2.0, 2.0, 0.3, 0, 132, 255, 140, false, false, 10, false, false, false, false)
            if Vdist2(GetEntityCoords(PlayerPedId(), false), v1) < 3 then
                DisplayHelpText("~INPUT_PICKUP~ 키를 눌러 ~g~차고~w~ 를 엽니다.")
                if IsControlJustPressed(1, 38) then
                    garagemenu()
                end
            end
        end
    end
end)

function open(type)
    server.requestVehicleTable({type})
    SetNuiFocus(true, true)
    SendNUIMessage(
        {
            action = "display"
        }
    )
    local playerPos = GetEntityCoords(GetPlayerPed(), true)
    nowx = playerPos.x
    nowy = playerPos.y
    nowz = playerPos.z
    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', 1)
    nowcam = cam
    SetEntityVisible(GetPlayerPed(), false, 0)
    SetGameplayCamRelativeRotation(100, 100, 100)
    SetEntityCoords(GetPlayerPed(), -35.28 ,-1095.3 ,28.12, true,false,false,true)
    SetEntityHeading(GetPlayerPed(), 50.0)
    SetCamCoord(cam, -49.62 ,-1097.3 ,26.12)
    SetCamRot(cam, 0.0, 0.0, -80.0, 1)
    RenderScriptCams(1, 1, 1000, 0, 0)
    Wait(500)
    FreezeEntityPosition(PlayerPedId(), false)
end
function garagemenu()
    SendNUIMessage(
        {
            action = "garagemenu"
        }
    )
    SetNuiFocus(true, true)
end

RegisterNUICallback("NUIFocusOff", function(data)
    if data.asdf == "showroom" or data.asdf == "garage" then
        closegarage()
    else
        SetNuiFocus(false, false)
    end
end)

RegisterNUICallback("SelectVehicle", function(data)
    SelectVehicle(data.code)
end)

RegisterNUICallback("opengarage", function(data)
    open('garage')
end)

RegisterNUICallback("back", function(data)
    server.back({})
    SetNuiFocus(false, false)
end)

RegisterNUICallback("BuyVehicle", function(data)
    server.buyvehicle({data.price, data.code, data.name})
    closegarage()
end)

RegisterNUICallback("TakeVehicle", function(data)
    server.takevehicle({data.code, data.name, data.maker})
    closegarage()
end)

RegisterNUICallback("Front", function(data)
    SetCamCoord(nowcam, -49.62 ,-1097.3 ,26.12)
    SetCamRot(nowcam, 0.0, 0.0, -80.0, 1)
    RenderScriptCams(1, 1, 1000, 0, 0)
end)

RegisterNUICallback("Back", function(data)
    SetCamCoord(nowcam, -40.91, -1096.91, 26.12)
    SetCamRot(nowcam, 0.0, 0.0, 100.0, 1)
    RenderScriptCams(1, 1, 1000, 0, 0)
end)

RegisterNUICallback("Pov", function(data)
    RenderScriptCams(0, 1, 1000, 0, 0)
    SetFollowVehicleCamViewMode(4)
end)



function SelectVehicle(code)
    if nowveh ~= nil then
        DeleteEntity(nowveh)
    end
    SetEntityVisible(GetPlayerPed(), false, 0)
    RequestModel(code)
    while not HasModelLoaded(code) do
        Wait(500)
    end
    local vehicle = CreateVehicle(code, -45.28 ,-1097.3 ,26.12, GetEntityHeading(GetPlayerPed()), false, false)
    SetEntityVisible(GetPlayerPed(), true, 0)
    SetPedIntoVehicle(GetPlayerPed(), vehicle, -1)
    nowveh = vehicle
    local maxspeed = GetVehicleEstimatedMaxSpeed(vehicle)
    local brake = GetVehicleMaxBraking(vehicle)
    local handling = GetVehicleMaxTraction(vehicle)
    local seats = GetVehicleMaxNumberOfPassengers(vehicle)
    local fuel = GetVehicleFuelLevel(vehicle)   
    SendNUIMessage(
    {
        action = "setvehiclespec",
        maxspeed = maxspeed,
        brake = brake,
        handling = handling,
        seats = seats,
        fuel = fuel
    })
    Wait(1000)
    TaskVehicleTempAction(GetPlayerPed(), vehicle, 31, 2000)
end

function closegarage()
    SendNUIMessage({
        action = "hide"
    })
    SetNuiFocus(false, false)
    DeleteEntity(nowveh)
    SetEntityCoords(GetPlayerPed(), nowx, nowy, nowz, true,false,false,true)
    RenderScriptCams(0, 1, 1000, 0, 0)
    DestroyCam(nowcam, false)
    FreezeEntityPosition(PlayerPedId(), false)
    SetEntityVisible(GetPlayerPed(), true, 0)
    SetFollowPedCamViewMode(1)
end

local vehicleclasses = {'소형','세단','쿠페','머슬카','스포츠 클래식','스포츠카','슈퍼카','오토바이','오프로드','공업용','상업용','밴','자전거','보트','헬리콥터','비행기','서비스','긴급','군용'}

function vRPin.setclientvehicles(_pvehicles, vehicles, index)
    local veh = {}
    local pvehicles = {}
    for k,v in pairs(_pvehicles) do
        pvehicles[string.lower(v.vehicle)] = true
    end

    for k,v in pairs(vehicles) do
        if k ~= "_config" and pvehicles[string.lower(k)] == nil then
            if IsModelInCdimage(k) then
                local class = GetVehicleClassFromName(k)
                local vehclass=vehicleclasses[class]
                table.insert(veh, {code=k, name=v[1], price=v[2], des=v[3], maker=Config.AllowedGroups[index], class=vehclass})
            end
        end
    end
    SendNUIMessage(
        {
            action = "setvehicle",
            place = "showroom",
            veh = veh
        }
    )
end

function vRPin.setclientgaragevehicles(_pvehicles, vehicles, index)
    local veh = {}
    local pvehicles = {}
    for k,v in pairs(_pvehicles) do
        pvehicles[string.lower(v.vehicle)] = true
    end

    for k,v in pairs(vehicles) do
        if k ~= "_config" and pvehicles[string.lower(k)] ~= nil then
            if IsModelInCdimage(k) then
                local class = GetVehicleClassFromName(k)
                local vehclass=vehicleclasses[class]
                table.insert(veh, {code=k, name=v[1], price=v[2], des=v[3], maker=Config.AllowedGroups[index], class=vehclass})
            end
        end
    end
    SendNUIMessage(
        {
            action = "setvehicle",
            place = "garage",
            veh = veh
        }
    )
end

function vRPin.closeshowroom()
    closegarage()
end

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end
