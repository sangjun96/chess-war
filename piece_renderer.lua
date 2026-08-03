local PieceRenderer = {}
PieceRenderer.__index = PieceRenderer

local spriteSize = 32
local spriteBaseX = 16
local spriteBaseY = 30
local spriteLocations = {
    pawn = { 0, 0 },
    rook = { 1, 0 },
    knight = { 2, 0 },
    bishop = { 3, 0 },
    king = { 4, 0 },
    queen = { 4, 1 },
}

function PieceRenderer.new(assetPath, scale)
    local blue = love.graphics.newImage(assetPath .. "/Isocubic_Chess_Small_Pieces_Blue.png")
    local red = love.graphics.newImage(assetPath .. "/Isocubic_Chess_Small_Pieces_Red.png")
    local renderer = setmetatable({
        sheets = { blue = blue, red = red },
        quads = {},
        scale = scale or 1,
    }, PieceRenderer)

    for kind, location in pairs(spriteLocations) do
        renderer.quads[kind] = love.graphics.newQuad(
            location[1] * spriteSize,
            location[2] * spriteSize,
            spriteSize,
            spriteSize,
            blue:getDimensions()
        )
    end

    return renderer
end

function PieceRenderer:draw(piece, x, y)
    love.graphics.draw(
        self.sheets[piece.team],
        self.quads[piece.kind],
        x - spriteBaseX * self.scale,
        y - spriteBaseY * self.scale,
        0,
        self.scale,
        self.scale
    )
end

return PieceRenderer
