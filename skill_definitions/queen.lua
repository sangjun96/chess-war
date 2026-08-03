return {
    name = "Starfall Requiem",
    range = 5,
    effectRadius = 1,
    fps = 18,
    frameCount = 17,
    layers = {
        {
            image = "assets/skill-effects/combo/dark-bolt.png",
            frameWidth = 88, frameHeight = 88, frameCount = 8, fps = 20,
            scale = 1.0, offsetY = -34, directional = true,
        },
        {
            image = "assets/skill-effects/combo/queen-nova.png",
            frameWidth = 96, frameHeight = 96, frameCount = 10, fps = 18,
            scale = 1.55, offsetY = -38, delay = 0.06,
        },
        {
            image = "assets/skill-effects/combo/queen-sparkle.png",
            frameWidth = 64, frameHeight = 64, frameCount = 17, fps = 20,
            scale = 1.8, offsetY = -36, delay = 0.10,
        },
        {
            image = "assets/skill-effects/combo/arcane-fireworks.png",
            frameWidth = 96, frameHeight = 96, frameCount = 27, columns = 7, fps = 20,
            scale = 1.15, offsetY = -40, delay = 0.13,
        },
    },
}
