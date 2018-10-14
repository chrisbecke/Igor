local GuildBank = {}

function GuildBank.CanInteract()
    return Inspect.Interaction("guildbank")
end

local Bank = {}

function Bank.CanInteract()
    return Inspect.Interaction("guildbank")
end

local Auction = {}

function Auction.CanInteract()
    return Inspect.Interaction("auction")
end

local Mail = {}

function Mail.CanInteract()
    return Inspect.Interaction("mail")
end

local slot = Utility.Item.Slot.Inventory(1,1)

local type, param1, param2 = Utility.Item.Slot.Parse(slot)
-- dvalue(type,'type')
-- dvalue(param1,'param1')
-- dvalue(param2,"param2")


