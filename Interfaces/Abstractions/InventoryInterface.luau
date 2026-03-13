local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IndexInterface = require(script.Parent.IndexInterface)
local DataTypes = require(ReplicatedStorage.Shared.Data.DataTypes)
local PlayerDataInterface = require(script.Parent.Parent.PlayerDataInterface)
local AssetInfo = require(ReplicatedStorage.Shared.AssetInfo.AssetInfo)
local MutationUtils = require(ReplicatedStorage.Shared.Mutations.MutationUtils)

local InventoryInterface = {}
local MANAGED_GEAR_TAG = "ManagedGearTool"

function InventoryInterface.getCombatant(player: Player, uniqueId: string | number): DataTypes.combatant
	return PlayerDataInterface.get(player, "inventory.combatants."..uniqueId)
end

function InventoryInterface.addCombatantToCollect(player: Player, uniqueId: string | number, amount: number)
	PlayerDataInterface.update(player, `inventory.combatants.{uniqueId}.toCollect`, true, function(v)
		return v + amount
	end)
end

function InventoryInterface.collectCombatantCash(player: Player, uniqueId: string)
    local collected: number
    PlayerDataInterface.update(player, `inventory.combatants.{uniqueId}.toCollect`, true, function(v)
        collected = v
        return 0
    end)
    
    if not collected then
        error("Nothing collected! "..uniqueId)
    end
    
    PlayerDataInterface.update(player, `currency.coins`, true, function(v)
        return v + collected
    end)
end

function InventoryInterface.getEgg(player: Player, uniqueId: string | number): DataTypes.egg
	return PlayerDataInterface.get(player, "inventory.eggs."..uniqueId)
end

function InventoryInterface.removeEgg(player: Player, uniqueId: string | number)
    PlayerDataInterface.update(player, `inventory.eggs.{uniqueId}`, true, function(_)
        return nil
    end)
end

function InventoryInterface.setEggPlacedTime(player: Player, uniqueId: string | number, placedTime: number)
    PlayerDataInterface.update(player, `inventory.eggs.{uniqueId}`, true, function(t: DataTypes.egg)
        t.metadata.placedTime = placedTime
        return t
    end)
end

function InventoryInterface.addCombatant(player: Player, combatantId: number, mutations: {number}): string
    local uniqueId = HttpService:GenerateGUID(false)
    PlayerDataInterface.update(player, `inventory.combatants.{uniqueId}`, true, function(_)
        return {
            id = combatantId,
            mutations = mutations,
            level = 0,
            toCollect = 0,

            metadata = {
                placed = false,
                placedTime = 0,

                position = nil,
                rotation = 0
            }
        } :: DataTypes.combatant
    end)
    
    local baseMut = MutationUtils.hasBaseMutation(mutations)
    if baseMut == -1 then
        baseMut = nil
    end
    IndexInterface.addToCombatantIndex(player, combatantId, baseMut)
    
    return uniqueId
end

function InventoryInterface.addLevels(player: Player, uniqueId: string, levels: number)
    PlayerDataInterface.update(player, `inventory.combatants.{uniqueId}.level`, true, function(level)
        return level + levels
    end)
end

function InventoryInterface.addEgg(player: Player, eggId: string | number, mutations: {number})
    local info = AssetInfo.getEgg(eggId)
    local uniqueId = HttpService:GenerateGUID(false)
    PlayerDataInterface.update(player, `inventory.eggs.{uniqueId}`, true, function(_)
        return {
            id = eggId,
            mutations = mutations,
            hatchTimeLeft = info.hatchTime,

            metadata = {
                placed = false,
                placedTime = 0,

                position = nil,
                rotation = 0
            }
        } :: DataTypes.egg
    end)
end

function InventoryInterface.placeCombatant(player: Player, uniqueId: string | number, slotNumber: number)
	PlayerDataInterface.update(player, `inventory.combatants.{uniqueId}.metadata`, true, function(data: {})
        data.placed = true
		data.placedTime = os.time()
		data.slotNumber = slotNumber
		
		return data
	end)
end

function InventoryInterface.placeEgg(player: Player, uniqueId: string | number, slotNumber: number)
	PlayerDataInterface.update(player, `inventory.eggs.{uniqueId}`, true, function(data: DataTypes.egg)
		local info = AssetInfo.getEgg(data.id)
		
        data.metadata.placed = true
		data.metadata.placedTime = os.time()
		data.slotNumber = slotNumber

		data.hatchTimeLeft = info.hatchTime

		return data
	end)
end

function InventoryInterface.updateHotbarPosition(player: Player, uniqueId: string, position: number)
    position = tostring(position)
    PlayerDataInterface.update(player, "hotbar", false, function(t: {string})
        local index = nil
        for p, uid in t do
            if uid == uniqueId then
                index = p
                break
            end
        end
        if index then
            t[index] = nil
        end
        
		if position == "-1" then
			t[position] = nil
		else
			t[position] = uniqueId
		end
		return t
	end)
end

function InventoryInterface.getEquippedSword(player: Player): (string | number)?
    return PlayerDataInterface.get(player, "equipped.sword")
end

function InventoryInterface.getSwords(player: Player): {string | number}
    return PlayerDataInterface.get(player, "inventory.swords")
end

function InventoryInterface.hasSword(player: Player, swordId: string)
    local swords = PlayerDataInterface.get(player, "inventory.swords")
    return table.find(swords, swordId) ~= nil
end

function InventoryInterface.setEquippedSword(player: Player, swordId: string | number)
    return PlayerDataInterface.update(player, "equipped.sword", true, function(_)
        return swordId
    end)
end

function InventoryInterface.addSword(player: Player, swordId: string | number)
    PlayerDataInterface.update(player, `inventory.swords`, true, function(t: {number})
        table.insert(t, swordId)
        return t
    end)
end

function InventoryInterface.getGears(player: Player): {string | number}
    return PlayerDataInterface.get(player, "inventory.gears")
end

function InventoryInterface.hasGear(player: Player, gearId: string | number): boolean
    local gears = InventoryInterface.getGears(player)
    return table.find(gears, gearId) ~= nil
end

function InventoryInterface.addGear(player: Player, gearId: string | number): boolean
    if InventoryInterface.hasGear(player, gearId) then
        return false
    end

    PlayerDataInterface.update(player, "inventory.gears", true, function(gears: {string | number})
        table.insert(gears, gearId)
        return gears
    end)
    return true
end

function InventoryInterface.getEquippedGear(player: Player): (string | number)?
    return PlayerDataInterface.get(player, "equipped.gear")
end

function InventoryInterface.setEquippedGear(player: Player, gearId: (string | number)?): boolean
    if gearId and not InventoryInterface.hasGear(player, gearId) then
        return false
    end

    PlayerDataInterface.update(player, "equipped.gear", true, function(_)
        return gearId
    end)
    return true
end

return InventoryInterface
