return {
    name = "Vanguard Breaker",
    range = 2,
    effectRadius = 0,
    fps = 18,
    frameCount = 7,
    layers = {
        {
            image = "assets/skill-effects/combo/vanguard-flash.png",
            frameWidth = 96, frameHeight = 48, frameCount = 8, columns = 2, fps = 24,
            scale = 0.95, offsetY = -24, directional = true,
        },
        {
            image = "assets/skill-effects/combo/vanguard-impact.png",
            frameWidth = 140, frameHeight = 50, frameCount = 7, fps = 20,
            scale = 1.25, offsetY = -18, delay = 0.03, directional = true,
        },
        {
            image = "assets/skill-effects/combo/arcane-spark.png",
            frameWidth = 32, frameHeight = 32, frameCount = 7, fps = 22,
            scale = 1.7, offsetY = -20, delay = 0.06,
        },
    },
}
