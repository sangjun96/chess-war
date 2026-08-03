local ResultRenderer = require("result_renderer")

local Router = {}

function Router.install(config)
    local function resultPress(x, y)
        if config.credits:mousepressed(x, y) then return end
        local action = ResultRenderer.actionAt(x, y)
        if action == "rematch" then config.rematch()
        elseif action == "menu" then config.showDifficulty() end
    end

    local function startFromDifficulty(x, y, button)
        local difficulty = config.difficulty:mousepressed(x, y, button)
        if difficulty then config.startGame(difficulty) end
    end

    function love.mousepressed(x, y, button)
        local flow, input = config.flow(), config.input()
        if config.difficulty.active then startFromDifficulty(x, y, button)
        elseif flow and flow.finished then resultPress(x, y)
        elseif input then input:mousepressed(x, y, button) end
    end

    function love.mousereleased(x, y, button)
        local input = config.input()
        if input and not config.difficulty.active then input:mousereleased(x, y, button) end
    end

    function love.mousemoved(x, y, dx, dy)
        local input = config.input()
        if input and not config.difficulty.active then input:mousemoved(x, y, dx, dy) end
    end

    function love.wheelmoved(x, y)
        local input = config.input()
        if input and not config.difficulty.active then input:wheelmoved(x, y) end
    end

    function love.touchpressed(id, x, y)
        local flow, input = config.flow(), config.input()
        if config.difficulty.active then startFromDifficulty(x, y, 1)
        elseif flow and flow.finished then resultPress(x, y)
        elseif input then input:touchpressed(id, x, y) end
    end

    function love.touchmoved(id, x, y, dx, dy)
        local flow, input = config.flow(), config.input()
        if input and not config.difficulty.active and not flow.finished then input:touchmoved(id, x, y, dx, dy) end
    end

    function love.touchreleased(id, x, y)
        local flow, input = config.flow(), config.input()
        if input and not config.difficulty.active and not flow.finished then input:touchreleased(id, x, y) end
    end
end

return Router
