extends Control
@onready var label: Label = %Panel/Label
const LEVEL_INFIN = preload("res://Scenes/Levels/Level Infin/LevelInfin.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    label.text = "Distance Traveled: " + LEVEL_INFIN.total_distance_traveled
    pass
