local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRPin = {}
Tunnel.bindInterface("adobe_showroom",vRPin)
Proxy.addInterface("adobe_showroom",vRPin)
client = Tunnel.getInterface("adobe_showroom","adobe_showroom")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","adobe_showroom")

local cfg = module("cfg/garages")
local vehicle_groups = cfg.garage_types


function vRPin.requestVehicleTable(type)
    local _source = source
    local user_id = vRP.getUserId({_source})
    local veh = {}
    for i=1, #Config.AllowedGroups do
        local vehicles = vehicle_groups[Config.AllowedGroups[i]]
        if vehicles then
            MySQL.Async.fetchAll("SELECT vehicle FROM vrp_user_vehicles WHERE user_id = @user_id", {['@user_id']=user_id}, function(_pvehicles)
                if type == 'showroom' then
                    client.setclientvehicles(_source, {_pvehicles, vehicles, i})
                else
                    client.setclientgaragevehicles(_source, {_pvehicles, vehicles, i})
                end
            end)
        end
    end
end

function vRPin.buyvehicle(price, code, name)
    local _source = source
    local user_id = vRP.getUserId({_source})
    if vRP.tryPayment({user_id,price}) then
        MySQL.Async.execute('INSERT IGNORE INTO vrp_user_vehicles(user_id,vehicle) VALUES(@user_id,@vehicle)',{['@user_id']=user_id, ['@vehicle']=code})
        vRPclient.notify(_source, {'~g~차량 '..name..'을(를) 성공적으로 구입하였습니다!'})
    else
        vRPclient.notify(_source, {'~r~돈이 부족합니다!'})
    end
end

function vRPin.takevehicle(code, name, maker)
    local _source = source
    local user_id = vRP.getUserId({_source})
    local vehicles = vehicle_groups[maker]
    local veh_type = vehicles._config.vtype or "default"
    vRPclient.spawnGarageVehicle(_source,{veh_type,code})
end

function vRPin.back()
    local _source = source
    local user_id = vRP.getUserId({_source})
    vRPclient.despawnGarageVehicle(_source,{'car',100})
end