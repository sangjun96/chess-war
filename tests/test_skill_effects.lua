local function installLoveMock(soundSkill)
    local state = { draws = {}, ellipses = {}, plays = 0, stops = 0 }
    love = {
        filesystem = {
            getInfo = function(path)
                if not soundSkill then return nil end
                local mp3 = "/" .. soundSkill .. ".mp3"
                local ogg = "/" .. soundSkill .. ".ogg"
                return (path:find(mp3, 1, true) or path:find(ogg, 1, true)) and {} or nil
            end,
        },
        audio = {
            newSource = function()
                return {
                    clone = function()
                        return {
                            play = function() state.plays = state.plays + 1 end,
                            stop = function() state.stops = state.stops + 1 end,
                            setPitch = function() end,
                            setVolume = function() end,
                            isPlaying = function() return true end,
                        }
                    end,
                }
            end,
        },
        graphics = {
            newImage = function(path)
                return {
                    path = path,
                    setFilter = function() end,
                    getDimensions = function() return 4096, 64 end,
                }
            end,
            newQuad = function(...) return { ... } end,
            setColor = function() end,
            setLineWidth = function() end,
            ellipse = function(...) table.insert(state.ellipses, { ... }) end,
            draw = function(...) table.insert(state.draws, { ... }) end,
        },
    }
    return state
end

return function()
    local state = installLoveMock(nil)
    package.loaded.skill_effects = nil
    package.loaded.skill_audio = nil
    local SkillEffects = require("skill_effects")
    local effects = SkillEffects.new()
    effects:load()
    effects:trigger("impact", 0, 0, 1, 0)
    effects:trigger("lightning", 0, 0, 0, 1)
    assert(#effects.active == 2)

    effects:update(1 / 15 + 0.001)
    assert(effects.active[1].frame == 2 and effects.active[2].frame == 2)
    effects:update(0.08)
    local camera = { worldToIso = function(_, x, y) return x - y, (x + y) / 2 end }
    effects:draw({ cellSize = 68 }, camera)
    assert(#state.draws >= 5, "Pawn and knight attacks should build from layered motion phases.")
    assert(math.abs(state.draws[1][5]) > 0.01)

    effects:update(10)
    assert(#effects.active == 0)

    state = installLoveMock(nil)
    package.loaded.skill_effects = nil
    package.loaded.skill_effect_renderer = nil
    package.loaded.skill_audio = nil
    SkillEffects = require("skill_effects")
    effects = SkillEffects.new()
    effects:load()
    local secondRowQuad = effects.animations.sparkle[5].quads[11]
    assert(secondRowQuad[1] == 0 and secondRowQuad[2] == 96,
        "Multi-row spritesheets should advance to the next row.")
    effects:trigger("royal_calamity", 0, 0, 1, 0)
    effects:update(0.40)
    effects:draw({ cellSize = 68 }, camera)
    assert(#state.draws == 6, "Royal Calamity should show its cast, strike, and aftermath layers.")

    state = installLoveMock("knight")
    package.loaded.skill_effects = nil
    package.loaded.skill_audio = nil
    SkillEffects = require("skill_effects")
    effects = SkillEffects.new()
    effects:load()
    effects:trigger("lightning", 0, 0, 1, 1)
    effects:trigger("lightning", 0, 0, 1, 1)
    assert(state.plays == 0, "The thunder cue should wait for the projectile impact.")
    effects:update(0.2)
    effects:draw({ cellSize = 68 }, camera)
    local projectile = state.draws[1]
    local targetX, targetY = 0, 102
    assert(projectile[3] ~= targetX or projectile[4] ~= targetY,
        "Directional projectiles should travel instead of appearing on the target.")
    effects:update(0.2)
    assert(state.plays == 1, "A formation volley should play one shared skill cue.")
    effects:draw({ cellSize = 68 }, camera)
    assert(#state.ellipses > 0, "A timed impact ring should reinforce the hit frame.")
    effects:update(0.95)
    assert(state.stops == 1, "Long source clips should fade and stop with the visual effect.")
end
