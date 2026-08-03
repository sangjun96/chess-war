return {
    name = "Thunder Charge",
    range = 4,
    effectRadius = 0,
    fps = 18,
    frameCount = 10,
    layers = {
        {
            image = "assets/skill-effects/combo/dark-bolt.png",
            frameWidth = 88, frameHeight = 88, frameCount = 8, fps = 20,
            scale = 1.1, offsetY = -34, directional = true,
        },
        {
            image = "assets/skill-effects/royal-calamity/crown-lightning.png",
            frameWidth = 128, frameHeight = 128, frameCount = 5, fps = 20,
            scale = 1.05, offsetY = -42, delay = 0.04, directional = true,
        },
        {
            image = "assets/skill-effects/combo/thunder-burst.png",
            frameWidth = 96, frameHeight = 96, frameCount = 10, fps = 20,
            scale = 1.2, offsetY = -34, delay = 0.10,
        },
    },
}
