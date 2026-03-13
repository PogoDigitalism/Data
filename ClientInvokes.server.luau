local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConstants = require(ReplicatedStorage.Shared.Constants.GameConstants)
local MetaInterface = require(script.Parent.Interfaces.Abstractions.MetaInterface)
local Update = require(ReplicatedStorage.Shared.Networking.Update)

Update.ReadLog:Connect(function(player, _)
    MetaInterface.readUpdateLogAction(player, GameConstants.UpdateVersion)
end)