local TileBatchRenderer = require("tile_batch_renderer")

return function()
    local state = { draws = {}, added = {}, flushes = 0 }
    local atlas = {
        getDimensions = function() return 68, 18 end,
        setFilter = function(_, min, mag) state.filter = { min, mag } end,
    }
    local batch = {
        add = function(_, ...) state.added[#state.added + 1] = { ... } end,
        flush = function() state.flushes = state.flushes + 1 end,
    }
    love = { graphics = {
        newCanvas = function(width, height)
            assert(width == 68 and height == 18)
            return atlas
        end,
        newSpriteBatch = function(texture, capacity, usage)
            assert(texture == atlas and capacity == 16 and usage == "static")
            return batch
        end,
        newQuad = function(...) return { ... } end,
        push = function() end,
        pop = function() end,
        setCanvas = function() end,
        clear = function() end,
        setColor = function() end,
        draw = function(...) state.draws[#state.draws + 1] = { ... } end,
    } }
    local tile = { getDimensions = function() return 34, 18 end }
    local renderer = TileBatchRenderer.new({ lightTile = tile, darkTile = tile }, 4, 68)

    assert(#state.added == 16 and state.flushes == 1)
    assert(state.added[1][2] == -34 and state.added[1][3] == 0)
    assert(state.filter[1] == "nearest" and state.filter[2] == "nearest")
    assert(#state.draws == 2, "Building the atlas should draw both tile textures once.")
    renderer:draw()
    assert(#state.draws == 3 and state.draws[3][1] == batch,
        "The completed board should render with one draw submission per frame.")
end
