local CreditsOverlay = {}
CreditsOverlay.__index = CreditsOverlay

local credits = {
    "Chess tiles and pieces",
    "Isocubic Chess FREE - Chess Set by Nikoichu",
    "CC BY-NC-SA 4.0. Adapted for Chess War; non-commercial use only.",
    "nikoichu.itch.io/isocubic-chess-free",
    "",
    "Combat effects",
    "Super Pixel Effects Gigapack (Free Version) by Will Tice / unTied Games",
    "Used under the pack license. Attribution required.",
    "",
    "Magic effects",
    "Free Magic Pack 9 by Luis Zuno (ansimuz), CC0.",
    "",
    "Sound effects",
    "Generated with ElevenLabs.",
}

function CreditsOverlay.new(theme)
    return setmetatable({ theme = theme, open = false }, CreditsOverlay)
end

function CreditsOverlay:toggle()
    self.open = not self.open
end

function CreditsOverlay:close()
    self.open = false
end

function CreditsOverlay:buttonBounds()
    return 20, 64, 104, 30
end

function CreditsOverlay:mousepressed(x, y)
    if self.open then
        self:close()
        return true
    end

    local left, top, width, height = self:buttonBounds()
    if x >= left and x <= left + width and y >= top and y <= top + height then
        self:toggle()
        return true
    end
    return false
end

function CreditsOverlay:keypressed(key)
    if key == "c" then
        self:toggle()
        return true
    end
    if key == "escape" and self.open then
        self:close()
        return true
    end
    return false
end

function CreditsOverlay:drawButton(font)
    local left, top, width, height = self:buttonBounds()
    love.graphics.setColor(self.theme.panel)
    love.graphics.rectangle("fill", left, top, width, height, 8, 8)
    love.graphics.setColor(self.theme.panelEdge)
    love.graphics.rectangle("line", left, top, width, height, 8, 8)
    love.graphics.setColor(self.theme.muted)
    love.graphics.setFont(font)
    love.graphics.printf("C  CREDITS", left, top + 9, width, "center")
end

function CreditsOverlay:draw(fonts)
    self:drawButton(fonts.body)
    if not self.open then return end

    local width, height = love.graphics.getDimensions()
    local panelWidth = math.min(650, width - 48)
    local panelHeight = math.min(570, height - 48)
    local left = (width - panelWidth) / 2
    local top = (height - panelHeight) / 2

    love.graphics.setColor(self.theme.overlay)
    love.graphics.rectangle("fill", 0, 0, width, height)
    love.graphics.setColor(self.theme.panel)
    love.graphics.rectangle("fill", left, top, panelWidth, panelHeight, 14, 14)
    love.graphics.setColor(self.theme.panelEdge)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", left, top, panelWidth, panelHeight, 14, 14)

    love.graphics.setColor(self.theme.text)
    love.graphics.setFont(fonts.title)
    love.graphics.printf("Credits & Licenses", left + 28, top + 28, panelWidth - 56, "left")
    love.graphics.setColor(self.theme.muted)
    love.graphics.setFont(fonts.body)
    love.graphics.printf("Full links and license texts are available on the web Credits page.",
        left + 28, top + 58, panelWidth - 56, "left")

    local y = top + 96
    for _, line in ipairs(credits) do
        if line == "" then
            y = y + 9
        else
            love.graphics.setColor(line:find("CC ") and self.theme.victory or self.theme.text)
            love.graphics.printf(line, left + 28, y, panelWidth - 56, "left")
            y = y + 24
        end
    end

    love.graphics.setColor(self.theme.muted)
    love.graphics.printf("Press C, Esc, or click anywhere to close.", left + 28, top + panelHeight - 38,
        panelWidth - 56, "center")
end

return CreditsOverlay
