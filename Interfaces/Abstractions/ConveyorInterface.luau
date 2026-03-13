local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataInterface = require(script.Parent.Parent.PlayerDataInterface)
local AssetTypes = require(ReplicatedStorage.Shared.AssetInfo.AssetTypes)

local MetaInterface = {}

-------------------------------------------------------
function MetaInterface.getConveyorEgg(player: Player): string
    return PlayerDataInterface.get(player, "island_info.conveyor_egg")
end
function MetaInterface.getRecoveryEgg(player: Player): string
    return PlayerDataInterface.get(player, "island_info.recovery_egg")
end
function MetaInterface.setConveyorEgg(player: Player, eggData: AssetTypes.EggData)
    PlayerDataInterface.update(player, "island_info.conveyor_egg", true, function(_)
        return eggData
    end)
end
function MetaInterface.setRecoveryEgg(player: Player, eggData: AssetTypes.EggData)
    PlayerDataInterface.update(player, "island_info.recovery_egg", true, function(_)
        return eggData
    end)
end


function MetaInterface.getConveyor(player: Player): string
    return PlayerDataInterface.get(player, "island_info.conveyor_stage")
end
function MetaInterface.setConveyor(player: Player, conveyor: string)
    PlayerDataInterface.update(player, "island_info.conveyor_stage", true, function(_)
        return conveyor
    end)
end
function MetaInterface.addConveyor(player: Player, conveyor: string)
    PlayerDataInterface.update(player, "island_info.unlocked_conveyors", true, function(t)
        table.insert(
            t,
            conveyor
        )
        return t
    end)
end

return MetaInterface