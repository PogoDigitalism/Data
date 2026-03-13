--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local SerDes = require(script.Parent.Parent.SerDes)
local TableUtil = require(ReplicatedStorage.Shared.Lib.TableUtil)
local Types_3 = require(ReplicatedStorage.Shared.Data.DataTypes)
local AdminTemplate = require(ReplicatedStorage.Shared.Data.Templates.AdminTemplate)
local BaseTemplate = require(ReplicatedStorage.Shared.Data.Templates.BaseTemplate)
local DevTemplate = require(ReplicatedStorage.Shared.Data.Templates.DevTemplate)
local DataChanged = ReplicatedStorage.Shared.Data.DataChanged

local PlayerDataInterface = {}

local ProfileStore = require(script.Parent.Parent.ProfileStore)
local DataMigration = require(script.Parent.Parent.DataMigration)

BaseTemplate = SerDes.serialize(BaseTemplate) :: typeof(BaseTemplate)
AdminTemplate = SerDes.serialize(AdminTemplate) :: typeof(AdminTemplate)
DevTemplate = SerDes.serialize(DevTemplate) :: typeof(DevTemplate)

local GROUP_ID = 1046838214

type data_template = typeof(DevTemplate)
type function getReturnValue(key, base_template)
	if not key:is("singleton") then
		error("Not a keyPath ")
	end

	local currentRef = base_template
	
	local keyPath = key:value()
	local keys = string.split(keyPath, ".")

	for i = 1, #keys - 1, 1 do
		local key = keys[i]
		key = tonumber(key) or key

		currentRef = currentRef:readproperty(types.singleton(key)) :: type
	end

	local finalKey = keys[#keys]
	finalKey = tonumber(finalKey) or finalKey

	return currentRef:readproperty(types.singleton(finalKey))
end

--⚠️ BE VERY CAREFUL ⚠️--
local FORCE_MOCK = true
local DEV_MODE = true
local DISABLE_ADMIN = true

if game.PlaceId == 121183047577587 then
	FORCE_MOCK = false
	DEV_MODE = false
	DISABLE_ADMIN = true
end

--⚠️ BE VERY CAREFUL⚠️ --

local function formatNumber(n)
	if n >= 1e9 then
		return string.format("$%.1fB", n/1e9)
	elseif n >= 1e6 then
		return string.format("$%.1fM", n/1e6)
	elseif n >= 1e3 then
		return string.format("$%.1fK", n/1e3)
	else
		return tostring(n)
	end
end

local normalStore = ProfileStore.New("PlayerStore", BaseTemplate)
local adminStore = ProfileStore.New("AdminStore", AdminTemplate)
local devStore = ProfileStore.New("DevStore", DevTemplate)

if FORCE_MOCK then
	warn("RUNNING ON MOCK PROFILES")
	normalStore = normalStore.Mock
	adminStore = adminStore.Mock
	devStore = devStore.Mock
end

local Profiles: {[Player]: typeof(normalStore:StartSessionAsync())} = {}

local yieldedThreads: {[Player]: thread} = {}
local function releaseYieldedThreads(player: Player, success: boolean)
	for _, t in yieldedThreads[player] or {} do
		task.spawn(
			t, success
		)
	end
	table.clear(yieldedThreads[player] or {})
end

local function yieldTillLoaded(player: Player)
	if not Profiles[player] or Profiles[player] == -1 then
		local thread = coroutine.running()

		if not yieldedThreads[player] then
			yieldedThreads[player] = {}
		end

		table.insert(
			yieldedThreads[player],
			thread
		)

		local success = coroutine.yield()
		return success
	end
	if Profiles[player] == 0 then
		return false
	end
	return true
end

local batches: {[Player]: {[string]: any}} = {}
RunService.Heartbeat:Connect(function(dt)
	for player, batch in batches do
		if next(batch) == nil then continue end
        
        DataChanged:FireClient(player, batch)
		
		batches[player] = {}
	end
end)

@native
local function addToBatch(player: Player, loc: string, value: any)
	if value == nil then
        value = "nil"
        for keyPath in batches[player] or {} do
            if keyPath:find(loc) then
                batches[player][keyPath] = nil
            end
        end
	end
    batches[player][loc] = value
end

local function syncToClient(player: Player, loc: string, data: any)
    addToBatch(player, loc, data)
end

local function setTableValue(player: Player, keyPath, value)
	local profile = Profiles[player]
	
	
	local keys = string.split(keyPath, ".")
	local currentRef = profile.Data

	for i = 1, #keys - 1, 1 do
		local key = keys[i]
		key = tonumber(key) or key
		
		if type(currentRef[key]) ~= "table" then
			error("Invalid key path: " .. table.concat(keys, ".", 1, i))
		end
		currentRef = currentRef[key]
	end

	local finalKey = keys[#keys]
	finalKey = tonumber(finalKey) or finalKey
	currentRef[finalKey] = value
end

local function getTableValue(player: Player, keyPath)
	local profile = Profiles[player]

	local keys = string.split(keyPath, ".")
	local currentRef = profile.Data
	for i = 1, #keys - 1, 1 do
		local key = keys[i]
		key = tonumber(key) or key
		
		if not key then
			error("Invalid key path: " .. key .. " does not exist in: " .. keyPath)
		end
		if type(currentRef[key]) ~= "table" then
			error("Invalid key path: " .. table.concat(keys, ".", 1, i))
		end
		
		currentRef = currentRef[key]
	end

	local finalKey = keys[#keys]
	finalKey = tonumber(finalKey) or finalKey
	return currentRef[finalKey]
end

function PlayerDataInterface.get<T>(player: Player, keyPath: T | ""): getReturnValue<T, data_template>
	local success = yieldTillLoaded(player)
	if not success then error("Player data could not be loaded!", 2) end

	local profile = Profiles[player]
	if profile then
		return getTableValue(player, keyPath)
	end
end

function PlayerDataInterface.set(player: Player, keyPath: string, value: any)
	local success = yieldTillLoaded(player)
	if not success then error("Player data could not be loaded!", 2) end

	local profile = Profiles[player]
	if profile then
		setTableValue(player, keyPath, value)
		syncToClient(player, keyPath, value)
	end
end

type callback<T> = (value: any) -> any
function PlayerDataInterface.update<T>(
	player: Player, 
	keyPath: T | "", 
	sync_to_client: boolean , 
	callback: callback<T>
)
	local success = yieldTillLoaded(player)
	if not success then error("Player data could not be loaded!", 2) end

	local profile = Profiles[player]
	if profile then
		local value = PlayerDataInterface.get(player, keyPath)
		local newValue = callback(value)
		
		if keyPath == 'currency.coins' then 
			player.leaderstats.Cash.Value = formatNumber(newValue) 
		end
		
		PlayerDataInterface.set(player, keyPath, newValue)
	end
end

function PlayerDataInterface.getDataTable(player: Player): typeof(BaseTemplate)
	local success = yieldTillLoaded(player)
	if not success then error("Player data could not be loaded!", 2) end

	return Profiles[player].Data
end

function PlayerDataInterface.wait(player: Player): boolean
	return yieldTillLoaded(player)
end

function PlayerDataInterface.getProfile(player: Player)
	return Profiles[player]
end

function PlayerDataInterface.releaseProfile(player: Player)
	Profiles[player]:Release()
	Profiles[player] = nil
end

function PlayerDataInterface.clear(player: Player)
	Profiles[player] = nil
end


----- Initialize -----
local function getProfileSession(player)
	local key = tostring(player.UserId)
	if DEV_MODE then
		local profile = devStore:StartSessionAsync(key)
		if not profile then return end
		
		
		profile.Data = TableUtil.Copy(DevTemplate, true)
		return profile
	end
	local success, result = pcall(function()
        if not DISABLE_ADMIN and player:GetRankInGroup(GROUP_ID) >= 253 then
			return adminStore:StartSessionAsync(key)
		else
			return normalStore:StartSessionAsync(key)
		end
	end)
	if not success then
		warn("--> ADMIN LOAD ERRORED", result)
		return normalStore:StartSessionAsync(key)
	end
	return result
end

-- game specific profile load handling
local function handleLoadedProfile(player)
	local profile = Profiles[player]
    local data: typeof(DevTemplate) = profile.Data
    
    DataMigration.applyMigration(data)
    
	local ls = Instance.new("Folder")
	ls.Name = "leaderstats"
	ls.Parent = player

	local coins = Instance.new("StringValue")
    coins.Name = "Cash"
	coins.Value = formatNumber(data.currency.coins)
	coins.Parent = ls

	local now = os.time()
	data.meta.times_logged_in += 1

	local function getDay(t)
		return math.floor(t / (24 * 60 * 60))
	end

	local current_day = getDay(now)
	local last_day = getDay(data.meta.daily_login)

	if current_day > last_day then
		if current_day - last_day == 1 then
			data.meta.daily_login_streak += 1
		else
			data.meta.daily_login_streak = 1
		end
		data.meta.daily_login = now
	end

	data.meta.previous_login = data.meta.latest_login
	data.meta.latest_login = now
	
	profile.OnSave:Connect(function()
        Profiles[player] = -1
        profile.Data.meta.logout_time = os.time()
		profile.Data = SerDes.serialize(profile.Data)
	end)
	
	profile.OnAfterSave:Connect(function(lsd)
		profile.Data = SerDes.deserialize(lsd)
		Profiles[player] = profile
		
		releaseYieldedThreads(player, true)
	end)
	profile.Data = SerDes.deserialize(profile.Data)
	
	profile.OnSessionEnd:Connect(function()
		Profiles[player] = nil
		player:Kick("Please rejoin.")
	end)
end

function PlayerDataInterface.handlePlayerAdded(player:Player)
	Profiles[player] = -1 -- not loaded state
	
	local profile = getProfileSession(player)
	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		batches[player] = {}
		Profiles[player] = profile
		
		--warn(player.Name, "data loaded", profile.Data)

		if player:IsDescendantOf(Players) then
			Profiles[player] = profile
			
            handleLoadedProfile(player)
            print("PLAYER DTAA LOADED", profile.Data)
			releaseYieldedThreads(player, true)
		else
			profile:EndSession()
			releaseYieldedThreads(player, false)
		end
	else
		
		Profiles[player] = 0
		releaseYieldedThreads(player, false)
		player:Kick("Data could not be loaded!") 
	end
end

for _, player in Players:GetPlayers() do
	task.spawn(PlayerDataInterface.handlePlayerAdded, player)
end
Players.PlayerAdded:Connect(PlayerDataInterface.handlePlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	batches[player] = nil
	local profile = Profiles[player]
	if profile ~= nil then
		profile:EndSession()
	end
end)

ReplicatedStorage.Shared.Data.GetPlayerData.OnServerInvoke = function(player: Player)
	local success = yieldTillLoaded(player)
	if not success then error("Player data could not be loaded!", 2) end

	return Profiles[player].Data
end

return PlayerDataInterface