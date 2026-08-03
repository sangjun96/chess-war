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
local damageShaderCode = [[
extern number damage;

vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords) {
    vec4 pixel = Texel(texture, textureCoords) * color;
    number gray = dot(pixel.rgb, vec3(0.299, 0.587, 0.114));
    pixel.rgb = mix(pixel.rgb, vec3(gray), damage);
    pixel.rgb *= 1.0 - damage * 0.32;
    return pixel;
}
]]

function PieceRenderer.new(assetPath, scale)
    local blue = love.graphics.newImage(assetPath .. "/Isocubic_Chess_Small_Pieces_Blue.png")
    local red = love.graphics.newImage(assetPath .. "/Isocubic_Chess_Small_Pieces_Red.png")
    local renderer = setmetatable({
        sheets = { blue = blue, red = red },
        quads = {},
        scale = scale or 1,
        damageShader = love.graphics.newShader(damageShaderCode),
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
    local damage = (1 - piece.hp / piece.maxHp) * 0.85
    love.graphics.setColor(1, 1, 1, 1)
    self.damageShader:send("damage", damage)
    love.graphics.setShader(self.damageShader)
    love.graphics.draw(
        self.sheets[piece.team],
        self.quads[piece.kind],
        x - spriteBaseX * self.scale,
        y - spriteBaseY * self.scale,
        0,
        self.scale,
        self.scale
    )
    love.graphics.setShader()
end

return PieceRenderer
