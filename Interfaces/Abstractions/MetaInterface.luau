local PlayerDataInterface = require(script.Parent.Parent.PlayerDataInterface)

local MetaInterface = {}

-------------------------------------------------------
function MetaInterface.readUpdateLogAction(player: Player, _version: number)
    PlayerDataInterface.update(player, "meta.read_update_log", true, function(v)
        return _version
    end)
end

function MetaInterface.getPreviousLogin(player: Player): number
	return PlayerDataInterface.get(player, "meta.previous_login")
end

function MetaInterface.getCurrentLogin(player: Player): number
	return PlayerDataInterface.get(player, "meta.latest_login")
end

function MetaInterface.getLogoutTime(player:  Player)
    return PlayerDataInterface.get(player, "meta.logout_time")
end

function MetaInterface.inTutorial(player: Player): boolean
    local stage = PlayerDataInterface.get(player, "meta.tutorial_stage")
    if stage == "none" or stage == "completed" then
        return false
    else
        return true
    end
end
function MetaInterface.getTutorial(player:  Player): string
    return PlayerDataInterface.get(player, "meta.tutorial_stage")
end

function MetaInterface.setTutorialStage(player: Player, stage: string): boolean
    PlayerDataInterface.update(player, "meta.tutorial_stage", true, function(_)
        return stage
    end)
end

function MetaInterface.setTutorialDecision(player: Player, decision: boolean)
	PlayerDataInterface.update(player, "meta", true, function(meta)
		meta.show_tutorial_popup = false
		
		if decision then
			meta.tutorial_stage = "acceptedIntro"
		end
	end)
end

function MetaInterface.getLoggedEvents(player: Player)
    return PlayerDataInterface.get(player, "stats.logs")
end

function MetaInterface.getOnboardingFunnels(player: Player): {number?}
	return PlayerDataInterface.get(player, "meta.funnels.onboarding")
end
function MetaInterface.logOnboardingStep(player: Player, step: number)
	PlayerDataInterface.update(player, "meta.funnels.onboarding", true, function(list)
		table.insert(list, step)
		return list
	end)
end

function MetaInterface.logEvent(player: Player, eventId: string, value: any)
	PlayerDataInterface.update(player, "stats.logs", true, function(logs)
        logs[eventId] = value
    end)
end

--function MetaInterface.hasGamepass(player: Player, gamepassId: number)
--    return PlayerDataInterface.get(player, `meta.gamepasses.{gamepassId}`) or false
--end
--function MetaInterface.addGamepass(player: Player, gamepassId: number) 
--	return PlayerDataInterface.update(player, `meta.gamepasses`, true, function(entry) 
--        return true
--    end)
--end

function MetaInterface.getDevProduct(player: Player, devProductId: number): number?
	--print(PlayerDataInterface.get(player, "meta.purchased_products."..devProductId), devProductId)
	return PlayerDataInterface.get(player, `meta.purchased_products.{tostring(devProductId)}`)
end

function MetaInterface.addDevProduct(player: Player, devProductId: number)
	PlayerDataInterface.update(player, `meta.purchased_products.{devProductId}`, true, function(entry)
		if not entry then
			return 1
		end
		return entry + 1
	end)
end

function MetaInterface.hasGamepass(player: Player, gamepassId: number)
	return PlayerDataInterface.get(player, `meta.purchased_products.{gamepassId}`) or false
end
function MetaInterface.addGamepass(player: Player, gamepassId: number)
	PlayerDataInterface.update(player, `meta.purchased_products.{gamepassId}`, true, function(entry)
		if not entry then
			return 1
		end
		return entry + 1
	end)
end

return MetaInterface