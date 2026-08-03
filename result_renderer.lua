local ResultRenderer = {}

local teamName = { red = "RED", blue = "BLUE" }

local function teamColor(theme, team)
    return team == "red" and theme.redTeam or theme.blueTeam
end

local function buttonBounds()
    local width, height = love.graphics.getDimensions()
    local cardWidth = math.min(530, width - 24)
    local cardHeight = math.min(284, height - 24)
    local x, y = (width - cardWidth) / 2, (height - cardHeight) / 2
    local buttonWidth = (cardWidth - 68) / 2
    return {
        { action = "rematch", x = x + 24, y = y + cardHeight - 58, width = buttonWidth, height = 36 },
        { action = "menu", x = x + 44 + buttonWidth, y = y + cardHeight - 58, width = buttonWidth, height = 36 },
    }, x, y, cardWidth, cardHeight
end

function ResultRenderer.actionAt(x, y)
    for _, button in ipairs(buttonBounds()) do
        if x >= button.x and x <= button.x + button.width
            and y >= button.y and y <= button.y + button.height then return button.action end
    end
end

function ResultRenderer.draw(theme, fonts, flow, drawCard)
    local width, height = love.graphics.getDimensions()
    local color = teamColor(theme, flow.winner)
    local soft = flow.winner == "red" and theme.redTeamSoft or theme.blueTeamSoft
    local buttons, x, y, cardWidth, cardHeight = buttonBounds()
    love.graphics.setColor(theme.overlay)
    love.graphics.rectangle("fill", 0, 0, width, height)
    drawCard(theme, x, y, cardWidth, cardHeight, color, soft)
    love.graphics.setColor(theme.victory)
    love.graphics.setFont(fonts.body)
    love.graphics.printf("BATTLE COMPLETE", x, y + 30, cardWidth, "center")
    love.graphics.setColor(theme.text)
    love.graphics.setFont(fonts.resultTitle)
    love.graphics.printf(teamName[flow.winner] .. " TEAM WINS", x, y + 56, cardWidth, "center")
    love.graphics.setColor(theme.victorySoft)
    love.graphics.circle("fill", x + cardWidth / 2, y + 144, 38)
    love.graphics.setColor(color)
    love.graphics.setLineWidth(3)
    love.graphics.circle("line", x + cardWidth / 2, y + 144, 27)
    love.graphics.line(x + cardWidth / 2 - 14, y + 152, x + cardWidth / 2 + 14, y + 152)
    love.graphics.line(x + cardWidth / 2, y + 126, x + cardWidth / 2, y + 158)
    love.graphics.setColor(theme.muted)
    love.graphics.setFont(fonts.statusBody)
    love.graphics.printf(flow.status, x + 42, y + cardHeight - 98, cardWidth - 84, "center")
    for _, button in ipairs(buttons) do
        love.graphics.setColor(theme.actionFill)
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height, 9, 9)
        love.graphics.setColor(theme.panelEdge)
        love.graphics.rectangle("line", button.x, button.y, button.width, button.height, 9, 9)
        love.graphics.setColor(theme.text)
        love.graphics.setFont(fonts.body)
        local label = button.action == "rematch" and "R  REMATCH" or "M  DIFFICULTY"
        love.graphics.printf(label, button.x, button.y + 11, button.width, "center")
    end
end

return ResultRenderer
