ESX                           = nil
local color = {r = 37, g = 175, b = 134, alpha = 255} -- Color of the text 
local font = 0 -- Font of the text
local time = 1000 -- Duration of the display of the text : 1000ms = 1sec
local timeAlways = true -- set it to true to keep display of the text forever
local nbrDisplaying = 0
local coordNumber = 0
local CoordArray = {}
CoordArray.X = {}
CoordArray.Y = {}
CoordArray.Z = {}
CoordArray.H = {}


Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)


RegisterCommand('sg', function(source, args)
  local cNo = tonumber(args[1])
  SetEntityCoords(GetPlayerPed(-1), CoordArray.X[cNo], CoordArray.Y[cNo], CoordArray.Z[cNo])
end)

RegisterCommand('coords', function(source, args)
    local coords = GetEntityCoords(GetPlayerPed(-1))
    local heading = GetEntityHeading(GetPlayerPed(-1))
    local offset = 0
    coordNumber = coordNumber + 1

    CoordArray.X[coordNumber] = coords.x
    CoordArray.Y[coordNumber] = coords.y
    CoordArray.Z[coordNumber] = coords.z + 1
    CoordArray.H[coordNumber] = heading

    TriggerServerEvent('tools:saveCoords', coords.x, coords.y, coords.z, heading)
    DisplayMe(GetPlayerFromServerId(source), coordNumber, offset)

  
end)
function DisplayMe(mePlayer, text, offset)
    local displaying = true
    Citizen.CreateThread(function()
        Wait(time)
        if not timeAlways then
          displaying = false
        end
    end)
    Citizen.CreateThread(function()
        nbrDisplaying = nbrDisplaying + 1
        local coords = GetEntityCoords(GetPlayerPed(mePlayer), false)
        while displaying do
            Wait(0)
            
            DrawText3D(coords['x'], coords['y'], coords['z']+offset, text)
        end
        nbrDisplaying = nbrDisplaying - 1
    end)
end


function DrawText3D(x,y,z, text)
  local onScreen,_x,_y=World3dToScreen2d(x,y,z)
  local px,py,pz=table.unpack(GetGameplayCamCoords())

  SetTextScale(0.40, 0.40)
  SetTextFont(4)
  SetTextProportional(1)
  SetTextColour(255, 255, 255, 215)
  SetTextEntry("STRING")
  SetTextCentre(1)
  AddTextComponentString(text)
  DrawText(_x,_y)
  local factor = (string.len(text)) / 370
  DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end
RegisterCommand('sethp', function(source, args)
  local ped = args[1]
  local hp = args[2]
  TriggerServerEvent('tools:setHp', ped, hp)
end)

RegisterNetEvent('tools:setHpClient')
AddEventHandler('tools:setHpClient', function(hp)
  local _hp = hp
  SetEntityHealth(GetPlayerPed(-1), tonumber(_hp))
  Citizen.Wait(100)
end)

