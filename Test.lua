local addon, data = ...

-- Signals that a dimension item has been added.
-- - addedItem - The dimension item that has been added.
local function didAddItem(handle, addedItem)
    print("Dimension.Layout.didAddItem")
    fulldump(addedItem)
end

-- Signals that a dimension item has been removed.
-- - removedItem - The dimension item that has been removed.
local function didRemoveItem(handle, removedIte)
    print("Dimension.Layout.didRemoveItem")
end

-- Signals that a dimension item has been updated.
-- - updatedItem - The dimension item that has been updated.
local function didUpdateItem(handle, updatedItem)
    print("Dimension.Layout.didUpdateItem")
end

Command.Event.Attach(Event.Dimension.Layout.Add, didAddItem, "LayoutDidAddItem")
Command.Event.Attach(Event.Dimension.Layout.Remove, didRemoveItem, "LayoutDidRemoveItem")
Command.Event.Attach(Event.Dimension.Layout.Update, didUpdateItem, "LayoutDidUpdateItem")
