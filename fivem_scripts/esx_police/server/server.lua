ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local policeOnDuty = {}

-- Set duty status
RegisterServerEvent('esx_police:setDuty')
AddEventHandler('esx_police:setDuty', function(onDuty)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer.job.name == 'police' then
		policeOnDuty[source] = onDuty
		
		if onDuty then
			TriggerClientEvent('esx:showNotification', source, '~g~Du bist jetzt im Dienst!')
		else
			TriggerClientEvent('esx:showNotification', source, '~r~Du bist jetzt außer Dienst!')
		end
	end
end)

-- Arrest Player
RegisterServerEvent('esx_police:arrestPlayer')
AddEventHandler('esx_police:arrestPlayer', function(targetId)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(targetId)
	
	if xPlayer.job.name == 'police' and policeOnDuty[source] then
		if xTarget then
			-- Add to database
			MySQL.Async.execute('INSERT INTO police_arrests (officer_id, suspect_id, arrest_time) VALUES (@officer, @suspect, @time)', {
				['@officer'] = xPlayer.identifier,
				['@suspect'] = xTarget.identifier,
				['@time'] = os.time()
			})
			
			-- Put in jail
			TriggerClientEvent('esx_jail:sendToJail', targetId, 300) -- 5 minutes
			
			TriggerClientEvent('esx_police:arrestedPlayer', source, xTarget.getName())
			TriggerClientEvent('esx:showNotification', targetId, '~r~Du wurdest von der Polizei verhaftet!')
			
			-- Log to discord/console
			print('[ESX_POLICE] ' .. xPlayer.getName() .. ' arrested ' .. xTarget.getName())
		end
	end
end)

-- Fine Player
RegisterServerEvent('esx_police:finePlayer')
AddEventHandler('esx_police:finePlayer', function(targetId, amount, reason)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(targetId)
	
	if xPlayer.job.name == 'police' and policeOnDuty[source] then
		if xTarget then
			amount = tonumber(amount)
			
			if xTarget.getMoney() >= amount then
				xTarget.removeMoney(amount)
				
				-- Add fine to database
				MySQL.Async.execute('INSERT INTO police_fines (officer_id, suspect_id, amount, reason, fine_time) VALUES (@officer, @suspect, @amount, @reason, @time)', {
					['@officer'] = xPlayer.identifier,
					['@suspect'] = xTarget.identifier,
					['@amount'] = amount,
					['@reason'] = reason,
					['@time'] = os.time()
				})
				
				TriggerClientEvent('esx_police:finedPlayer', source, xTarget.getName(), amount)
				TriggerClientEvent('esx:showNotification', targetId, '~r~Du hast eine Strafe von $' .. amount .. ' erhalten!~n~Grund: ' .. reason)
			else
				TriggerClientEvent('esx:showNotification', source, '~r~Der Spieler hat nicht genug Geld!')
			end
		end
	end
end)

-- Search Player
RegisterServerEvent('esx_police:searchPlayer')
AddEventHandler('esx_police:searchPlayer', function(targetId)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(targetId)
	
	if xPlayer.job.name == 'police' and policeOnDuty[source] then
		if xTarget then
			local inventory = xTarget.getInventory()
			local weapons = xTarget.getLoadout()
			local money = xTarget.getMoney()
			
			local searchResults = {
				money = money,
				inventory = {},
				weapons = {}
			}
			
			for i=1, #inventory do
				if inventory[i].count > 0 then
					table.insert(searchResults.inventory, {
						name = inventory[i].name,
						label = inventory[i].label,
						count = inventory[i].count
					})
				end
			end
			
			for i=1, #weapons do
				table.insert(searchResults.weapons, {
					name = weapons[i].name,
					label = weapons[i].label,
					ammo = weapons[i].ammo
				})
			end
			
			TriggerClientEvent('esx_police:searchResults', source, xTarget.getName(), searchResults)
		end
	end
end)

-- Request Backup
RegisterServerEvent('esx_police:requestBackup')
AddEventHandler('esx_police:requestBackup', function(coords, streetName)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer.job.name == 'police' then
		local xPlayers = ESX.GetPlayers()
		
		for i=1, #xPlayers do
			local xTarget = ESX.GetPlayerFromId(xPlayers[i])
			
			if xTarget.job.name == 'police' and xPlayers[i] ~= source then
				TriggerClientEvent('esx_police:backupRequest', xPlayers[i], coords, streetName, xPlayer.getName())
			end
		end
	end
end)

-- Clean up on disconnect
AddEventHandler('playerDropped', function()
	policeOnDuty[source] = nil
end)

-- ESX Callbacks
ESX.RegisterServerCallback('esx_police:getOfficers', function(source, cb)
	local officers = {}
	local xPlayers = ESX.GetPlayers()
	
	for i=1, #xPlayers do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		
		if xPlayer.job.name == 'police' then
			table.insert(officers, {
				id = xPlayers[i],
				name = xPlayer.getName(),
				grade = xPlayer.job.grade_name,
				onDuty = policeOnDuty[xPlayers[i]] or false
			})
		end
	end
	
	cb(officers)
end)