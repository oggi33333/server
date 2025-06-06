ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local ambulanceOnDuty = {}
local emergencyCalls = {}
local deadPlayers = {}

-- Set duty status
RegisterServerEvent('esx_ambulance:setDuty')
AddEventHandler('esx_ambulance:setDuty', function(onDuty)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer.job.name == 'ambulance' then
		ambulanceOnDuty[source] = onDuty
		
		-- Log duty time
		if onDuty then
			MySQL.Async.execute('INSERT INTO ambulance_duty_log (medic_id, medic_name, duty_start) VALUES (@medic, @name, @time)', {
				['@medic'] = xPlayer.identifier,
				['@name'] = xPlayer.getName(),
				['@time'] = os.time()
			})
			TriggerClientEvent('esx:showNotification', source, '~g~Du bist jetzt im medizinischen Dienst!')
		else
			MySQL.Async.execute('UPDATE ambulance_duty_log SET duty_end = @time, total_time = (@time - UNIX_TIMESTAMP(duty_start)) WHERE medic_id = @medic AND duty_end IS NULL', {
				['@medic'] = xPlayer.identifier,
				['@time'] = os.time()
			})
			TriggerClientEvent('esx:showNotification', source, '~r~Du bist jetzt außer Dienst!')
		end
	end
end)

-- Heal Player
RegisterServerEvent('esx_ambulance:healPlayer')
AddEventHandler('esx_ambulance:healPlayer', function(targetId)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(targetId)
	
	if xPlayer.job.name == 'ambulance' and ambulanceOnDuty[source] then
		if xTarget then
			-- Log healing
			MySQL.Async.execute('INSERT INTO ambulance_treatments (medic_id, patient_id, treatment_type, treatment_time) VALUES (@medic, @patient, @type, @time)', {
				['@medic'] = xPlayer.identifier,
				['@patient'] = xTarget.identifier,
				['@type'] = 'heal',
				['@time'] = os.time()
			})
			
			-- Heal the player
			TriggerClientEvent('esx_basicneeds:healPlayer', targetId)
			TriggerClientEvent('esx_ambulance:healedPlayer', source, xTarget.getName())
			TriggerClientEvent('esx:showNotification', targetId, '~g~Du wurdest von einem Sanitäter geheilt!')
			
			-- Give experience/money to medic
			xPlayer.addMoney(math.random(200, 500))
		end
	end
end)

-- Revive Player
RegisterServerEvent('esx_ambulance:revivePlayer')
AddEventHandler('esx_ambulance:revivePlayer', function(targetId)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(targetId)
	
	if xPlayer.job.name == 'ambulance' and ambulanceOnDuty[source] then
		if xTarget then
			-- Log revive
			MySQL.Async.execute('INSERT INTO ambulance_treatments (medic_id, patient_id, treatment_type, treatment_time) VALUES (@medic, @patient, @type, @time)', {
				['@medic'] = xPlayer.identifier,
				['@patient'] = xTarget.identifier,
				['@type'] = 'revive',
				['@time'] = os.time()
			})
			
			-- Revive the player
			TriggerClientEvent('esx_ambulancejob:revive', targetId)
			TriggerClientEvent('esx_ambulance:revivedPlayer', source, xTarget.getName())
			TriggerClientEvent('esx:showNotification', targetId, '~g~Du wurdest von einem Sanitäter wiederbelebt!')
			
			-- Remove from dead players list
			deadPlayers[targetId] = nil
			
			-- Give reward to medic
			xPlayer.addMoney(math.random(500, 1000))
		end
	end
end)

-- Give Medical Item
RegisterServerEvent('esx_ambulance:giveMedicalItem')
AddEventHandler('esx_ambulance:giveMedicalItem', function(targetId, item, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(targetId)
	
	if xPlayer.job.name == 'ambulance' and ambulanceOnDuty[source] then
		if xTarget then
			-- Check if medic has the item
			local medicItem = xPlayer.getInventoryItem(item)
			
			if medicItem and medicItem.count >= amount then
				xPlayer.removeInventoryItem(item, amount)
				xTarget.addInventoryItem(item, amount)
				
				-- Log item given
				MySQL.Async.execute('INSERT INTO ambulance_items_given (medic_id, patient_id, item_name, quantity, given_time) VALUES (@medic, @patient, @item, @quantity, @time)', {
					['@medic'] = xPlayer.identifier,
					['@patient'] = xTarget.identifier,
					['@item'] = item,
					['@quantity'] = amount,
					['@time'] = os.time()
				})
				
				TriggerClientEvent('esx:showNotification', source, '~g~Du hast ' .. amount .. 'x ' .. item .. ' an ' .. xTarget.getName() .. ' gegeben!')
				TriggerClientEvent('esx_ambulance:receivedMedicalItem', targetId, item, amount)
			else
				TriggerClientEvent('esx:showNotification', source, '~r~Du hast nicht genug ' .. item .. '!')
			end
		end
	end
end)

-- Check Player Health
RegisterServerEvent('esx_ambulance:checkHealth')
AddEventHandler('esx_ambulance:checkHealth', function(targetId)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(targetId)
	
	if xPlayer.job.name == 'ambulance' and ambulanceOnDuty[source] then
		if xTarget then
			TriggerClientEvent('esx_ambulance:getPlayerHealth', targetId, source)
		end
	end
end)

-- Send to Hospital
RegisterServerEvent('esx_ambulance:sendToHospital')
AddEventHandler('esx_ambulance:sendToHospital', function(targetId)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(targetId)
	
	if xPlayer.job.name == 'ambulance' and ambulanceOnDuty[source] then
		if xTarget then
			-- Log hospital transport
			MySQL.Async.execute('INSERT INTO ambulance_transports (medic_id, patient_id, transport_time, destination) VALUES (@medic, @patient, @time, @destination)', {
				['@medic'] = xPlayer.identifier,
				['@patient'] = xTarget.identifier,
				['@time'] = os.time(),
				['@destination'] = 'Pillbox Hospital'
			})
			
			-- Teleport to hospital
			TriggerClientEvent('esx_ambulance:teleportToHospital', targetId)
			TriggerClientEvent('esx:showNotification', source, '~g~Du hast ' .. xTarget.getName() .. ' ins Krankenhaus gebracht!')
			TriggerClientEvent('esx:showNotification', targetId, '~g~Du wurdest ins Krankenhaus gebracht!')
			
			-- Give reward
			xPlayer.addMoney(math.random(300, 700))
		end
	end
end)

-- Request Medical Backup
RegisterServerEvent('esx_ambulance:requestBackup')
AddEventHandler('esx_ambulance:requestBackup', function(coords, streetName)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer.job.name == 'ambulance' then
		local xPlayers = ESX.GetPlayers()
		
		-- Log backup request
		MySQL.Async.execute('INSERT INTO ambulance_backup (medic_id, medic_name, location, street_name, coords_x, coords_y, coords_z, request_time) VALUES (@medic, @name, @location, @street, @x, @y, @z, @time)', {
			['@medic'] = xPlayer.identifier,
			['@name'] = xPlayer.getName(),
			['@location'] = streetName,
			['@street'] = streetName,
			['@x'] = coords.x,
			['@y'] = coords.y,
			['@z'] = coords.z,
			['@time'] = os.time()
		})
		
		for i=1, #xPlayers do
			local xTarget = ESX.GetPlayerFromId(xPlayers[i])
			
			if xTarget.job.name == 'ambulance' and xPlayers[i] ~= source then
				TriggerClientEvent('esx_ambulance:backupRequest', xPlayers[i], coords, streetName, xPlayer.getName())
			end
		end
	end
end)

-- Player Death System
RegisterServerEvent('esx_ambulance:playerDied')
AddEventHandler('esx_ambulance:playerDied', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	
	deadPlayers[source] = {
		identifier = xPlayer.identifier,
		name = xPlayer.getName(),
		deathTime = os.time()
	}
	
	-- Log death
	MySQL.Async.execute('INSERT INTO ambulance_deaths (player_id, player_name, death_time, location) VALUES (@player, @name, @time, @location)', {
		['@player'] = xPlayer.identifier,
		['@name'] = xPlayer.getName(),
		['@time'] = os.time(),
		['@location'] = 'Unknown' -- Can be enhanced with coords
	})
	
	-- Notify all ambulance workers
	local xPlayers = ESX.GetPlayers()
	for i=1, #xPlayers do
		local xTarget = ESX.GetPlayerFromId(xPlayers[i])
		if xTarget.job.name == 'ambulance' then
			TriggerClientEvent('esx:showNotification', xPlayers[i], '~r~NOTFALL: ~w~' .. xPlayer.getName() .. ' benötigt medizinische Hilfe!')
		end
	end
end)

RegisterServerEvent('esx_ambulance:playerRevived')
AddEventHandler('esx_ambulance:playerRevived', function()
	deadPlayers[source] = nil
end)

-- Emergency Calls
RegisterServerEvent('esx_ambulance:createEmergencyCall')
AddEventHandler('esx_ambulance:createEmergencyCall', function(message, coords)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	local callId = #emergencyCalls + 1
	emergencyCalls[callId] = {
		id = callId,
		caller = xPlayer.getName(),
		message = message,
		coords = coords,
		time = os.time(),
		responded = false
	}
	
	-- Notify all ambulance workers
	local xPlayers = ESX.GetPlayers()
	for i=1, #xPlayers do
		local xTarget = ESX.GetPlayerFromId(xPlayers[i])
		if xTarget.job.name == 'ambulance' then
			TriggerClientEvent('esx_ambulance:emergencyCall', xPlayers[i], emergencyCalls[callId])
		end
	end
end)

RegisterServerEvent('esx_ambulance:getEmergencyCalls')
AddEventHandler('esx_ambulance:getEmergencyCalls', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer.job.name == 'ambulance' then
		TriggerClientEvent('esx_ambulance:sendEmergencyCalls', source, emergencyCalls)
	end
end)

-- Clean up on disconnect
AddEventHandler('playerDropped', function()
	ambulanceOnDuty[source] = nil
	deadPlayers[source] = nil
end)

-- ESX Callbacks
ESX.RegisterServerCallback('esx_ambulance:getMedics', function(source, cb)
	local medics = {}
	local xPlayers = ESX.GetPlayers()
	
	for i=1, #xPlayers do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		
		if xPlayer.job.name == 'ambulance' then
			table.insert(medics, {
				id = xPlayers[i],
				name = xPlayer.getName(),
				grade = xPlayer.job.grade_name,
				onDuty = ambulanceOnDuty[xPlayers[i]] or false
			})
		end
	end
	
	cb(medics)
end)

ESX.RegisterServerCallback('esx_ambulance:getDeadPlayers', function(source, cb)
	cb(deadPlayers)
end)