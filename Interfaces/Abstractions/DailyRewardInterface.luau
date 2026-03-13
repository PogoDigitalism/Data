local PlayerDataInterface = require(script.Parent.Parent.PlayerDataInterface)

local DailyRewardInterface = {}

local SECONDS_PER_DAY = 86400

local function getUTCDay(timestamp: number): number
	return math.floor(timestamp / SECONDS_PER_DAY)
end

-------------------------------------------------------

function DailyRewardInterface.getLastClaimTime(player: Player): number
	return PlayerDataInterface.get(player, "meta.daily_login_claim_time")
end

function DailyRewardInterface.getRewardCount(player: Player): number
	return PlayerDataInterface.get(player, "meta.daily_reward_count")
end

function DailyRewardInterface.getStreak(player: Player): number
	return PlayerDataInterface.get(player, "meta.daily_login_streak")
end

function DailyRewardInterface.getUnclaimedCount(player: Player): number
	local lastClaimTime = DailyRewardInterface.getLastClaimTime(player)
	if lastClaimTime == 0 then
		return 1
	end
	local lastClaimedDay = getUTCDay(lastClaimTime)
	local currentDay     = getUTCDay(os.time())
	return math.min(7, math.max(0, currentDay - lastClaimedDay))
end

function DailyRewardInterface.canClaim(player: Player): boolean
	return DailyRewardInterface.getUnclaimedCount(player) > 0
end

function DailyRewardInterface.getTimeUntilNextDay(): number
	local now = os.time()
	local nextMidnight = (getUTCDay(now) + 1) * SECONDS_PER_DAY
	return nextMidnight - now
end

function DailyRewardInterface.claim(player: Player)
	local lastClaimTime = DailyRewardInterface.getLastClaimTime(player)

	local lastClaimedDay
	if lastClaimTime == 0 then
		lastClaimedDay = getUTCDay(os.time()) - 1
	else
		lastClaimedDay = getUTCDay(lastClaimTime)
	end

	PlayerDataInterface.update(player, "meta.daily_login_claim_time", true, function(_)
		return (lastClaimedDay + 1) * SECONDS_PER_DAY
	end)

	PlayerDataInterface.update(player, "meta.daily_reward_count", true, function(count)
		return count + 1
	end)
end

return DailyRewardInterface