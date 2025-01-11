Config = {}

Config.Surprises = {
	{
        name = "Lion",
        model = "a_c_lionmangy_01",
        isAggressive = true,
        spawnDistance = 4.0,
        notifyTitle = "LIONS APPEAR",
        notifyMessage = "RUN FOR YOUR LIFE!",
        roarSound = "LION_ROAR",
        rewardChance = 30, -- 30% chance to drop reward
		effectScale = 1.0,
        rewards = {
            {item = "raw_meat", amount = 2},
        }
    },
    {
        name = "Legendary Panther",
        model = "A_C_Panther_01",
        isAggressive = true,
        spawnDistance = 4.0,
        notifyTitle = "LEGENDARY PANTHERS EMERGES",
        notifyMessage = "THE HUNT IS ON!",
        roarSound = "PANTHER_ROAR",
        rewardChance = 40,
		effectScale = 1.0,
        rewards = {
            {item = "raw_meat", amount = 2},
            
        }
    },
    {
        name = "Bear",
        model = "A_C_Bear_01",
        isAggressive = true,
        spawnDistance = 4.0,
        notifyTitle = "BEARS CHARGE",
        notifyMessage = "STAND YOUR GROUND!",
        roarSound = "BEAR_ROAR",
        rewardChance = 35,
		effectScale = 1.0,
        rewards = {
            {item = "raw_meat", amount = 2},
            
        }
    },
    {
        name = "Snake",
        model = "A_C_Snake_01",
        isAggressive = true,
        spawnDistance = 2.0,
		effectScale = 1.0,
        notifyTitle = "SNAKES APPEAR",
        notifyMessage = "WATCH OUT!"
    },
    {
        name = "Wolf",
        model = "A_C_WOLF",
        isAggressive = true,
        spawnDistance = 3.0,
		effectScale = 1.0,
        notifyTitle = "WOLVES EMERGE",
        notifyMessage = "BE CAREFUL!"
    },
    {
        name = "Rabbit",
        model = "A_C_Rabbit_01",
        isAggressive = false,
        spawnDistance = 2.0,
		effectScale = 1.0,
        notifyTitle = "RABBITS HOP OUT",
        notifyMessage = "HOW CUTE!"
    },
    {
        name = "Chicken",
        model = "A_C_CHICKEN_01",
        isAggressive = false,
        spawnDistance = 2.0,
		effectScale = 1.0,
        notifyTitle = "CHICKENS APPEAR",
        notifyMessage = "CLUCK CLUCK!"
    },
	{
        name = "Cat",
        model = "a_c_cat_01",
        isAggressive = false,
        spawnDistance = 2.0,
		effectScale = 1.0,
        notifyTitle = "CATS APPEAR",
        notifyMessage = "PURR PURR!"
    },
	{
        name = "Dog",
        model = "a_c_dogpoodle_01",
        isAggressive = false,
        spawnDistance = 2.0,
		effectScale = 1.0,
        notifyTitle = "DOGS APPEAR",
        notifyMessage = "GRRR GRRR!"
    },
    {
        name = "Coyote",
        model = "A_C_COYOTE_01",
        isAggressive = true,
        spawnDistance = 3.0,
		effectScale = 1.0,
        notifyTitle = "COYOTES APPEAR",
        notifyMessage = "LOOK ALIVE!"
    }
}

Config.BoxProp = {
    model = "p_ammoboxlancaster01x",
    placementDistance = 1.5, -- How far in front of player to place box
    deleteDelay = 4000 -- How long to wait before deleting the box
}

Config.Effects = {
    screenShake = true
}

-- Rewards Configuration
Config.RewardExp = 50 -- XP for killing aggressive animals
Config.LootableAnimals = true -- Enable/disable animal looting
Config.RarityChances = {
    common = 60,
    uncommon = 25,
    rare = 10,
    legendary = 5
}
