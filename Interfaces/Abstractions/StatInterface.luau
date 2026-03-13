local PlayerDataInterface = require(script.Parent.Parent.PlayerDataInterface)
local StatInterface = {}

-------------------------------------------------------
function StatInterface.addCoins(player: Player, value: number)
	PlayerDataInterface.update(player, "currency.coins", true, function(coins)
		return coins + value
	end)
end
function StatInterface.setCoins(player: Player, coins: number): number
    PlayerDataInterface.update(player, "currency.coins", true, function(_)
        return coins
    end)
end
function StatInterface.addSlots(player: Player, value: number)
    PlayerDataInterface.update(player, "stats.inventory_slots", true, function(slots)
        return slots + value
    end)
end
function StatInterface.getSlots(player: Player)
	return PlayerDataInterface.get(player, "stats.inventory_slots")
end
function StatInterface.reductCoins(player: Player, value: number)
	PlayerDataInterface.update(player, "currency.coins", true, function(coins)
		return coins - value
	end)
end
function StatInterface.getCoins(player: Player)
	return PlayerDataInterface.get(player, "currency.coins")
end
function StatInterface.getIndex(player: Player): {[number]: {[string]: any}}
	return PlayerDataInterface.get(player, "stats.index")
end

function StatInterface.addToIndex(player: Player, id: number, weight: number, variants)
	PlayerDataInterface.update(player, "stats.index."..id, true, function(t)
		if not t then
			local variantSet = {}
			for i=1,#variants do
				variantSet[variants[i]] = true
			end
			
			return {
				collected_amount = 1,
				biggest_weight = weight,
				variants = variantSet
			}
		end
		
		t.collected_amount += 1
		if weight > t.biggest_weight then
			t.biggest_weight = weight
		end
		
		local tRef = t.variants
		for i=1,#variants do
			tRef[variants[i]] = true
		end

		return t
	end)
end

    return StatInterface