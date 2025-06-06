ESX = nil
local PlayerData = {}
local playerGang = nil
local gangRank = 0
local gangMenuOpen = false
local territoryBlips = {}
local gangWars = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
	TriggerServerEvent('esx_gangs:getPlayerGang')
end)

-- Update player data
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
	TriggerServerEvent('esx_gangs:getPlayerGang')
end)

-- Gang Menu
function OpenGangMenu()
	if not playerGang then
		ESX.ShowNotification('~r~Du bist in keiner Gang!')
		return
	end

	ESX.TriggerServerCallback('esx_gangs:getGangInfo', function(gangData)
		SendNUIMessage({
			type = "openGangMenu",
			playerData = PlayerData,
			gangData = gangData,
			playerGang = playerGang,
			gangRank = gangRank
		})
		SetNuiFocus(true, true)
		gangMenuOpen = true
	end, playerGang)
end

-- Gang Actions
function InvitePlayerToGang()
	local player, distance = ESX.Game.GetClosestPlayer()
	
	if distance ~= -1 and distance <= 3.0 then
		local targetId = GetPlayerServerId(player)
		
		if gangRank >= 3 then -- Minimum rank to invite
			TriggerServerEvent('esx_gangs:invitePlayer', targetId, playerGang)
		else
			ESX.ShowNotification('~r~Du hast nicht die Berechtigung Spieler einzuladen!')
		end
	else
		ESX.ShowNotification('~r~Kein Spieler in der Nähe!')
	end
end

function KickPlayerFromGang(targetId)
	if gangRank >= 4 then -- Higher rank to kick
		TriggerServerEvent('esx_gangs:kickPlayer', targetId, playerGang)
	else
		ESX.ShowNotification('~r~Du hast nicht die Berechtigung Spieler zu kicken!')
	end
end

function PromotePlayer(targetId)
	if gangRank >= 5 then -- Boss/Leader rank
		TriggerServerEvent('esx_gangs:promotePlayer', targetId, playerGang)
	else
		ESX.ShowNotification('~r~Du hast nicht die Berechtigung zu befördern!')
	end
end

function DemotePlayer(targetId)
	if gangRank >= 5 then
		TriggerServerEvent('esx_gangs:demotePlayer', targetId, playerGang)
	else
		ESX.ShowNotification('~r~Du hast nicht die Berechtigung zu degradieren!')
	end
end

-- Territory System
function AttackTerritory(territoryId)
	if gangRank >= 2 then
		TriggerServerEvent('esx_gangs:attackTerritory', territoryId, playerGang)
	else
		ESX.ShowNotification('~r~Du hast nicht die Berechtigung Territorien anzugreifen!')
	end
end

function DefendTerritory(territoryId)
	TriggerServerEvent('esx_gangs:defendTerritory', territoryId, playerGang)
end

-- Gang War Functions
function StartGangWar(targetGang)
	if gangRank >= 5 then
		TriggerServerEvent('esx_gangs:startGangWar', playerGang, targetGang)
	else
		ESX.ShowNotification('~r~Nur der Gang-Boss kann Kriege starten!')
	end
end

function EndGangWar(warId)
	if gangRank >= 5 then
		TriggerServerEvent('esx_gangs:endGangWar', warId, playerGang)
	else
		ESX.ShowNotification('~r~Nur der Gang-Boss kann Kriege beenden!')
	end
end

-- Drug Operations
function StartDrugRun()
	if not playerGang then
		ESX.ShowNotification('~r~Du bist in keiner Gang!')
		return
	end
	
	TriggerServerEvent('esx_gangs:startDrugRun', playerGang)
end

function SellDrugs()
	if not playerGang then
		ESX.ShowNotification('~r~Du bist in keiner Gang!')
		return
	end
	
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	TriggerServerEvent('esx_gangs:sellDrugs', playerGang, coords)
end

-- Weapon Operations
function BuyWeapons(weaponType, amount)
	if gangRank >= 3 then
		TriggerServerEvent('esx_gangs:buyWeapons', playerGang, weaponType, amount)
	else
		ESX.ShowNotification('~r~Du hast nicht die Berechtigung Waffen zu kaufen!')
	end
end

-- Gang Bank
function DepositMoney(amount)
	TriggerServerEvent('esx_gangs:depositMoney', playerGang, amount)
end

function WithdrawMoney(amount)
	if gangRank >= 3 then
		TriggerServerEvent('esx_gangs:withdrawMoney', playerGang, amount)
	else
		ESX.ShowNotification('~r~Du hast nicht die Berechtigung Geld abzuheben!')
	end
end

-- Vehicle Functions
function SpawnGangVehicle(model)
	if gangRank >= 2 then
		TriggerServerEvent('esx_gangs:spawnGangVehicle', playerGang, model)
	else
		ESX.ShowNotification('~r~Du hast nicht die Berechtigung Gang-Fahrzeuge zu spawnen!')
	end
end

-- NUI Callbacks
RegisterNUICallback('closeMenu', function(data, cb)
	SetNuiFocus(false, false)
	gangMenuOpen = false
	cb('ok')
end)

RegisterNUICallback('invitePlayer', function(data, cb)
	InvitePlayerToGang()
	cb('ok')
end)

RegisterNUICallback('kickPlayer', function(data, cb)
	KickPlayerFromGang(data.playerId)
	cb('ok')
end)

RegisterNUICallback('promotePlayer', function(data, cb)
	PromotePlayer(data.playerId)
	cb('ok')
end)

RegisterNUICallback('demotePlayer', function(data, cb)
	DemotePlayer(data.playerId)
	cb('ok')
end)

RegisterNUICallback('attackTerritory', function(data, cb)
	AttackTerritory(data.territoryId)
	cb('ok')
end)

RegisterNUICallback('defendTerritory', function(data, cb)
	DefendTerritory(data.territoryId)
	cb('ok')
end)

RegisterNUICallback('startGangWar', function(data, cb)
	StartGangWar(data.targetGang)
	cb('ok')
end)

RegisterNUICallback('endGangWar', function(data, cb)
	EndGangWar(data.warId)
	cb('ok')
end)

RegisterNUICallback('startDrugRun', function(data, cb)
	StartDrugRun()
	cb('ok')
end)

RegisterNUICallback('sellDrugs', function(data, cb)
	SellDrugs()
	cb('ok')
end)

RegisterNUICallback('buyWeapons', function(data, cb)
	BuyWeapons(data.weaponType, data.amount)
	cb('ok')
end)

RegisterNUICallback('depositMoney', function(data, cb)
	DepositMoney(data.amount)
	cb('ok')
end)

RegisterNUICallback('withdrawMoney', function(data, cb)
	WithdrawMoney(data.amount)
	cb('ok')
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
	SpawnGangVehicle(data.model)
	cb('ok')
end)

-- Key Bindings
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		
		if IsControlJustReleased(0, 167) then -- F6
			if playerGang then
				OpenGangMenu()
			end
		end
	end
end)

-- Territory Blips Management
function CreateTerritoryBlips(territories)
	-- Clear existing blips
	for i = 1, #territoryBlips do
		RemoveBlip(territoryBlips[i])
	end
	territoryBlips = {}
	
	-- Create new blips
	for i = 1, #territories do
		local territory = territories[i]
		local blip = AddBlipForCoord(territory.coords.x, territory.coords.y, territory.coords.z)
		
		SetBlipSprite(blip, 84)
		SetBlipScale(blip, 1.2)
		SetBlipAsShortRange(blip, true)
		
		-- Color based on gang
		if territory.owner_gang == playerGang then
			SetBlipColour(blip, 2) -- Green for owned
		elseif territory.owner_gang then
			SetBlipColour(blip, 1) -- Red for enemy
		else
			SetBlipColour(blip, 5) -- Yellow for neutral
		end
		
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(territory.name .. ' (' .. (territory.owner_gang or 'Neutral') .. ')')
		EndTextCommandSetBlipName(blip)
		
		table.insert(territoryBlips, blip)
	end
end

-- Gang War Notifications
function ShowGangWarNotification(message, type)
	if type == 'war_started' then
		PlaySoundFrontend(-1, 'CHECKPOINT_PERFECT', 'HUD_MINI_GAME_SOUNDSET', 1)
	elseif type == 'territory_attacked' then
		PlaySoundFrontend(-1, 'CHALLENGE_UNLOCKED', 'HUD_AWARDS', 1)
	end
	
	ESX.ShowAdvancedNotification('Gang Wars', playerGang or 'Gang System', message, 'CHAR_GANGAPP', 1)
end

-- Receive Server Events
RegisterNetEvent('esx_gangs:setPlayerGang')
AddEventHandler('esx_gangs:setPlayerGang', function(gang, rank)
	playerGang = gang
	gangRank = rank
	
	if gang then
		ESX.ShowNotification('~g~Gang geladen: ' .. gang .. ' (Rang: ' .. rank .. ')')
	end
end)

RegisterNetEvent('esx_gangs:updateTerritories')
AddEventHandler('esx_gangs:updateTerritories', function(territories)
	CreateTerritoryBlips(territories)
end)

RegisterNetEvent('esx_gangs:gangWarStarted')
AddEventHandler('esx_gangs:gangWarStarted', function(gang1, gang2)
	if gang1 == playerGang or gang2 == playerGang then
		ShowGangWarNotification('Gang War zwischen ' .. gang1 .. ' und ' .. gang2 .. ' hat begonnen!', 'war_started')
	end
end)

RegisterNetEvent('esx_gangs:territoryAttacked')
AddEventHandler('esx_gangs:territoryAttacked', function(territoryName, attackingGang, defendingGang)
	if attackingGang == playerGang or defendingGang == playerGang then
		ShowGangWarNotification(territoryName .. ' wird von ' .. attackingGang .. ' angegriffen!', 'territory_attacked')
	end
end)

RegisterNetEvent('esx_gangs:gangInvite')
AddEventHandler('esx_gangs:gangInvite', function(gang, inviterName)
	ESX.ShowAdvancedNotification(
		'Gang Einladung',
		gang,
		inviterName .. ' hat dich zu ' .. gang .. ' eingeladen!\nDrücke Y um anzunehmen oder N um abzulehnen.',
		'CHAR_GANGAPP',
		1
	)
	
	-- Wait for input
	Citizen.CreateThread(function()
		local timeout = 30000
		local startTime = GetGameTimer()
		
		while GetGameTimer() - startTime < timeout do
			Citizen.Wait(0)
			
			if IsControlJustReleased(0, 246) then -- Y key
				TriggerServerEvent('esx_gangs:acceptInvite', gang)
				break
			elseif IsControlJustReleased(0, 249) then -- N key
				TriggerServerEvent('esx_gangs:declineInvite', gang)
				break
			end
		end
	end)
end)

RegisterNetEvent('esx_gangs:drugRunStarted')
AddEventHandler('esx_gangs:drugRunStarted', function(coords)
	ESX.ShowNotification('~g~Drug Run gestartet! Fahre zu den Koordinaten.')
	SetNewWaypoint(coords.x, coords.y)
end)

RegisterNetEvent('esx_gangs:vehicleSpawned')
AddEventHandler('esx_gangs:vehicleSpawned', function(model)
	ESX.ShowNotification('~g~Gang-Fahrzeug ' .. model .. ' gespawnt!')
end)

-- Gang Zone Detection
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		
		if playerGang then
			local playerPed = PlayerPedId()
			local coords = GetEntityCoords(playerPed)
			
			-- Check if in gang territory
			TriggerServerEvent('esx_gangs:checkPlayerInTerritory', coords)
		end
	end
end)

RegisterNetEvent('esx_gangs:enteredTerritory')
AddEventHandler('esx_gangs:enteredTerritory', function(territoryName, ownerGang)
	if ownerGang == playerGang then
		ESX.ShowNotification('~g~Du betrittst dein Territorium: ' .. territoryName)
	elseif ownerGang then
		ESX.ShowNotification('~r~Du betrittst feindliches Territorium: ' .. territoryName .. ' (' .. ownerGang .. ')')
	else
		ESX.ShowNotification('~y~Du betrittst neutrales Territorium: ' .. territoryName)
	end
end)