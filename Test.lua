local addon, lib = ...
-- access CreateFrame extensions.
local UI = lib.UI

local function didMove()
end

local context = UI.CreateContext('Test')

--[[
local window = UI.CreateFrame('RiftWindow',"Test",context)

local function didClose()
    window:SetVisible(false)
end

window:EnableClose( didClose )
window:EnableDrag( didMove )
]]

Backgrounds = {
    ConquestDominion = 'window_conquest_dominion.png.dds', -- 512x512
    ConquestNightfall = 'window_conquest_nightfall.png.dds', -- 512x512
    ConquestOathsworn = 'window_conquest_oathsworn.png.dds',

    LargeYellow = 'window_large_bg_(yellow).png.dds', -- 1024x512 ancient

    MediumGreen = 'window_med_bg_(green).png.dds', -- 512x512
    MediumBlueRed = 'window_med_blue+red.png.dds', -- 512x512

}

Frames = {
    -- RiftWindow Frames
    MainMap = "window_mainmap.png.dds", -- 512x512 RiftWindowframe with alpha cutout

    -- 'deco' Frames
    SmallPopup = 'window_popup.small.png.dds',          -- 128x128
    SmallPopupSelected = 'window_popup_small.png.dds'   -- 128x128
}

-- bag bar
BagBar = {
    Slot = 'bagslot.png.dds' - 64x64
    Locked = 'slot_bag_imprint_(locked).png.dds', -- 64x64 Locked Bag Bar Slot
    Normal = 'slot_bag_impront_(normal).png.dds', -- 64x64 empty Bag Bar Slot
    Frame = '', -- frame around bag slot
    Rift = '' -- Ascended Editions icon
}

SmallIconBorders = {
    Normal = 'sml_icon_border.png.dds',                 -- 32x32
    Down = 'sml_icon_border_(click)_blue.png.dds',      -- 32x32
    Over = 'sml_icon_border_(over)_blue.png.dds',       -- 32x32
    Over2 = 'sml_icon_border_(over)_yellow.png.dds',    -- 32x32
    Dark = 'sml_icon_border_darken.png.dds'             -- 32x32
}

SubWindows = {
    Normal = 'sub_window_02.png.dds',           -- 128x128
    Grey = 'sub_window_02_grey.png.dds',        -- 256x256
    Teal = 'sub_window_02_teal.png.dds',        -- 128x128
    Blue = 'sub_window_blue.png.dds',           -- 128x128
    Red  = 'sub_window_red.png.dds',            -- 128x128
}

TabControl = {
    Selected = 'tab_(on).png.dds',              -- 128x32
    Normal = 'tab_(off).png.dds'                -- 128x32
}

Separators = {
    Underscore = 'underscore.png.dds'              -- 152x16 "---===o===---"
}

RaidFrames = {
    'raid_frame_aggro.png.dds', -- 64x64
    'raid_frame_bg.png.dds',
    'raid_Frame_click.png.dds',
    'raid_frame_targeted.png.dds',

}


AdventureCard = {
    TopBackground = 'minion_adventures_001(water_fire).png.dds', =-- 206x116 001..062
    BottomBackground = '',
    Frame = '',
    RewardType = '',
    Banner = '',
    StaminaIcon = '',
    Badge = '',
    stat1Icon = '',
    stat2Icon = ''
}

MinionCard = {
    Background = '',
    Separator = '',
    LevelBadge = 'seasonal_loyalty_ring.png.dds',
    LevelBadgeXpRing = 'seasonal_loyalty_ring.png.dds',
    MinionIcon = '',
    RaidFrame = '',
    Name = 'Rudy',
    StaminaIcon = '',
    stat1Icon = '',
    stat2Icon = '',
    LevelBadge = '',
    Level = '9',
    stamina = '6/18',
    stat1Text = '9',
    stat2Text = '8'
}

SlotCard = {
    Background = '',
    Banner = '',
    RewardType = '',
    riftbutton = 'HURRY', -- 'CLAIM'
    minionFrame = '',
    minionIcon = ''
}

MinionStuff = {
    AdventurineIcon = 'adventurine_01.dds' -- 48x48
}

local smallWindow = UI.CreateFrame("SmallWindow","SmallWindow",context)
smallWindow:EnableDrag()
local closeButton = UI.CreateFrame("RiftButton","CloseButton",smallWindow)
closeButton:SetText('Close')
local content = smallWindow:GetContent()
closeButton:SetPoint(0.5,1,content,0.5,1,0,-4)


-- local strataList = { 'implementation', 'main'}
-- local strata = main
-- local strataList = smallFrameBg:GetStrataList()
-- fulldump(strataList)
-- local strata = smallFrameBg:GetStrata()
-- fulldump(strata)
