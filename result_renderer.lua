local ResultRenderer = {}

local teamName = { red = "RED", blue = "BLUE" }

local function teamColor(theme, team)
    return team == "red" and theme.redTeam or theme.blueTeam
end

function ResultRenderer.draw(theme, fonts, flow, drawCard)
    local width, height = love.graphics.getDimensions()
    local color = teamColor(theme, flow.winner)
    local soft = flow.winner == "red" and theme.redTeamSoft or theme.blueTeamSoft
    local cardWidth, cardHeight = math.min(530, width - 48), 284
    local x, y = (width - cardWidth) / 2, (height - cardHeight) / 2
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
    love.graphics.printf(flow.status, x + 42, y + 194, cardWidth - 84, "center")
    love.graphics.setColor(theme.panelEdge)
    love.graphics.line(x + 34, y + 235, x + cardWidth - 34, y + 235)
    love.graphics.setColor(theme.muted)
    love.graphics.setFont(fonts.body)
    love.graphics.printf("R  REMATCH     M  DIFFICULTY MENU", x, y + 246, cardWidth, "center")
end

return ResultRenderer
