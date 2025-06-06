ESX = nil
local PlayerData = {}
local currentJob = nil
local jobVehicle = nil
local jobBlip = nil
local jobInProgress = false

-- Job specific variables
local garbageRoute = {}
local fishingSpot = nil
local deliveryRoute = {}
local constructionSite = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
	currentJob = PlayerData.job.name
end)

-- Update job data
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
	currentJob = job.name
end)

-- Civilian Jobs Menu
function OpenCivilianJobsMenu()
	SendNUIMessage({
		type = "openCivilianMenu",
		playerData = PlayerData,
		currentJob = currentJob,
		jobInProgress = jobInProgress
	})
	SetNuiFocus(true, true)
end

-- GARBAGE COLLECTOR JOB
function StartGarbageJob()
	if currentJob ~= 'garbage' and currentJob ~= 'unemployed' then
		ESX.ShowNotification('~r~Du musst Müllmann sein oder arbeitslos!')
		return
	end
	
	if jobInProgress then
		ESX.ShowNotification('~r~Du hast bereits einen Job aktiv!')
		return
	end
	
	-- Set job if unemployed
	if currentJob == 'unemployed' then
		TriggerServerEvent('esx_civilianjobs:setJob', 'garbage')
	end
	
	-- Get garbage truck
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	
	ESX.Game.SpawnVehicle('trash', coords, 90.0, function(vehicle)
		jobVehicle = vehicle
		SetVehicleNumberPlateText(vehicle, 'GARBAGE')
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		
		-- Generate garbage route
		GenerateGarbageRoute()
		jobInProgress = true
		
		ESX.ShowNotification('~g~Müllmann-Job gestartet! Fahre zu den markierten Mülltonnen.')
	end)
end

function GenerateGarbageRoute()
	local garbageLocations = {
		{x = 128.9, y = -1298.7, z = 29.2, collected = false},
		{x = 213.9, y = -1461.1, z = 29.3, collected = false},
		{x = 341.3, y = -1574.5, z = 29.3, collected = false},
		{x = 435.7, y = -1703.6, z = 29.6, collected = false},
		{x = 321.8, y = -1935.9, z = 24.9, collected = false},
		{x = 149.4, y = -1864.8, z = 24.6, collected = false},
		{x = 76.4, y = -1948.1, z = 21.2, collected = false},
		{x = -34.0, y = -1847.3, z = 26.2, collected = false}
	}
	
	garbageRoute = garbageLocations
	CreateGarbageBlips()
	StartGarbageCollection()
end

function CreateGarbageBlips()
	for i = 1, #garbageRoute do
		if not garbageRoute[i].collected then
			local blip = AddBlipForCoord(garbageRoute[i].x, garbageRoute[i].y, garbageRoute[i].z)
			SetBlipSprite(blip, 318)
			SetBlipScale(blip, 0.8)
			SetBlipColour(blip, 2)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName('STRING')
			AddTextComponentSubstringPlayerName('Müllcontainer')
			EndTextCommandSetBlipName(blip)
			garbageRoute[i].blip = blip
		end
	end
end

function StartGarbageCollection()
	Citizen.CreateThread(function()
		while jobInProgress and currentJob == 'garbage' do
			Citizen.Wait(0)
			
			local playerPed = PlayerPedId()
			local coords = GetEntityCoords(playerPed)
			
			for i = 1, #garbageRoute do
				local location = garbageRoute[i]
				if not location.collected then
					local distance = #(coords - vector3(location.x, location.y, location.z))
					
					if distance < 5.0 then
						DrawText3D(location.x, location.y, location.z + 1.0, '[E] Müll sammeln')
						
						if IsControlJustReleased(0, 38) and IsPedInVehicle(playerPed, jobVehicle, false) then
							CollectGarbage(i)
						end
					end
				end
			end
		end
	end)
end

function CollectGarbage(index)
	local playerPed = PlayerPedId()
	
	-- Animation
	TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_JANITOR', 0, true)
	
	ESX.ShowNotification('~g~Sammle Müll...')
	
	Citizen.Wait(3000)
	ClearPedTasks(playerPed)
	
	-- Mark as collected
	garbageRoute[index].collected = true
	RemoveBlip(garbageRoute[index].blip)
	
	-- Pay player
	local payment = math.random(50, 150)
	TriggerServerEvent('esx_civilianjobs:payPlayer', payment, 'Müll gesammelt')
	
	ESX.ShowNotification('~g~Müll gesammelt! +$' .. payment)
	
	-- Check if all collected
	local allCollected = true
	for i = 1, #garbageRoute do
		if not garbageRoute[i].collected then
			allCollected = false
			break
		end
	end
	
	if allCollected then
		ESX.ShowNotification('~g~Route abgeschlossen! Fahre zurück zum Depot.')
		FinishGarbageJob()
	end
end

function FinishGarbageJob()
	-- Create depot blip
	local depotBlip = AddBlipForCoord(-322.3, -1545.9, 31.0)
	SetBlipSprite(depotBlip, 318)
	SetBlipColour(depotBlip, 3)
	SetBlipRoute(depotBlip, true)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName('Müll-Depot')
	EndTextCommandSetBlipName(depotBlip)
	
	-- Wait for depot return
	Citizen.CreateThread(function()
		while jobInProgress do
			Citizen.Wait(0)
			
			local playerPed = PlayerPedId()
			local coords = GetEntityCoords(playerPed)
			local distance = #(coords - vector3(-322.3, -1545.9, 31.0))
			
			if distance < 10.0 then
				DrawText3D(-322.3, -1545.9, 32.0, '[E] Job beenden')
				
				if IsControlJustReleased(0, 38) then
					-- Final payment
					local bonus = math.random(500, 1000)
					TriggerServerEvent('esx_civilianjobs:payPlayer', bonus, 'Route abgeschlossen')
					
					ESX.ShowNotification('~g~Müllmann-Job abgeschlossen! Bonus: +$' .. bonus)
					
					-- Cleanup
					DeleteVehicle(jobVehicle)
					RemoveBlip(depotBlip)
					jobInProgress = false
					break
				end
			end
		end
	end)
end

-- FISHING JOB
function StartFishingJob()
	if currentJob ~= 'fisherman' and currentJob ~= 'unemployed' then
		ESX.ShowNotification('~r~Du musst Fischer sein oder arbeitslos!')
		return
	end
	
	if jobInProgress then
		ESX.ShowNotification('~r~Du hast bereits einen Job aktiv!')
		return
	end
	
	-- Set job if unemployed
	if currentJob == 'unemployed' then
		TriggerServerEvent('esx_civilianjobs:setJob', 'fisherman')
	end
	
	-- Check if player has fishing rod
	ESX.TriggerServerCallback('esx_civilianjobs:hasItem', function(hasRod)
		if hasRod then
			StartFishingSpots()
		else
			ESX.ShowNotification('~r~Du brauchst eine Angelrute! Kaufe eine für $50.')
			TriggerServerEvent('esx_civilianjobs:buyFishingRod')
		end
	end, 'fishing_rod')
end

function StartFishingSpots()
	local fishingSpots = {
		{x = -1850.7, y = -1248.0, z = 8.6, name = 'Vespucci Beach'},
		{x = -3426.3, y = 967.4, z = 8.3, name = 'Chumash Beach'},
		{x = 1300.4, y = 4216.7, z = 33.9, name = 'Alamo Sea'},
		{x = 2835.8, y = 1584.7, z = 24.5, name = 'Sandy Shores'},
		{x = -783.4, y = 5432.1, z = 34.1, name = 'Paleto Bay'}
	}
	
	fishingSpot = fishingSpots[math.random(1, #fishingSpots)]
	jobInProgress = true
	
	-- Create fishing blip
	jobBlip = AddBlipForCoord(fishingSpot.x, fishingSpot.y, fishingSpot.z)
	SetBlipSprite(jobBlip, 317)
	SetBlipColour(jobBlip, 3)
	SetBlipRoute(jobBlip, true)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName('Angelplatz: ' .. fishingSpot.name)
	EndTextCommandSetBlipName(jobBlip)
	
	ESX.ShowNotification('~g~Fischer-Job gestartet! Fahre zum Angelplatz: ' .. fishingSpot.name)
	StartFishingActivity()
end

function StartFishingActivity()
	Citizen.CreateThread(function()
		while jobInProgress and currentJob == 'fisherman' do
			Citizen.Wait(0)
			
			local playerPed = PlayerPedId()
			local coords = GetEntityCoords(playerPed)
			local distance = #(coords - vector3(fishingSpot.x, fishingSpot.y, fishingSpot.z))
			
			if distance < 20.0 then
				DrawText3D(fishingSpot.x, fishingSpot.y, fishingSpot.z + 1.0, '[E] Angeln')
				
				if IsControlJustReleased(0, 38) then
					StartFishing()
				end
			end
		end
	end)
end

function StartFishing()
	local playerPed = PlayerPedId()
	
	-- Fishing animation
	RequestAnimDict('amb@world_human_stand_fishing@idle_a')
	while not HasAnimDictLoaded('amb@world_human_stand_fishing@idle_a') do
		Wait(10)
	end
	
	TaskPlayAnim(playerPed, 'amb@world_human_stand_fishing@idle_a', 'idle_c', 8.0, 8.0, -1, 1, 0, false, false, false)
	
	ESX.ShowNotification('~g~Angelst... Warte auf einen Biss!')
	
	-- Random fishing time
	local fishingTime = math.random(5000, 15000)
	Citizen.Wait(fishingTime)
	
	ClearPedTasks(playerPed)
	
	-- Random catch
	local catchChance = math.random(1, 100)
	if catchChance <= 70 then -- 70% chance to catch fish
		local fishTypes = {
			{name = 'Sardine', price = 25},
			{name = 'Forelle', price = 45},
			{name = 'Lachs', price = 75},
			{name = 'Thunfisch', price = 120},
			{name = 'Hai', price = 500} -- Rare
		}
		
		local fish
		local rarity = math.random(1, 100)
		if rarity <= 50 then -- Common
			fish = fishTypes[math.random(1, 2)]
		elseif rarity <= 80 then -- Uncommon
			fish = fishTypes[math.random(2, 3)]
		elseif rarity <= 95 then -- Rare
			fish = fishTypes[4]
		else -- Very rare
			fish = fishTypes[5]
		end
		
		TriggerServerEvent('esx_civilianjobs:giveFish', fish.name, fish.price)
		ESX.ShowNotification('~g~Du hast einen ' .. fish.name .. ' gefangen! ($' .. fish.price .. ')')
	else
		ESX.ShowNotification('~r~Der Fisch ist entkommen!')
	end
	
	-- Continue fishing or sell fish
	Citizen.Wait(2000)
end

-- DELIVERY JOB
function StartDeliveryJob()
	if currentJob ~= 'delivery' and currentJob ~= 'unemployed' then
		ESX.ShowNotification('~r~Du musst Lieferfahrer sein oder arbeitslos!')
		return
	end
	
	if jobInProgress then
		ESX.ShowNotification('~r~Du hast bereits einen Job aktiv!')
		return
	end
	
	-- Set job if unemployed
	if currentJob == 'unemployed' then
		TriggerServerEvent('esx_civilianjobs:setJob', 'delivery')
	end
	
	-- Spawn delivery van
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	
	ESX.Game.SpawnVehicle('boxville', coords, 90.0, function(vehicle)
		jobVehicle = vehicle
		SetVehicleNumberPlateText(vehicle, 'DELIVERY')
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		
		GenerateDeliveryRoute()
		jobInProgress = true
		
		ESX.ShowNotification('~g~Lieferfahrer-Job gestartet! Fahre zu den Lieferstellen.')
	end)
end

function GenerateDeliveryRoute()
	local deliveryLocations = {
		{x = 25.7, y = -1347.3, z = 29.5, name = 'Vanilla Unicorn', delivered = false},
		{x = 373.5, y = 325.6, z = 103.6, name = 'Clinton Ave', delivered = false},
		{x = -1487.5, y = -379.1, z = 40.2, name = 'Morningwood', delivered = false},
		{x = -1821.5, y = 792.5, z = 138.1, name = 'Banham Canyon', delivered = false},
		{x = 1167.0, y = -324.1, z = 69.2, name = 'Mirror Park', delivered = false}
	}
	
	deliveryRoute = deliveryLocations
	CreateDeliveryBlips()
	StartDeliveryRun()
end

function CreateDeliveryBlips()
	for i = 1, #deliveryRoute do
		if not deliveryRoute[i].delivered then
			local blip = AddBlipForCoord(deliveryRoute[i].x, deliveryRoute[i].y, deliveryRoute[i].z)
			SetBlipSprite(blip, 478)
			SetBlipScale(blip, 0.8)
			SetBlipColour(blip, 5)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName('STRING')
			AddTextComponentSubstringPlayerName('Lieferung: ' .. deliveryRoute[i].name)
			EndTextCommandSetBlipName(blip)
			deliveryRoute[i].blip = blip
		end
	end
end

function StartDeliveryRun()
	Citizen.CreateThread(function()
		while jobInProgress and currentJob == 'delivery' do
			Citizen.Wait(0)
			
			local playerPed = PlayerPedId()
			local coords = GetEntityCoords(playerPed)
			
			for i = 1, #deliveryRoute do
				local location = deliveryRoute[i]
				if not location.delivered then
					local distance = #(coords - vector3(location.x, location.y, location.z))
					
					if distance < 5.0 then
						DrawText3D(location.x, location.y, location.z + 1.0, '[E] Paket liefern')
						
						if IsControlJustReleased(0, 38) and IsPedInVehicle(playerPed, jobVehicle, false) then
							DeliverPackage(i)
						end
					end
				end
			end
		end
	end)
end

function DeliverPackage(index)
	local playerPed = PlayerPedId()
	
	-- Animation
	TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
	
	ESX.ShowNotification('~g~Liefere Paket...')
	
	Citizen.Wait(3000)
	ClearPedTasks(playerPed)
	
	-- Mark as delivered
	deliveryRoute[index].delivered = true
	RemoveBlip(deliveryRoute[index].blip)
	
	-- Pay player
	local payment = math.random(100, 250)
	TriggerServerEvent('esx_civilianjobs:payPlayer', payment, 'Paket geliefert')
	
	ESX.ShowNotification('~g~Paket geliefert an ' .. deliveryRoute[index].name .. '! +$' .. payment)
	
	-- Check if all delivered
	local allDelivered = true
	for i = 1, #deliveryRoute do
		if not deliveryRoute[i].delivered then
			allDelivered = false
			break
		end
	end
	
	if allDelivered then
		ESX.ShowNotification('~g~Alle Pakete geliefert! Fahre zurück zum Depot.')
		FinishDeliveryJob()
	end
end

function FinishDeliveryJob()
	-- Create depot blip
	local depotBlip = AddBlipForCoord(1025.2, -2400.5, 30.5)
	SetBlipSprite(depotBlip, 478)
	SetBlipColour(depotBlip, 3)
	SetBlipRoute(depotBlip, true)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName('Lieferdepot')
	EndTextCommandSetBlipName(depotBlip)
	
	-- Wait for depot return
	Citizen.CreateThread(function()
		while jobInProgress do
			Citizen.Wait(0)
			
			local playerPed = PlayerPedId()
			local coords = GetEntityCoords(playerPed)
			local distance = #(coords - vector3(1025.2, -2400.5, 30.5))
			
			if distance < 10.0 then
				DrawText3D(1025.2, -2400.5, 31.5, '[E] Job beenden')
				
				if IsControlJustReleased(0, 38) then
					-- Final payment
					local bonus = math.random(300, 600)
					TriggerServerEvent('esx_civilianjobs:payPlayer', bonus, 'Alle Lieferungen abgeschlossen')
					
					ESX.ShowNotification('~g~Lieferfahrer-Job abgeschlossen! Bonus: +$' .. bonus)
					
					-- Cleanup
					DeleteVehicle(jobVehicle)
					RemoveBlip(depotBlip)
					jobInProgress = false
					break
				end
			end
		end
	end)
end

-- CONSTRUCTION JOB
function StartConstructionJob()
	if currentJob ~= 'construction' and currentJob ~= 'unemployed' then
		ESX.ShowNotification('~r~Du musst Bauarbeiter sein oder arbeitslos!')
		return
	end
	
	if jobInProgress then
		ESX.ShowNotification('~r~Du hast bereits einen Job aktiv!')
		return
	end
	
	-- Set job if unemployed
	if currentJob == 'unemployed' then
		TriggerServerEvent('esx_civilianjobs:setJob', 'construction')
	end
	
	-- Random construction site
	local constructionSites = {
		{x = -141.9, y = -1687.4, z = 32.9, name = 'Davis Construction'},
		{x = 1273.9, y = -1524.5, z = 49.6, name = 'El Burro Heights'},
		{x = -967.5, y = -1434.1, z = 7.5, name = 'Vespucci Beach'},
		{x = 2561.3, y = 384.8, z = 108.6, name = 'Vinewood Hills'}
	}
	
	constructionSite = constructionSites[math.random(1, #constructionSites)]
	jobInProgress = true
	
	-- Create construction blip
	jobBlip = AddBlipForCoord(constructionSite.x, constructionSite.y, constructionSite.z)
	SetBlipSprite(jobBlip, 566)
	SetBlipColour(jobBlip, 5)
	SetBlipRoute(jobBlip, true)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName('Baustelle: ' .. constructionSite.name)
	EndTextCommandSetBlipName(jobBlip)
	
	ESX.ShowNotification('~g~Bauarbeiter-Job gestartet! Fahre zur Baustelle: ' .. constructionSite.name)
	StartConstructionWork()
end

function StartConstructionWork()
	Citizen.CreateThread(function()
		while jobInProgress and currentJob == 'construction' do
			Citizen.Wait(0)
			
			local playerPed = PlayerPedId()
			local coords = GetEntityCoords(playerPed)
			local distance = #(coords - vector3(constructionSite.x, constructionSite.y, constructionSite.z))
			
			if distance < 10.0 then
				DrawText3D(constructionSite.x, constructionSite.y, constructionSite.z + 1.0, '[E] Arbeiten')
				
				if IsControlJustReleased(0, 38) then
					DoConstructionWork()
				end
			end
		end
	end)
end

function DoConstructionWork()
	local playerPed = PlayerPedId()
	
	-- Construction animation
	TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_HAMMERING', 0, true)
	
	ESX.ShowNotification('~g~Arbeite an der Baustelle...')
	
	-- Random work time
	local workTime = math.random(10000, 20000)
	Citizen.Wait(workTime)
	
	ClearPedTasks(playerPed)
	
	-- Pay player
	local payment = math.random(150, 350)
	TriggerServerEvent('esx_civilianjobs:payPlayer', payment, 'Bauarbeit')
	
	ESX.ShowNotification('~g~Arbeit abgeschlossen! +$' .. payment)
	
	-- Continue working or finish
	Citizen.Wait(3000)
end

-- Utility Functions
function DrawText3D(x, y, z, text)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	local px, py, pz = table.unpack(GetGameplayCamCoords())
	
	SetTextScale(0.35, 0.35)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x, _y)
	local factor = (string.len(text)) / 370
	DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

-- NUI Callbacks
RegisterNUICallback('closeMenu', function(data, cb)
	SetNuiFocus(false, false)
	cb('ok')
end)

RegisterNUICallback('startJob', function(data, cb)
	local jobType = data.jobType
	
	if jobType == 'garbage' then
		StartGarbageJob()
	elseif jobType == 'fishing' then
		StartFishingJob()
	elseif jobType == 'delivery' then
		StartDeliveryJob()
	elseif jobType == 'construction' then
		StartConstructionJob()
	elseif jobType == 'clothing' then
		OpenClothingStore()
	end
	
	cb('ok')
end)

RegisterNUICallback('stopJob', function(data, cb)
	if jobInProgress then
		-- Cleanup current job
		if jobVehicle then
			DeleteVehicle(jobVehicle)
			jobVehicle = nil
		end
		
		if jobBlip then
			RemoveBlip(jobBlip)
			jobBlip = nil
		end
		
		jobInProgress = false
		ESX.ShowNotification('~r~Job beendet!')
	end
	
	cb('ok')
end)

-- Key Bindings
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		
		if IsControlJustReleased(0, 168) then -- F7
			OpenCivilianJobsMenu()
		end
	end
end)

-- Clothing Store (Special civilian job)
function OpenClothingStore()
	-- This would open a clothing store interface
	ESX.ShowNotification('~g~Kleidungsladen-Feature kommt bald!')
end

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
	if resourceName == GetCurrentResourceName() then
		if jobVehicle then
			DeleteVehicle(jobVehicle)
		end
		
		if jobBlip then
			RemoveBlip(jobBlip)
		end
	end
end)