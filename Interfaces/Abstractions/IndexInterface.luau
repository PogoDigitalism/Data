local PlayerDataInterface = require(script.Parent.Parent.PlayerDataInterface)

local IndexInterface = {}

-------------------------------------------------------
function IndexInterface.killedEnemy(player: Player, enemyId: number, variant: number?)
	PlayerDataInterface.update(player, `stats.index.enemies.{enemyId}`, true, function(t)
		if not t then
			return {
				timesKilled = 1,
				killedVariants = {variant}
			}
		else
			if variant and not table.find(t.killedVariants, variant) then
				table.insert(t.killedVariants, variant)
			end

			t.timesKilled += 1

			return t
		end
	end)
end

function IndexInterface.addToCombatantIndex(player: Player, combatantId: number, variant: number?)
	PlayerDataInterface.update(player, `stats.index.buildings.{combatantId}`, true, function(t)
		if not t then
			return {
				unlockedVariants = {variant}
			}
		else
			if variant and not table.find(t.unlockedVariants, variant) then
				table.insert(t.unlockedVariants, variant)
			end
			return t
		end
	end)
end

function IndexInterface.killedBoss(player: Player, bossId: number, variant: number?)
	PlayerDataInterface.update(player, `stats.index.bosses.{bossId}`, true, function(t)
		if not t then
			return {
				timesKilled = 1,
				killedVariants = {variant}
			}
		else
			if variant and not table.find(t.killedVariants, variant) then
				table.insert(t.killedVariants, variant)
			end

			t.timesKilled += 1

			return t
		end
	end)
	
end

return IndexInterface