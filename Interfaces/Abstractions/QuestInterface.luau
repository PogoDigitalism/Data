local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataInterface = require(script.Parent.Parent.PlayerDataInterface)
local Types = require(ReplicatedStorage.Shared.Data.Types)

local QuestInterface = {}

-------------------------------------------------------
function QuestInterface.getQuests(player: Player): {[string]: Types.quest}
	return PlayerDataInterface.get(player, "quests")
end
function QuestInterface.getQuest(player: Player, questId: string): Types.quest?
    return PlayerDataInterface.get(player, `quests.{questId}`)
end

function QuestInterface.createQuest(player: Player, questId: string, baseProgress: number)
    PlayerDataInterface.update(player, `quests.{questId}`, true, function(_)
        return {
            progress=baseProgress or 0,
            claimed=false
        }
    end)
end

function QuestInterface.updateQuest(player: Player, questId: string, progress: number)
    PlayerDataInterface.update(player, `quests.{questId}.progress`, true, function(_)
        return progress
    end)
end

function QuestInterface.completeQuest(player: Player, questId: string)
    PlayerDataInterface.update(player, `quests.{questId}.completed`, true, function(_)
        return true
    end)
end

function QuestInterface.destroyQuest(player: Player, questId: string)
    PlayerDataInterface.update(player, `quests.{questId}`, true, function(quest: Types.quest)
        return nil
    end)
end

return QuestInterface