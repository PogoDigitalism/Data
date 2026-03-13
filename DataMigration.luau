--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DevTemplate = require(ReplicatedStorage.Shared.Data.Templates.DevTemplate)
local Configs = require(script.Configs)

local DataMigration = {}

local CURRENT_MIGRATION_VERSION = script.Parent.MIGRATION_VERSION.Value

type template = typeof(DevTemplate)

local MIGRATIONS: {
    [number]: (playerData: template) -> ()
} = {
    -- EXAMPLE
    [999] = function(playerData: template)
        -- TODO EXAMPLE
    end,

    [0] = function(playerData: template) end
    -- EXAMPLE
}
if not MIGRATIONS[CURRENT_MIGRATION_VERSION] then
    error(`CURRENT_MIGRATION_VERSION {CURRENT_MIGRATION_VERSION} has no migration function`)
end

function DataMigration.applyMigration(playerData: template)
    local meta = playerData.meta
    local migration_version = meta.migration_version or 0
    
    while migration_version < CURRENT_MIGRATION_VERSION do
        local nextVersion = migration_version + 1
        local migrationFunc = MIGRATIONS[nextVersion]
        
        if not migrationFunc then
            error(`No migration version for {nextVersion}`)
        end
        
        migrationFunc(playerData)
        migration_version = nextVersion
        
        meta.migration_version = migration_version
    end
end

return DataMigration
