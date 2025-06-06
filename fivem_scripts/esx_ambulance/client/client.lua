ESX = nil
local PlayerData = {}
local onDuty = false
local currentGrade = 0
local isReviving = false
local isHealing = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
	if PlayerData.job.name == 'ambulance' then
		currentGrade = PlayerData.job.grade
	end
end)

-- Update job data
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
	if job.name == 'ambulance' then
		currentGrade = job.grade
	end
end)

-- Ambulance Menu
function OpenAmbulanceMenu()
	if PlayerData.job.name ~= 'ambulance' then
		ESX.ShowNotification('~r~Du bist kein Sanitäter!')
		return
	end

	SendNUIMessage({
		type = "openAmbulanceMenu",
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
		ESX.ShowNotification('~g~Du bist jetzt im medizinischen Dienst!')
		TriggerServerEvent('esx_ambulance:setDuty', true)
	else
		ESX.ShowNotification('~r~Du bist jetzt außer Dienst!')
		TriggerServerEvent('esx_ambulance:setDuty', false)
	end
	
	SendNUIMessage({
		type = "updateDuty",
		onDuty = onDuty
	})
end

-- Vehicle Actions
function SpawnAmbulanceVehicle(model)
	if not onDuty then
		ESX.ShowNotification('~r~Du musst im Dienst sein!')
		return
	end

	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	
	ESX.Game.SpawnVehicle(model, coords, 90.0, function(vehicle)
		SetVehicleNumberPlateText(vehicle, 'MEDIC')
		SetVehicleLivery(vehicle, 0)
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		ESX.ShowNotification('~g~Rettungsfahrzeug gespawnt!')
	end)
end

-- Heal Player
function HealPlayer()
	if isHealing then return end
	
	local player, distance = ESX.Game.GetClosestPlayer()
	
	if distance ~= -1 and distance <= 3.0 then
		local targetId = GetPlayerServerId(player)
		isHealing = true
		
		-- Animation
		local playerPed = PlayerPedId()
		RequestAnimDict('mini@cpr@char_a@cpr_str')
		while not HasAnimDictLoaded('mini@cpr@char_a@cpr_str') do
			Wait(10)
		end
		
		TaskPlayAnim(playerPed, 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest', 8.0, 8.0, 5000, 1, 0, false, false, false)
		
		ESX.ShowNotification('~g~Behandle Patienten...')
		
		Citizen.Wait(5000)
		
		TriggerServerEvent('esx_ambulance:healPlayer', targetId)
		isHealing = false
		ClearPedTasks(playerPed)
	else
		ESX.ShowNotification('~r~Kein Patient in der Nähe!')
	end
end

-- Revive Player
function RevivePlayer()
	if isReviving then return end
	
	local player, distance = ESX.Game.GetClosestPlayer()
	
	if distance ~= -1 and distance <= 3.0 then
		local targetId = GetPlayerServerId(player)
		isReviving = true
		
		-- Animation
		local playerPed = PlayerPedId()
		RequestAnimDict('mini@cpr@char_a@cpr_str')
		while not HasAnimDictLoaded('mini@cpr@char_a@cpr_str') do
			Wait(10)
		end
		
		TaskPlayAnim(playerPed, 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest', 8.0, 8.0, 15000, 1, 0, false, false, false)
		
		ESX.ShowNotification('~g~Wiederbelebe Patienten...')
		
		-- Progress bar simulation
		for i = 1, 15 do
			Citizen.Wait(1000)
			ESX.ShowNotification('~g~Wiederbelebung: ' .. math.floor((i/15)*100) .. '%')
		end
		
		TriggerServerEvent('esx_ambulance:revivePlayer', targetId)
		isReviving = false
		ClearPedTasks(playerPed)
	else
		ESX.ShowNotification('~r~Kein Patient in der Nähe!')
	end
end

-- Give Medical Item
function GiveMedicalItem(item, amount)
	local player, distance = ESX.Game.GetClosestPlayer()
	
	if distance ~= -1 and distance <= 3.0 then
		local targetId = GetPlayerServerId(player)
		TriggerServerEvent('esx_ambulance:giveMedicalItem', targetId, item, amount)
	else
		ESX.ShowNotification('~r~Kein Patient in der Nähe!')
	end
end

-- Check Player Health
function CheckPlayerHealth()
	local player, distance = ESX.Game.GetClosestPlayer()
	
	if distance ~= -1 and distance <= 3.0 then
		local targetId = GetPlayerServerId(player)
		TriggerServerEvent('esx_ambulance:checkHealth', targetId)
	else
		ESX.ShowNotification('~r~Kein Patient in der Nähe!')
	end
end

-- Respond to Emergency Call
function RespondToCall()
	TriggerServerEvent('esx_ambulance:getEmergencyCalls')
end

-- Put in Ambulance
function PutInAmbulance()
	local player, distance = ESX.Game.GetClosestPlayer()
	
	if distance ~= -1 and distance <= 3.0 then
		local targetPed = GetPlayerPed(player)
		local vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 10.0, 0, 71)
		
		if DoesEntityExist(vehicle) then
			local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
			
			for i = maxSeats - 1, 0, -1 do
				if IsVehicleSeatFree(vehicle, i) then
					TaskWarpPedIntoVehicle(targetPed, vehicle, i)
					ESX.ShowNotification('~g~Patient ins Fahrzeug gebracht!')
					return
				end
			end
			ESX.ShowNotification('~r~Keine freien Plätze im Fahrzeug!')
		else
			ESX.ShowNotification('~r~Kein Fahrzeug in der Nähe!')
		end
	else
		ESX.ShowNotification('~r~Kein Patient in der Nähe!')
	end
end

-- Hospital Functions
function SendToHospital()
	local player, distance = ESX.Game.GetClosestPlayer()
	
	if distance ~= -1 and distance <= 3.0 then
		local targetId = GetPlayerServerId(player)
		TriggerServerEvent('esx_ambulance:sendToHospital', targetId)
	else
		ESX.ShowNotification('~r~Kein Patient in der Nähe!')
	end
end

-- Request Medical Backup
function RequestMedicalBackup()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
	
	TriggerServerEvent('esx_ambulance:requestBackup', coords, streetName)
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
	SpawnAmbulanceVehicle(data.model)
	cb('ok')
end)

RegisterNUICallback('healPlayer', function(data, cb)
	HealPlayer()
	cb('ok')
end)

RegisterNUICallback('revivePlayer', function(data, cb)
	RevivePlayer()
	cb('ok')
end)

RegisterNUICallback('giveMedicalItem', function(data, cb)
	GiveMedicalItem(data.item, data.amount)
	cb('ok')
end)

RegisterNUICallback('checkHealth', function(data, cb)
	CheckPlayerHealth()
	cb('ok')
end)

RegisterNUICallback('putInAmbulance', function(data, cb)
	PutInAmbulance()
	cb('ok')
end)

RegisterNUICallback('sendToHospital', function(data, cb)
	SendToHospital()
	cb('ok')
end)

RegisterNUICallback('requestBackup', function(data, cb)
	RequestMedicalBackup()
	cb('ok')
end)

RegisterNUICallback('respondToCall', function(data, cb)
	RespondToCall()
	cb('ok')
end)

-- Key Bindings
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		
		if IsControlJustReleased(0, 166) then -- F5
			if PlayerData.job and PlayerData.job.name == 'ambulance' then
				OpenAmbulanceMenu()
			end
		end
	end
end)

-- Death System
local isDead = false
local deathTime = 0

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		
		local playerPed = PlayerPedId()
		
		if IsEntityDead(playerPed) and not isDead then
			isDead = true
			deathTime = GetGameTimer()
			TriggerServerEvent('esx_ambulance:playerDied')
		elseif not IsEntityDead(playerPed) and isDead then
			isDead = false
			TriggerServerEvent('esx_ambulance:playerRevived')
		end
	end
end)

-- Receive Server Events
RegisterNetEvent('esx_ambulance:healedPlayer')
AddEventHandler('esx_ambulance:healedPlayer', function(targetName)
	ESX.ShowNotification('~g~Du hast ' .. targetName .. ' geheilt!')
end)

RegisterNetEvent('esx_ambulance:revivedPlayer')
AddEventHandler('esx_ambulance:revivedPlayer', function(targetName)
	ESX.ShowNotification('~g~Du hast ' .. targetName .. ' wiederbelebt!')
end)

RegisterNetEvent('esx_ambulance:receivedMedicalItem')
AddEventHandler('esx_ambulance:receivedMedicalItem', function(itemName, amount)
	ESX.ShowNotification('~g~Du hast ' .. amount .. 'x ' .. itemName .. ' erhalten!')
end)

RegisterNetEvent('esx_ambulance:backupRequest')
AddEventHandler('esx_ambulance:backupRequest', function(coords, streetName, requesterName)
	ESX.ShowNotification('~r~MEDIZINISCHER NOTFALL~n~~w~Von: ' .. requesterName .. '~n~Ort: ' .. streetName)
	SetNewWaypoint(coords.x, coords.y)
end)

RegisterNetEvent('esx_ambulance:emergencyCall')
AddEventHandler('esx_ambulance:emergencyCall', function(callData)
	ESX.ShowNotification('~r~NOTRUF: ~w~' .. callData.message .. '~n~Ort: ' .. callData.location)
	SetNewWaypoint(callData.coords.x, callData.coords.y)
end)

RegisterNetEvent('esx_ambulance:healthStatus')
AddEventHandler('esx_ambulance:healthStatus', function(targetName, health, armor)
	ESX.ShowNotification('~g~' .. targetName .. '~n~Gesundheit: ' .. health .. '%~n~Panzerung: ' .. armor .. '%')
end)