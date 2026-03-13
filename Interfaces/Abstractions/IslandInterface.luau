local PlayerDataInterface = require(script.Parent.Parent.PlayerDataInterface)

local PlotInterface = {}

-------------------------------------------------------
function PlotInterface.setPlotIsland(player: Player, island: string)
	PlayerDataInterface.update(player, "island_info.selected_island", true, function(_)
		return island
	end)
end
function PlotInterface.getPlotIsland(player: Player)
	return PlayerDataInterface.get(player, "island_info.selected_island")
end
function PlotInterface.increaseRebirth(player: Player)
	PlayerDataInterface.update(player, "island_info.rebirths", true, function(val)
		return val + 1
	end)
end
function PlotInterface.getRebirths(player: Player)
	return PlayerDataInterface.get(player, "island_info.rebirths")
end

return PlotInterface