local Camera = require("camera")

return function()
    local previousLove = love
    love = { graphics = { getDimensions = function() return 390, 800 end } }
    local camera = Camera.new(1088)
    camera:fitToViewport(390, 800)
    assert(camera.zoom == 0.55 and camera.homeZoom == 0.55)

    camera:zoomAt(195, 400, 1)
    assert(camera.zoom > camera.homeZoom)
    camera:reset()
    assert(camera.zoom == 0.55 and camera.x == 544 and camera.y == 544)
    camera:pan(100000, 100000)
    assert(camera.x >= 0 and camera.x <= 1088 and camera.y >= 0 and camera.y <= 1088)
    love = previousLove
end
