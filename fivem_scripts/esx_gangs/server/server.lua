ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local gangMembers = {}
local gangWars = {}
local territories = {}
local drugRuns = {}

-- Initialize gangs on resource start
Citizen.CreateThread(function()
	Wait(1000)
	LoadGangData()
	LoadTerritories()
end)

function LoadGangData()
	MySQL.Async.fetchAll('SELECT * FROM gang_members', {}, function(result)
		gangMembers = {}
		
		for i = 1, #result do
			local member = result[i]
			if not gangMembers[member.gang_name] then
				gangMembers[member.gang_name] = {}
			end
			
			gangMembers[member.gang_name][member.player_id] = {
				rank = member.rank,
				joined_date = member.joined_date
			}
		end
	end)
end

function LoadTerritories()
	MySQL.Async.fetchAll('SELECT * FROM gang_territories', {}, function(result)
		territories = result
		
		-- Broadcast to all players
		local xPlayers = ESX.GetPlayers()
		for i = 1, #xPlayers do
			TriggerClientEvent('esx_gangs:updateTerritories', xPlayers[i], territories)
		end
	end)
end

-- Get Player Gang
RegisterServerEvent('esx_gangs:getPlayerGang')
AddEventHandler('esx_gangs:getPlayerGang', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	
	MySQL.Async.fetchAll('SELECT * FROM gang_members WHERE player_id = @player', {
		['@player'] = xPlayer.identifier
	}, function(result)
		if result[1] then
			local gang = result[1].gang_name
			local rank = result[1].rank
			TriggerClientEvent('esx_gangs:setPlayerGang', source, gang, rank)
		else
			TriggerClientEvent('esx_gangs:setPlayerGang', source, nil, 0)
		end
	end)
end)

-- Gang Management
RegisterServerEvent('esx_gangs:invitePlayer')
AddEventHandler('esx_gangs:invitePlayer', function(targetId, gang)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(targetId)
	
	if xTarget then
		-- Check if player is already in a gang
		MySQL.Async.fetchAll('SELECT * FROM gang_members WHERE player_id = @player', {
			['@player'] = xTarget.identifier
		}, function(result)
			if result[1] then
				TriggerClientEvent('esx:showNotification', source, '~r~Spieler ist bereits in einer Gang!')
			else
				TriggerClientEvent('esx_gangs:gangInvite', targetId, gang, xPlayer.getName())
			end
		end)
	end
end)

RegisterServerEvent('esx_gangs:acceptInvite')
AddEventHandler('esx_gangs:acceptInvite', function(gang)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	-- Add player to gang with rank 1
	MySQL.Async.execute('INSERT INTO gang_members (player_id, player_name, gang_name, rank, joined_date) VALUES (@player, @name, @gang, @rank, @date)', {
		['@player'] = xPlayer.identifier,
		['@name'] = xPlayer.getName(),
		['@gang'] = gang,
		['@rank'] = 1,
		['@date'] = os.time()
	})
	
	TriggerClientEvent('esx_gangs:setPlayerGang', source, gang, 1)
	TriggerClientEvent('esx:showNotification', source, '~g~Du bist der Gang ' .. gang .. ' beigetreten!')
	
	LoadGangData()
end)

RegisterServerEvent('esx_gangs:declineInvite')
AddEventHandler('esx_gangs:declineInvite', function(gang)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('esx:showNotification', source, '~r~Gang-Einladung abgelehnt.')
end)

RegisterServerEvent('esx_gangs:kickPlayer')
AddEventHandler('esx_gangs:kickPlayer', function(targetId, gang)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(targetId)
	
	if xTarget then
		MySQL.Async.execute('DELETE FROM gang_members WHERE player_id = @player AND gang_name = @gang', {
			['@player'] = xTarget.identifier,
			['@gang'] = gang
		})
		
		TriggerClientEvent('esx_gangs:setPlayerGang', targetId, nil, 0)
		TriggerClientEvent('esx:showNotification', targetId, '~r~Du wurdest aus der Gang ' .. gang .. ' gekickt!')
		TriggerClientEvent('esx:showNotification', source, '~g~Spieler wurde aus der Gang gekickt!')
		
		LoadGangData()
	end
end)

RegisterServerEvent('esx_gangs:promotePlayer')
AddEventHandler('esx_gangs:promotePlayer', function(targetId, gang)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(targetId)
	
	if xTarget then
		MySQL.Async.execute('UPDATE gang_members SET rank = rank + 1 WHERE player_id = @player AND gang_name = @gang AND rank < 5', {
			['@player'] = xTarget.identifier,
			['@gang'] = gang
		})
		
		TriggerClientEvent('esx:showNotification', source, '~g~Spieler wurde befördert!')
		TriggerClientEvent('esx:showNotification', targetId, '~g~Du wurdest in der Gang befördert!')
		
		LoadGangData()
		TriggerServerEvent('esx_gangs:getPlayerGang', targetId)
	end
end)

RegisterServerEvent('esx_gangs:demotePlayer')
AddEventHandler('esx_gangs:demotePlayer', function(targetId, gang)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(targetId)
	
	if xTarget then
		MySQL.Async.execute('UPDATE gang_members SET rank = rank - 1 WHERE player_id = @player AND gang_name = @gang AND rank > 1', {
			['@player'] = xTarget.identifier,
			['@gang'] = gang
		})
		
		TriggerClientEvent('esx:showNotification', source, '~g~Spieler wurde degradiert!')
		TriggerClientEvent('esx:showNotification', targetId, '~r~Du wurdest in der Gang degradiert!')
		
		LoadGangData()
		TriggerServerEvent('esx_gangs:getPlayerGang', targetId)
	end
end)

-- Territory System
RegisterServerEvent('esx_gangs:attackTerritory')
AddEventHandler('esx_gangs:attackTerritory', function(territoryId, attackingGang)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	MySQL.Async.fetchAll('SELECT * FROM gang_territories WHERE id = @id', {
		['@id'] = territoryId
	}, function(result)
		if result[1] then
			local territory = result[1]
			
			if territory.owner_gang == attackingGang then
				TriggerClientEvent('esx:showNotification', source, '~r~Du kannst dein eigenes Territorium nicht angreifen!')
				return
			end
			
			-- Start territory attack
			MySQL.Async.execute('INSERT INTO gang_wars (territory_id, attacking_gang, defending_gang, war_start, status) VALUES (@territory, @attacking, @defending, @start, @status)', {
				['@territory'] = territoryId,
				['@attacking'] = attackingGang,
				['@defending'] = territory.owner_gang or 'None',
				['@start'] = os.time(),
				['@status'] = 'active'
			})
			
			-- Notify all gang members
			local xPlayers = ESX.GetPlayers()
			for i = 1, #xPlayers do
				TriggerClientEvent('esx_gangs:territoryAttacked', xPlayers[i], territory.name, attackingGang, territory.owner_gang or 'None')
			end
			
			TriggerClientEvent('esx:showNotification', source, '~g~Territorium-Angriff gestartet!')
			
			-- Territory battle logic (simplified)
			Citizen.CreateThread(function()
				Wait(300000) -- 5 minutes battle time
				
				-- Random outcome for now (can be enhanced with player participation)
				local success = math.random(1, 100) <= 60 -- 60% success rate
				
				if success then
					MySQL.Async.execute('UPDATE gang_territories SET owner_gang = @gang WHERE id = @id', {
						['@gang'] = attackingGang,
						['@id'] = territoryId
					})
					
					MySQL.Async.execute('UPDATE gang_wars SET status = @status, war_end = @end WHERE territory_id = @territory AND status = @active', {
						['@status'] = 'won',
						['@end'] = os.time(),
						['@territory'] = territoryId,
						['@active'] = 'active'
					})
					
					TriggerClientEvent('esx:showNotification', source, '~g~Territorium erfolgreich erobert!')
				else
					MySQL.Async.execute('UPDATE gang_wars SET status = @status, war_end = @end WHERE territory_id = @territory AND status = @active', {
						['@status'] = 'lost',
						['@end'] = os.time(),
						['@territory'] = territoryId,
						['@active'] = 'active'
					})
					
					TriggerClientEvent('esx:showNotification', source, '~r~Territorium-Angriff fehlgeschlagen!')
				end
				
				LoadTerritories()
			end)
		end
	end)
end)

-- Gang War System
RegisterServerEvent('esx_gangs:startGangWar')
AddEventHandler('esx_gangs:startGangWar', function(gang1, gang2)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	-- Log gang war
	MySQL.Async.execute('INSERT INTO gang_wars (attacking_gang, defending_gang, war_start, status, war_type) VALUES (@gang1, @gang2, @start, @status, @type)', {
		['@gang1'] = gang1,
		['@gang2'] = gang2,
		['@start'] = os.time(),
		['@status'] = 'active',
		['@type'] = 'gang_war'
	})
	
	-- Notify all players
	local xPlayers = ESX.GetPlayers()
	for i = 1, #xPlayers do
		TriggerClientEvent('esx_gangs:gangWarStarted', xPlayers[i], gang1, gang2)
	end
	
	TriggerClientEvent('esx:showNotification', source, '~g~Gang War gegen ' .. gang2 .. ' gestartet!')
end)

-- Drug Operations
RegisterServerEvent('esx_gangs:startDrugRun')
AddEventHandler('esx_gangs:startDrugRun', function(gang)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	-- Random drug run location
	local drugLocations = {
		{x = 1392.48, y = 3614.58, z = 34.89},
		{x = 2434.09, y = 4968.98, z = 42.35},
		{x = 1905.25, y = 4924.45, z = 48.88}
	}
	
	local randomLocation = drugLocations[math.random(1, #drugLocations)]
	
	drugRuns[source] = {
		gang = gang,
		location = randomLocation,
		started = os.time()
	}
	
	TriggerClientEvent('esx_gangs:drugRunStarted', source, randomLocation)
end)

RegisterServerEvent('esx_gangs:sellDrugs')
AddEventHandler('esx_gangs:sellDrugs', function(gang, coords)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	-- Check if player has drugs
	local weed = xPlayer.getInventoryItem('marijuana')
	local cocaine = xPlayer.getInventoryItem('cocaine')
	
	local totalEarnings = 0
	
	if weed and weed.count > 0 then
		local sellAmount = math.min(weed.count, 10)
		local price = math.random(150, 250) * sellAmount
		
		xPlayer.removeInventoryItem('marijuana', sellAmount)
		xPlayer.addMoney(price)
		totalEarnings = totalEarnings + price
	end
	
	if cocaine and cocaine.count > 0 then
		local sellAmount = math.min(cocaine.count, 5)
		local price = math.random(300, 500) * sellAmount
		
		xPlayer.removeInventoryItem('cocaine', sellAmount)
		xPlayer.addMoney(price)
		totalEarnings = totalEarnings + price
	end
	
	if totalEarnings > 0 then
		-- Add to gang bank (10% cut)
		local gangCut = math.floor(totalEarnings * 0.1)
		MySQL.Async.execute('UPDATE gangs SET bank_money = bank_money + @amount WHERE name = @gang', {
			['@amount'] = gangCut,
			['@gang'] = gang
		})
		
		TriggerClientEvent('esx:showNotification', source, '~g~Drogen verkauft für $' .. totalEarnings .. '! Gang erhält $' .. gangCut)
		
		-- Log drug sale
		MySQL.Async.execute('INSERT INTO gang_activities (gang_name, player_id, activity_type, amount, activity_time) VALUES (@gang, @player, @type, @amount, @time)', {
			['@gang'] = gang,
			['@player'] = xPlayer.identifier,
			['@type'] = 'drug_sale',
			['@amount'] = totalEarnings,
			['@time'] = os.time()
		})
	else
		TriggerClientEvent('esx:showNotification', source, '~r~Du hast keine Drogen zum Verkaufen!')
	end
end)

-- Weapon Operations
RegisterServerEvent('esx_gangs:buyWeapons')
AddEventHandler('esx_gangs:buyWeapons', function(gang, weaponType, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	local weaponPrices = {
		['pistol'] = 1500,
		['smg'] = 5000,
		['rifle'] = 12000
	}
	
	local weaponModels = {
		['pistol'] = 'WEAPON_PISTOL',
		['smg'] = 'WEAPON_SMG',
		['rifle'] = 'WEAPON_CARBINERIFLE'
	}
	
	local price = weaponPrices[weaponType] * amount
	
	if xPlayer.getMoney() >= price then
		xPlayer.removeMoney(price)
		
		for i = 1, amount do
			xPlayer.addWeapon(weaponModels[weaponType], 100)
		end
		
		TriggerClientEvent('esx:showNotification', source, '~g~' .. amount .. 'x ' .. weaponType .. ' gekauft für $' .. price)
		
		-- Log weapon purchase
		MySQL.Async.execute('INSERT INTO gang_activities (gang_name, player_id, activity_type, amount, activity_time) VALUES (@gang, @player, @type, @amount, @time)', {
			['@gang'] = gang,
			['@player'] = xPlayer.identifier,
			['@type'] = 'weapon_purchase',
			['@amount'] = price,
			['@time'] = os.time()
		})
	else
		TriggerClientEvent('esx:showNotification', source, '~r~Nicht genug Geld!')
	end
end)

-- Gang Bank
RegisterServerEvent('esx_gangs:depositMoney')
AddEventHandler('esx_gangs:depositMoney', function(gang, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer.getMoney() >= amount then
		xPlayer.removeMoney(amount)
		
		MySQL.Async.execute('UPDATE gangs SET bank_money = bank_money + @amount WHERE name = @gang', {
			['@amount'] = amount,
			['@gang'] = gang
		})
		
		TriggerClientEvent('esx:showNotification', source, '~g~$' .. amount .. ' in Gang-Bank eingezahlt!')
	else
		TriggerClientEvent('esx:showNotification', source, '~r~Nicht genug Geld!')
	end
end)

RegisterServerEvent('esx_gangs:withdrawMoney')
AddEventHandler('esx_gangs:withdrawMoney', function(gang, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	MySQL.Async.fetchAll('SELECT bank_money FROM gangs WHERE name = @gang', {
		['@gang'] = gang
	}, function(result)
		if result[1] and result[1].bank_money >= amount then
			MySQL.Async.execute('UPDATE gangs SET bank_money = bank_money - @amount WHERE name = @gang', {
				['@amount'] = amount,
				['@gang'] = gang
			})
			
			xPlayer.addMoney(amount)
			TriggerClientEvent('esx:showNotification', source, '~g~$' .. amount .. ' aus Gang-Bank abgehoben!')
		else
			TriggerClientEvent('esx:showNotification', source, '~r~Nicht genug Geld in der Gang-Bank!')
		end
	end)
end)

-- Vehicle System
RegisterServerEvent('esx_gangs:spawnGangVehicle')
AddEventHandler('esx_gangs:spawnGangVehicle', function(gang, model)
	local xPlayer = ESX.GetPlayerFromId(source)
	local playerPed = GetPlayerPed(source)
	local coords = GetEntityCoords(playerPed)
	
	-- Gang vehicle models
	local gangVehicles = {
		['vagos'] = {'tornado', 'tornado2', 'buccaneer', 'voodoo'},
		['ballas'] = {'emperor', 'emperor2', 'blade', 'buccaneer2'},
		['families'] = {'greenwood', 'glendale', 'manana', 'tornado3'}
	}
	
	if gangVehicles[gang] then
		for i = 1, #gangVehicles[gang] do
			if gangVehicles[gang][i] == model then
				TriggerClientEvent('esx_gangs:vehicleSpawned', source, model)
				return
			end
		end
	end
	
	TriggerClientEvent('esx:showNotification', source, '~r~Ungültiges Fahrzeug für deine Gang!')
end)

-- Territory Detection
RegisterServerEvent('esx_gangs:checkPlayerInTerritory')
AddEventHandler('esx_gangs:checkPlayerInTerritory', function(coords)
	for i = 1, #territories do
		local territory = territories[i]
		local distance = #(vector3(coords.x, coords.y, coords.z) - vector3(territory.coords_x, territory.coords_y, territory.coords_z))
		
		if distance <= territory.radius then
			TriggerClientEvent('esx_gangs:enteredTerritory', source, territory.name, territory.owner_gang)
			break
		end
	end
end)

-- ESX Callbacks
ESX.RegisterServerCallback('esx_gangs:getGangInfo', function(source, cb, gang)
	MySQL.Async.fetchAll('SELECT * FROM gangs WHERE name = @gang', {
		['@gang'] = gang
	}, function(gangResult)
		if gangResult[1] then
			MySQL.Async.fetchAll('SELECT * FROM gang_members WHERE gang_name = @gang', {
				['@gang'] = gang
			}, function(membersResult)
				MySQL.Async.fetchAll('SELECT * FROM gang_territories WHERE owner_gang = @gang', {
					['@gang'] = gang
				}, function(territoriesResult)
					cb({
						gang = gangResult[1],
						members = membersResult,
						territories = territoriesResult
					})
				end)
			end)
		else
			cb(nil)
		end
	end)
end)

-- Clean up on disconnect
AddEventHandler('playerDropped', function()
	drugRuns[source] = nil
end)