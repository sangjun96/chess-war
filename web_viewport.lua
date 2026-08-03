local WebViewport = {}
WebViewport.__index = WebViewport

local viewportScript = [[
(function () {
  var stage = document.getElementById('game-stage');
  if (!stage) return '';
  var rect = stage.getBoundingClientRect();
  return Math.max(320, Math.round(rect.width)) + 'x' + Math.max(280, Math.round(rect.height));
})()
]]

local function readViewport()
    if not love.js or not love.js.eval then return end
    local value = love.js.eval(viewportScript)
    local width, height = value:match("(%d+)x(%d+)")
    return tonumber(width), tonumber(height)
end

function WebViewport.new()
    return setmetatable({ elapsed = 1, width = 0, height = 0 }, WebViewport)
end

function WebViewport:apply(camera)
    local width, height = readViewport()
    if not width or (width == self.width and height == self.height) then return false end
    self.width, self.height = width, height
    love.window.setMode(width, height, {
        resizable = true,
        minwidth = 320,
        minheight = 280,
        highdpi = false,
    })
    if camera then camera:fitToViewport(width, height) end
    return true
end

function WebViewport:update(dt, camera)
    if not love.js or not love.js.eval then return end
    self.elapsed = self.elapsed + dt
    if self.elapsed < 0.35 then return end
    self.elapsed = 0
    self:apply(camera)
end

return WebViewport
