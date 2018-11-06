local addon, lib = ...

-- Igors Minion Manager

-- Command.Minion.Send
-- Command.Minion.Claim

-- Inspect.Minion.Adventure.List
-- Inspect.Minion.Adventure.Detail
-- Inspect.Minion.Minion.Detail
-- Inspect.Minion.Minion.List
-- Inspect.Minion.Minion.Slot

-- Event.Minion.Adventure.Change
-- Event.Minion.Minion.Change

-- Adventure.List
-- [{ .mn.adv.5D270FE7742C66F1=true }]
--
-- Adventure.Detail
-- statArtifact
-- statAssasination = true
-- statEarth=true
-- statDimension
-- statWater
-- statLife
-- statDeath
-- statAir
-- statHunting
-- duration = 60 / 300 / 900 / 28800 / 14400
-- id='mn.adv.1F....'
-- costStamina=7
-- reward='material', 'artifact', 'dimension', 'material', 'experience', 'hunt'
-- costCredit=0
-- name='name'
-- costAdventurine=0
-- mode = nil, 'available', 

local function OnAdventureChange(handle, adventures)
    for key in pairs(adventures) do
        local adventure = Inspect.Minion.Adventure.Detail(key);
        if adventure then
            print('>'..adventure.id..' - '..tostring(adventure.mode)..' - '..adventure.name)
        else
            print('>'..key..' deleted')
        end
    end
end

Command.Event.Attach(Event.Minion.Adventure.Change,OnAdventureChange,"OnAdventureChange")