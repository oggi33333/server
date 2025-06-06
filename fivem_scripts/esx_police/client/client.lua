ESX = nil
local PlayerData = {}
local onDuty = false
local currentGrade = 0

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
	if PlayerData.job.name == 'police' then
		currentGrade = PlayerData.job.grade
	end
end)

-- Update job data
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
	if job.name == 'police' then
		currentGrade = job.grade
	end
end)

-- Police Menu
function OpenPoliceMenu()
	if PlayerData.job.name ~= 'police' then
		ESX.ShowNotification('~r~Du bist kein Polizist!')
		return
	end

	SendNUIMessage({
		type = "openPoliceMenu",
		playerData = PlayerData,
		onDuty = onDuty,
		grade = currentGrade
	})
	SetNuiFocus(true, true)
end

-- Toggle Duty
function ToggleDuty()
	onDuty = not onDuty
	
	if onDuty then
		ESX.ShowNotification('~g~Du bist jetzt im Dienst!')
		TriggerServerEvent('esx_police:setDuty', true)
	else
		ESX.ShowNotification('~r~Du bist jetzt außer Dienst!')
		TriggerServerEvent('esx_police:setDuty', false)
	end
	
	SendNUIMessage({
		type = "updateDuty",
		onDuty = onDuty
	})
end

-- Vehicle Actions
function SpawnPoliceVehicle(model)
	if not onDuty then
		ESX.ShowNotification('~r~Du musst im Dienst sein!')
		return
	end

	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	
	ESX.Game.SpawnVehicle(model, coords, 90.0, function(vehicle)
		SetVehicleNumberPlateText(vehicle, 'POLICE')
		SetVehicleLivery(vehicle, 0)
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		ESX.ShowNotification('~g~Polizeifahrzeug gespawnt!')
	end)
end

-- Arrest Player
function ArrestPlayer()
	local player, distance = ESX.Game.GetClosestPlayer()
	
	if distance ~= -1 and distance <= 3.0 then
		local targetId = GetPlayerServerId(player)
		TriggerServerEvent('esx_police:arrestPlayer', targetId)
	else
		ESX.ShowNotification('~r~Kein Spieler in der Nähe!')
	end
end

-- Fine Player
function FinePlayer(amount, reason)
	local player, distance = ESX.Game.GetClosestPlayer()
	
	if distance ~= -1 and distance <= 3.0 then
		local targetId = GetPlayerServerId(player)
		TriggerServerEvent('esx_police:finePlayer', targetId, amount, reason)
	else
		ESX.ShowNotification('~r~Kein Spieler in der Nähe!')
	end
end

-- Search Player
function SearchPlayer()
	local player, distance = ESX.Game.GetClosestPlayer()
	
	if distance ~= -1 and distance <= 3.0 then
		local targetId = GetPlayerServerId(player)
		TriggerServerEvent('esx_police:searchPlayer', targetId)
	else
		ESX.ShowNotification('~r~Kein Spieler in der Nähe!')
	end
end

-- Request Backup
function RequestBackup()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
	
	TriggerServerEvent('esx_police:requestBackup', coords, streetName)
end

-- NUI Callbacks
RegisterNUICallback('closeMenu', function(data, cb)
	SetNuiFocus(false, false)
	cb('ok')
end)

RegisterNUICallback('toggleDuty', function(data, cb)
	ToggleDuty()
	cb('ok')
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
	SpawnPoliceVehicle(data.model)
	cb('ok')
end)

RegisterNUICallback('arrestPlayer', function(data, cb)
	ArrestPlayer()
	cb('ok')
end)

RegisterNUICallback('finePlayer', function(data, cb)
	FinePlayer(data.amount, data.reason)
	cb('ok')
end)

RegisterNUICallback('searchPlayer', function(data, cb)
	SearchPlayer()
	cb('ok')
end)

RegisterNUICallback('requestBackup', function(data, cb)
	RequestBackup()
	cb('ok')
end)

-- Key Bindings
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		
		if IsControlJustReleased(0, 166) then -- F5
			if PlayerData.job and PlayerData.job.name == 'police' then
				OpenPoliceMenu()
			end
		end
	end
end)

-- Receive Server Events
RegisterNetEvent('esx_police:arrestedPlayer')
AddEventHandler('esx_police:arrestedPlayer', function(targetName)
	ESX.ShowNotification('~g~Du hast ' .. targetName .. ' verhaftet!')
end)

RegisterNetEvent('esx_police:finedPlayer')
AddEventHandler('esx_police:finedPlayer', function(targetName, amount)
	ESX.ShowNotification('~g~Du hast ' .. targetName .. ' $' .. amount .. ' Strafe gegeben!')
end)

RegisterNetEvent('esx_police:backupRequest')
AddEventHandler('esx_police:backupRequest', function(coords, streetName, requesterName)
	ESX.ShowNotification('~r~BACKUP ANGEFORDERT~n~~w~Von: ' .. requesterName .. '~n~Ort: ' .. streetName)
	SetNewWaypoint(coords.x, coords.y)
end)