local PlayerDataInterface = require(script.Parent.Parent.PlayerDataInterface)
local SettingsInterface = {}

-------------------------------------------------------
function SettingsInterface.setValue(player: Player, setting: string, value: any): number
    PlayerDataInterface.update(player, `settings.{setting}`, true, function(_)
        return value
    end)
end

function SettingsInterface.SetAutoSell(player: Player, type_: "rarities" | "variants", key: number, value: boolean)
    PlayerDataInterface.update(player, `settings.auto_sell.{type_}.{key}`, true, function(_)
        return value
    end)
end

function SettingsInterface.IsAutoSellEnabled(player: Player, type_: "rarities" | "variants", key: number): boolean
    return PlayerDataInterface.get(player, `settings.auto_sell.{type_}.{key}`)
end

return SettingsInterface