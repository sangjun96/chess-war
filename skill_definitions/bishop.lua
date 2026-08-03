return {
    name = "Arcane Judgment",
    range = 3,
    effectRadius = 1,
    fps = 16,
    frameCount = 27,
    layers = {
        {
            image = "assets/skill-effects/combo/arcane-light.png",
            frameWidth = 256, frameHeight = 144, frameCount = 9, fps = 15,
            scale = 0.78, offsetY = -38,
        },
        {
            image = "assets/skill-effects/combo/arcane-spark.png",
            frameWidth = 32, frameHeight = 32, frameCount = 7, fps = 22,
            scale = 2.4, offsetY = -30, delay = 0.05,
        },
        {
            image = "assets/skill-effects/combo/arcane-fireworks.png",
            frameWidth = 96, frameHeight = 96, frameCount = 27, columns = 7, fps = 18,
            scale = 1.05, offsetY = -36, delay = 0.10,
        },
    },
}
