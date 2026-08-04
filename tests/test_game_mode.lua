local GameMode = require("game_mode")

return function()
    local player = GameMode.resolve("medium")
    assert(player.redDifficulty == "medium" and not player.automated)

    local demo = GameMode.resolve("hard_vs_hard")
    assert(demo.automated and demo.redDifficulty == "hard" and demo.blueDifficulty == "hard")
end
