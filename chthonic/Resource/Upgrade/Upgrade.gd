var rng = RandomNumberGenerator.new()
var selectedUpgrades = []
var selectedRarity = []
var finalUpgrades = []
var upgrades = {0: "Sharpness", 1: "Swing_Speed", 2: "Unmanned_Speed", 3: "Blood Multiplier", 4: "Blood Retainer", 5: "Subject_Toughness"}
var upgradesRarityBoost = {"Basic": 1, "Uncommon": 1.25, "Rare": 1.75, "Unique": 2.5}
const UPGRADE_UI = preload("res://UI/UpgradeUI/UpgradeUI.tscn")
var x = 0
var Upgrade0
var Upgrade1
var Upgrade2
var Upgrade3

func raritySelector():
    selectedUpgrades = []
    selectedRarity = []
    x = 0
    for x in 4:
        var rarity = rng.randf_range(0,100)
        if (rarity >= Rarity.Uncommon):
            selectedRarity.append('Basic')
        elif (rarity >= Rarity.Rare):
            selectedRarity.append('Uncommon')
        elif (rarity >= Rarity.Unique):
            selectedRarity.append('Rare')
        elif (rarity > Rarity.Legendary):
            selectedRarity.append('Unique')
        elif (rarity <= Rarity.Legendary):
            selectedRarity.append('Legendary')
    upgradeSelector()
    pass

func upgradeSelector():
    x = 0
    if (selectedRarity.find('Legendary')):
        selectedUpgrades = ['Lighting', 'Fire', 'Ice', 'Earth']
    else:
        for x in 4:
            var upgradesRan = rng.randi_range(0,5)
            selectedUpgrades.append(upgrades.get(upgradesRan))
            modifyUpgrades()

func modifyUpgrades():
    Upgrade0 = selectedRarity[0] + " " + selectedUpgrades[0]
    Upgrade1 = selectedRarity[1] + " " + selectedUpgrades[1]
    Upgrade2 = selectedRarity[2] + " " + selectedUpgrades[2]
    Upgrade3 = selectedRarity[3] + " " + selectedUpgrades[3]
    UPGRADE_UI.updateUpgrades()


enum Rarity {
    UnsetRarity = 0,
    Basic = 100,
    Uncommon = 61,
    Rare = 31,
    Unique = 6,
    Legendary = 1
}

enum Upgrades {
    Sharpness = 0,
    Swing_Speed = 1,
    Unmanned_Speed = 2, #how quickly you move unmanned
    Blood_Multiplier = 3, #how quickly you level
    Blood_Retainer = 4, #how quickly you die
    Subject_Toughness = 5
}
