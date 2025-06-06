ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local activeJobs = {}

-- Pay Player
RegisterServerEvent('esx_civilianjobs:payPlayer')
AddEventHandler('esx_civilianjobs:payPlayer', function(amount, reason)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer then
		xPlayer.addMoney(amount)
		
		-- Log activity
		MySQL.Async.execute('INSERT INTO civilian_job_logs (player_id, player_name, job_type, activity, amount, activity_time) VALUES (@player, @name, @job, @activity, @amount, @time)', {
			['@player'] = xPlayer.identifier,
			['@name'] = xPlayer.getName(),
			['@job'] = xPlayer.job.name,
			['@activity'] = reason,
			['@amount'] = amount,
			['@time'] = os.time()
		})
	end
end)

-- Set Job
RegisterServerEvent('esx_civilianjobs:setJob')
AddEventHandler('esx_civilianjobs:setJob', function(jobName)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer then
		xPlayer.setJob(jobName, 0)
		TriggerClientEvent('esx:showNotification', source, '~g~Job geändert zu: ' .. jobName)
		
		-- Log job change
		MySQL.Async.execute('INSERT INTO civilian_job_logs (player_id, player_name, job_type, activity, activity_time) VALUES (@player, @name, @job, @activity, @time)', {
			['@player'] = xPlayer.identifier,
			['@name'] = xPlayer.getName(),
			['@job'] = jobName,
			['@activity'] = 'Job gestartet',
			['@time'] = os.time()
		})
	end
end)

-- Buy Fishing Rod
RegisterServerEvent('esx_civilianjobs:buyFishingRod')
AddEventHandler('esx_civilianjobs:buyFishingRod', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer then
		if xPlayer.getMoney() >= 50 then
			xPlayer.removeMoney(50)
			xPlayer.addInventoryItem('fishing_rod', 1)
			TriggerClientEvent('esx:showNotification', source, '~g~Angelrute für $50 gekauft!')
		else
			TriggerClientEvent('esx:showNotification', source, '~r~Nicht genug Geld!')
		end
	end
end)

-- Give Fish
RegisterServerEvent('esx_civilianjobs:giveFish')
AddEventHandler('esx_civilianjobs:giveFish', function(fishName, price)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer then
		-- Add fish to inventory (if inventory system supports it)
		local fishItem = string.lower(fishName):gsub(" ", "_")
		
		-- For now, just give money directly
		xPlayer.addMoney(price)
		
		-- Log fish catch
		MySQL.Async.execute('INSERT INTO civilian_job_logs (player_id, player_name, job_type, activity, amount, activity_time) VALUES (@player, @name, @job, @activity, @amount, @time)', {
			['@player'] = xPlayer.identifier,
			['@name'] = xPlayer.getName(),
			['@job'] = 'fisherman',
			['@activity'] = 'Fisch gefangen: ' .. fishName,
			['@amount'] = price,
			['@time'] = os.time()
		})
		
		TriggerClientEvent('esx:showNotification', source, '~g~' .. fishName .. ' verkauft für $' .. price .. '!')
	end
end)

-- Sell Fish (if player wants to sell later)
RegisterServerEvent('esx_civilianjobs:sellFish')
AddEventHandler('esx_civilianjobs:sellFish', function(fishType, quantity)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer then
		local fishPrices = {
			['sardine'] = 25,
			['forelle'] = 45,
			['lachs'] = 75,
			['thunfisch'] = 120,
			['hai'] = 500
		}
		
		local price = fishPrices[fishType] or 25
		local totalPrice = price * quantity
		
		-- Check if player has the fish
		local fishItem = xPlayer.getInventoryItem(fishType)
		if fishItem and fishItem.count >= quantity then
			xPlayer.removeInventoryItem(fishType, quantity)
			xPlayer.addMoney(totalPrice)
			
			TriggerClientEvent('esx:showNotification', source, '~g~' .. quantity .. 'x ' .. fishType .. ' für $' .. totalPrice .. ' verkauft!')
		else
			TriggerClientEvent('esx:showNotification', source, '~r~Du hast nicht genug ' .. fishType .. '!')
		end
	end
end)

-- Construction Job Bonus
RegisterServerEvent('esx_civilianjobs:constructionBonus')
AddEventHandler('esx_civilianjobs:constructionBonus', function(hoursWorked)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer and xPlayer.job.name == 'construction' then
		local bonus = hoursWorked * 100
		xPlayer.addMoney(bonus)
		
		TriggerClientEvent('esx:showNotification', source, '~g~Bonus für ' .. hoursWorked .. ' Stunden Arbeit: $' .. bonus)
		
		-- Log bonus
		MySQL.Async.execute('INSERT INTO civilian_job_logs (player_id, player_name, job_type, activity, amount, activity_time) VALUES (@player, @name, @job, @activity, @amount, @time)', {
			['@player'] = xPlayer.identifier,
			['@name'] = xPlayer.getName(),
			['@job'] = 'construction',
			['@activity'] = 'Stunden-Bonus (' .. hoursWorked .. 'h)',
			['@amount'] = bonus,
			['@time'] = os.time()
		})
	end
end)

-- Get Job Statistics
ESX.RegisterServerCallback('esx_civilianjobs:getJobStats', function(source, cb, jobType)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	MySQL.Async.fetchAll('SELECT COUNT(*) as total_activities, SUM(amount) as total_earned FROM civilian_job_logs WHERE player_id = @player AND job_type = @job', {
		['@player'] = xPlayer.identifier,
		['@job'] = jobType
	}, function(result)
		if result[1] then
			cb({
				totalActivities = result[1].total_activities,
				totalEarned = result[1].total_earned or 0
			})
		else
			cb({totalActivities = 0, totalEarned = 0})
		end
	end)
end)

-- Check if player has item
ESX.RegisterServerCallback('esx_civilianjobs:hasItem', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer then
		local playerItem = xPlayer.getInventoryItem(item)
		cb(playerItem and playerItem.count > 0)
	else
		cb(false)
	end
end)

-- Get Player Job Info
ESX.RegisterServerCallback('esx_civilianjobs:getPlayerInfo', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer then
		cb({
			job = xPlayer.job.name,
			money = xPlayer.getMoney(),
			bank = xPlayer.getAccount('bank').money
		})
	else
		cb(nil)
	end
end)

-- Delivery Job Tracking
RegisterServerEvent('esx_civilianjobs:startDeliveryRoute')
AddEventHandler('esx_civilianjobs:startDeliveryRoute', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer then
		activeJobs[source] = {
			type = 'delivery',
			startTime = os.time(),
			player = xPlayer.identifier
		}
	end
end)

RegisterServerEvent('esx_civilianjobs:finishDeliveryRoute')
AddEventHandler('esx_civilianjobs:finishDeliveryRoute', function(deliveriesCompleted)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer and activeJobs[source] then
		local timeWorked = os.time() - activeJobs[source].startTime
		local bonus = math.floor(timeWorked / 60) * 10 -- $10 per minute
		
		xPlayer.addMoney(bonus)
		
		-- Log completion
		MySQL.Async.execute('INSERT INTO civilian_job_logs (player_id, player_name, job_type, activity, amount, activity_time) VALUES (@player, @name, @job, @activity, @amount, @time)', {
			['@player'] = xPlayer.identifier,
			['@name'] = xPlayer.getName(),
			['@job'] = 'delivery',
			['@activity'] = 'Route abgeschlossen (' .. deliveriesCompleted .. ' Lieferungen)',
			['@amount'] = bonus,
			['@time'] = os.time()
		})
		
		activeJobs[source] = nil
		TriggerClientEvent('esx:showNotification', source, '~g~Lieferroute abgeschlossen! Zeit-Bonus: $' .. bonus)
	end
end)

-- Garbage Job Tracking
RegisterServerEvent('esx_civilianjobs:startGarbageRoute')
AddEventHandler('esx_civilianjobs:startGarbageRoute', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer then
		activeJobs[source] = {
			type = 'garbage',
			startTime = os.time(),
			player = xPlayer.identifier
		}
	end
end)

RegisterServerEvent('esx_civilianjobs:finishGarbageRoute')
AddEventHandler('esx_civilianjobs:finishGarbageRoute', function(containersCollected)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer and activeJobs[source] then
		local timeWorked = os.time() - activeJobs[source].startTime
		local bonus = containersCollected * 50 -- $50 per container bonus
		
		xPlayer.addMoney(bonus)
		
		-- Log completion
		MySQL.Async.execute('INSERT INTO civilian_job_logs (player_id, player_name, job_type, activity, amount, activity_time) VALUES (@player, @name, @job, @activity, @amount, @time)', {
			['@player'] = xPlayer.identifier,
			['@name'] = xPlayer.getName(),
			['@job'] = 'garbage',
			['@activity'] = 'Route abgeschlossen (' .. containersCollected .. ' Container)',
			['@amount'] = bonus,
			['@time'] = os.time()
		})
		
		activeJobs[source] = nil
		TriggerClientEvent('esx:showNotification', source, '~g~Müllroute abgeschlossen! Container-Bonus: $' .. bonus)
	end
end)

-- Daily/Weekly Bonuses
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(3600000) -- 1 hour
		
		-- Check for players who worked for a full hour
		for playerId, jobData in pairs(activeJobs) do
			local timeWorked = os.time() - jobData.startTime
			
			if timeWorked >= 3600 then -- 1 hour
				local xPlayer = ESX.GetPlayerFromId(playerId)
				
				if xPlayer then
					local hourlyBonus = 200
					xPlayer.addMoney(hourlyBonus)
					
					TriggerClientEvent('esx:showNotification', playerId, '~g~Stunden-Bonus erhalten: $' .. hourlyBonus)
					
					-- Log hourly bonus
					MySQL.Async.execute('INSERT INTO civilian_job_logs (player_id, player_name, job_type, activity, amount, activity_time) VALUES (@player, @name, @job, @activity, @amount, @time)', {
						['@player'] = xPlayer.identifier,
						['@name'] = xPlayer.getName(),
						['@job'] = jobData.type,
						['@activity'] = 'Stunden-Bonus',
						['@amount'] = hourlyBonus,
						['@time'] = os.time()
					})
					
					-- Reset start time for next hour
					activeJobs[playerId].startTime = os.time()
				end
			end
		end
	end
end)

-- Clothing Store Management
RegisterServerEvent('esx_civilianjobs:buyClothing')
AddEventHandler('esx_civilianjobs:buyClothing', function(itemData, price)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer then
		if xPlayer.getMoney() >= price then
			xPlayer.removeMoney(price)
			
			-- This would integrate with clothing/skin system
			TriggerClientEvent('esx:showNotification', source, '~g~Kleidung für $' .. price .. ' gekauft!')
			
			-- If player is clothing store employee, give commission
			if xPlayer.job.name == 'clothing' then
				local commission = math.floor(price * 0.1) -- 10% commission
				xPlayer.addMoney(commission)
				TriggerClientEvent('esx:showNotification', source, '~g~Provision erhalten: $' .. commission)
			end
		else
			TriggerClientEvent('esx:showNotification', source, '~r~Nicht genug Geld!')
		end
	end
end)

-- Random Events for Jobs
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1800000) -- 30 minutes
		
		-- Random bonus event
		local onlinePlayers = ESX.GetPlayers()
		
		for i = 1, #onlinePlayers do
			local xPlayer = ESX.GetPlayerFromId(onlinePlayers[i])
			
			if xPlayer and activeJobs[onlinePlayers[i]] then
				local eventChance = math.random(1, 100)
				
				if eventChance <= 10 then -- 10% chance for random event
					local bonusAmount = math.random(100, 500)
					xPlayer.addMoney(bonusAmount)
					
					TriggerClientEvent('esx:showNotification', onlinePlayers[i], '~g~Zufallsbonus! Du hast $' .. bonusAmount .. ' gefunden!')
					
					-- Log random bonus
					MySQL.Async.execute('INSERT INTO civilian_job_logs (player_id, player_name, job_type, activity, amount, activity_time) VALUES (@player, @name, @job, @activity, @amount, @time)', {
						['@player'] = xPlayer.identifier,
						['@name'] = xPlayer.getName(),
						['@job'] = activeJobs[onlinePlayers[i]].type,
						['@activity'] = 'Zufallsbonus',
						['@amount'] = bonusAmount,
						['@time'] = os.time()
					})
				end
			end
		end
	end
end)

-- Clean up on disconnect
AddEventHandler('playerDropped', function()
	activeJobs[source] = nil
end)

-- Admin Commands
RegisterCommand('givejob', function(source, args, rawCommand)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer and xPlayer.getGroup() == 'admin' then
		local targetId = tonumber(args[1])
		local jobName = args[2]
		
		if targetId and jobName then
			local xTarget = ESX.GetPlayerFromId(targetId)
			
			if xTarget then
				xTarget.setJob(jobName, 0)
				TriggerClientEvent('esx:showNotification', targetId, '~g~Job geändert zu: ' .. jobName)
				TriggerClientEvent('esx:showNotification', source, '~g~Job von ' .. xTarget.getName() .. ' geändert zu: ' .. jobName)
			end
		end
	end
end)

RegisterCommand('jobstats', function(source, args, rawCommand)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer then
		MySQL.Async.fetchAll('SELECT job_type, COUNT(*) as activities, SUM(amount) as total_earned FROM civilian_job_logs WHERE player_id = @player GROUP BY job_type', {
			['@player'] = xPlayer.identifier
		}, function(result)
			TriggerClientEvent('esx:showNotification', source, '~g~Deine Job-Statistiken:')
			
			for i = 1, #result do
				local job = result[i]
				TriggerClientEvent('esx:showNotification', source, '~b~' .. job.job_type .. ': ' .. job.activities .. ' Aktivitäten, $' .. (job.total_earned or 0) .. ' verdient')
			end
		end)
	end
end)