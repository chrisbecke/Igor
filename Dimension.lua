local addon, lib = ...
local UI = lib.UI
local ids = lib.ids


--[[ 
    dimensionitem:
    .scale                      number
    .pitch .yaw .roll           number
    .coordX .coordY .coordZ     number
    .id                         itemidentifier
    .icon                       assetparth
    .type                       typeid
    .name                       string
    .selected                   true
]]


local Queue = {
    pendingActions = {}
}

function Queue:Scale(id, amount)
  table.insert(self.pendingActions, {op="scale", amount=amount, id=id})
end

function Queue:Move(id, x, y, z)
  table.insert(self.pendingActions, {op="move", x=x, y=y, z=z, id=id})
end

function Queue:Rotate(id, pitch, roll, yaw)
  table.insert(self.pendingActions, {op="rotate", pitch=pitch, yaw=yaw, roll=roll, id=id})
end

function Queue:Place(id, x, y, z)
    table.insert(self.pendingActions, {op="place", id=id, params = {
        coordX = x, coordY = y, coordZ = z,
        -- set these to zero otherwise they default player values
        pitch = 0, yaw = 0, roll = 0
    }})
end
  

local lastFrameTime = 0
function Queue:tick(handle)
	if #self.pendingActions > 0 then
      local action = table.remove(self.pendingActions, 1)
	  if action.op == "place" then
	    Command.Dimension.Layout.Place(action.id, action.params)
	  end
	  if action.op == "scale" then
	    Command.Dimension.Layout.Place(action.id, {scale=action.amount})
	  end
	  if action.op == "move" then
	    Command.Dimension.Layout.Place(action.id, {coordX=action.x, coordY=action.y, coordZ=action.z})
	  end
	  if action.op == "rotate" then
	    Command.Dimension.Layout.Place(action.id, action.params)
	  end
	end
end

local Shapes = {
Cube = { x = 0.75, y = 0.75, z = 0.75, minScale = 0.25, maxScale = 5 },
Sphere = { x = 0.75, y = 0.75, z = 0.75, minScale = 0.25, maxScale = 5 },
Plank = { x = 2.25, y = 0.05, z = 0.25, minScale = 0.25, maxScale = 6 },
Pole = { x = 0.125, y = 1, z = 0.125, minScale = 0.25, maxScale = 12 },
Rectangle = { x = 1.125, y = 0.0375, z = 0.75, minScale = 0.25, maxScale = 12 },
Square = { x = 0.75, y = 0.0375, z = 0.75, minScale = 0.25, maxScale = 12 },
Disc = { x = 0.75, y = 0.0375, z = 0.75, minScale = 0.25, maxScale = 12 },
Triangle = { x = 1.0, y = 0.0375, z = 1.0, minScale = 0.25, maxScale = 12 },
}

local function GetBuildingBlockInfo(item)
  local material, shape = string.match('^Building Block: (.+) (.+)', item)
end

local selectedItems = {}

local function watchSelectedItems(item)
    if not item.selected then
        selectedItems[item.id] = nil
    else
        selectedItems[item.id] = item
    end
end

-- Signals that a dimension item has been added.
-- - addedItem - The dimension item that has been added.
local function didAddItem(handle, addedItem)
    Queue:tick()
    if #Queue.pendingActions == 0 then
        for item in ids(addedItem) do
            local detail = Inspect.Dimension.Layout.Detail(item)
            local name = item
            if detail and detail.name then name = detail.name end
--            print("Item Added: "..name)
        end
    end
end

-- Signals that a dimension item has been removed.
-- - removedItem - The dimension item that has been removed.
local function didRemoveItem(handle, removedItem)
    for item in ids(removedItem) do
        -- the itemId is returned, but there are no dimension details available
        -- for removed items
        local name = item
        local detail = Inspect.Dimension.Layout.Detail(item)
        if detail and detail.name then name = detail.name end
--        print("Item Removed: "..name)
    end
end

-- Signals that a dimension item has been updated.
-- - updatedItem - The dimension item that has been updated.
local function didUpdateItem(handle, updatedItem)
    for item in ids(updatedItem) do
        local detail = Inspect.Dimension.Layout.Detail(item)
        if detail and detail.id then 
            watchSelectedItems(detail)
            local suffix = ''
            if detail.selected then suffix = ' selected' end
            print("Item Updated: "..detail.name..suffix.."("..detail.type..")")

            local material, shape = detail.name:match('^Building Block: (.+) (.+)')
            if material and shape then 
            -- print('Material: '..material )
            -- print('Shape: '..shape)
            end
        end
    end
end

Command.Event.Attach(Event.Dimension.Layout.Add, didAddItem, "LayoutDidAddItem")
Command.Event.Attach(Event.Dimension.Layout.Remove, didRemoveItem, "LayoutDidRemoveItem")
Command.Event.Attach(Event.Dimension.Layout.Update, didUpdateItem, "LayoutDidUpdateItem")


--[[
    local name,selected = next(selectedItems)

    if not name then return end

    local targetType = selected.type
    local targetShape = nil
    local targetMaterial = nil
    local material, shape = detail.name:match('^Building Block: (.+) (.+)')

    local args = param:split("%s")
    if arg == string.sub('recurse',1,#arg) then


    if material then
        message = message.." building blocks"

        if param == 'shape' then
            targetShape = shape
        end
        if param == 'material' then
            targetMaterial = material
        end
    end

    print(message)
]]

-- pickupSelected picks up all items from the dimension that match
-- the selected items. The matching type is specified
--    match must be one of "type", "shape" or "material"
--    "type" must be used for anything thats not "Building Block:"
local function pickupSelected(match)
    local bigList = Inspect.Dimension.Layout.List()
    local selected = {}

    -- gets the list of selected items
    for dimItem, isCrated in pairs(bigList) do
        local detail = Inspect.Dimension.Layout.Detail(dimItem)
        if detail and detail.selected then
            selected[detail.id] = detail
        end
    end

    -- generate the filter criteria
    local filterList = {}
    if match=="shape" then
        for id,detail in pairs(selected) do
            local material, shape = detail.name:match('^Building Block: (.+) (.+)')
            filterList[shape]=true
        end
    elseif match=="material" then
        for id,detail in pairs(selected) do
            local material, shape = detail.name:match('^Building Block: (.+) (.+)')
            filterList[material]=true
        end
    else
        for id,detail in pairs(selected) do
            filterList[detail.type] = true
        end
    end

    -- Tellthe user why they are about to lag out
    print("Igor is picking up: "..table.concat(filterList,","))

    -- now run over the list again, and pick up all the marked items
    for dimitem, isCrated in pairs(bigList) do
        local detail = Inspect.Dimension.Layout.Detail(dimitem)
        if detail then 
            local material, shape = detail.name:match('^Building Block: (.+) (.+)')

            local pickup = false
            if match=="type" and filterList[detail.type] then pickup=true
            elseif match=="shape" and filterList[shape] then pickup=true
            elseif match=="material" and filterList[material] then pickup=true
            end

            if pickup then Command.Dimension.Layout.Pickup(dimitem) end
        end
    end
end

local function itemEnum(itemStacks)
    local itemStack = next(itemStacks)
    local stack = 0
    if itemStack then stack = itemStack.stack end
    return function()
        while itemStack do
            if stack > 0 then
                stack = stack - 1
                return itemStack
            end
            itemStack = next(itemStacks,itemStack)
            if itemStack then stack = itemStack.stack end
        end
        return nil
    end
end


local function buildUsingAnchor(anchor,match,maxX,maxY,maxZ)
    local material, shape = anchor.name:match('^Building Block: (.+) (.+)')
    if not shape then
        print("Igor can't build with non Building Blocks")
        return
    end

    local spec = Shapes[shape]
    if not spec then
        print("Igor doesn't understand the shape "..shape)
        return
    end

    -- build a list of items to place
    local itemsToPlace = {}
    local inventory = Inspect.Item.List(Utility.Item.Slot.Inventory())
    for slot,item in pairs(inventory) do
        if item then 
            local detail = Inspect.Item.Detail(item)
            if detail then
--                print('checking '..detail.name..' agianst '..anchor.name)
                local isMatch = false
                local testMaterial, testShape = detail.name:match('^Building Block: (.+) (.+)')
                if match == 'type' and anchor.type == detail.type then
--                    print('found match for '..detail.name..' by type '..detail.type)
                    isMatch = true
                elseif match == 'shape' and testShape == shape then
                    isMatch = true
                end
                if isMatch then 
--                    print('found match for '..detail.name..' by type '..detail.type)
                    itemsToPlace[detail] = true 
                end
            end
        end
    end

    local nextItem = itemEnum(itemsToPlace)

    -- perform a build, using the found items
    local startx=2
    local item = true
    for y = 1, maxY, 1 do
--        print(z)
        for z = 1, maxZ, 1 do
--            print(y)
            for x = startx, maxX, 1 do
--                print(x)
                item = nextItem()
                if not item then break end
                -- print('placing...'..item.name)

                Queue:Place(item.id,anchor.coordX + (x-1)*spec.x, anchor.coordY + (y-1)*spec.y,anchor.coordZ + (z-1)*spec.z)
            end
            if not item then break end
            startx=1
        end
        if not item then break end
    end
end

-- for each selected block Igor goes there and tries to build
-- using items from the players inventory.
local function buildOnSelected(match,maxX,maxY,maxZ)
    local bigList = Inspect.Dimension.Layout.List()
    local selected = {}

    -- gets the list of selected items
    for dimItem, isCrated in pairs(bigList) do
        local detail = Inspect.Dimension.Layout.Detail(dimItem)
        if detail and detail.selected then
            selected[detail.id] = detail
        end
    end

    for id,detail in pairs(selected) do
        buildUsingAnchor(detail,match,maxX,maxY,maxZ)
    end
    Queue:tick()
end

-- pickup expects there to be some dim items selected
-- Igor will pick up all items that match the items type by default
-- Items that are Building Blocks can additionally be picked up by matching
-- shape or material
lib.Command['pickup'] = function(param)
    if not param then 
        pickupSelected("type")
    elseif param == string.sub('shape',1,#param) then
        pickupSelected("shape")
    elseif param == string.sub('material',1,#param) then
        pickupSelected("material")
    else
    end
end

lib.Command['build'] = function(param)
    local params = param or ""
    local arg = params:split("%s")

    local maxX = 4
    local maxY = 9
    local maxZ = 1

    if #arg >= 3 then
        maxX = tonumber(arg[#arg-2])
        maxY = tonumber(arg[#arg-1])
        maxZ = tonumber(arg[#arg])
    end

    if #arg == 0 or #arg ==3 then 
        buildOnSelected('type',maxX,maxY,maxZ)
    elseif arg[1] == string.sub('shape',1,#arg[1]) then
        buildOnSelected("shape",maxX,maxY,maxZ)
    end
end
