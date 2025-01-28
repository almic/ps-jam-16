extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var tent_door: Area3D = %TentDoorArea
@onready var infini_level: Node3D = %"."

func _ready() -> void:
    tent_door.area_entered.connect(_on_tent_door_area_entered)
    tent_door.body_entered.connect(_on_tent_door_area_body_entered)
    tent_door.add_to_group(GROUP.TENT_DOOR)

func _on_tent_door_area_body_entered(body: Node3D) -> void:
    infini_level.tent_touch()
    pass # Replace with function body.


func _on_tent_door_area_entered(area: Area3D) -> void:
    pass
