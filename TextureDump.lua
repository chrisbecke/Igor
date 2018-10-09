






Igor_Textures = { sentinel = true }

Command.System.Texture.Record()

Command.Event.Attach(
    Event.System.Texture,
    function (handle, textures)
        print("Saving "..tostring(#textures)..' textures.')
        for key,value in pairs(textures) do
            Igor_Textures[tostring(key)] = tostring(value)
            --dvalue(value,key)
        end
    end,
    "OnTexture")