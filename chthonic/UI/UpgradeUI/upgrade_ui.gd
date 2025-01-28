extends Control

@onready var upgrade_1: Label = %Panel/Upgrade1
@onready var upgrade_2: Label = $Panel/Upgrade2
@onready var upgrade_3: Label = $Panel/Upgrade3
@onready var upgrade_4: Label = $Panel/Upgrade4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func updateUpgrades():
    upgrade_1.text = upgrade.Upgrade0
    upgrade_2.text = upgrade.Upgrade1
    upgrade_3.text = upgrade.Upgrade2
    upgrade_4.text = upgrade.Upgrade3
