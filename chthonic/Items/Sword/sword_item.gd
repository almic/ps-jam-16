class_name SwordItem extends CharacterBody3D

@export var movement_speed: float = 2
@export var slide_bounds: AABB = AABB(Vector3(-0.5, -0.25, 0), Vector3(1, 0.5, 0.5))

@export var left_right: GUIDEAction = preload("res://Resource/Input/CombatGeneral/action/left_right.tres")
@export var up_down: GUIDEAction = preload("res://Resource/Input/CombatGeneral/action/up_down.tres")

@export var swing_left: GUIDEAction = preload("res://Resource/Input/Sword/action/swing_left.tres")

var initial_pos: Vector3

func _ready() -> void:
    initial_pos = position

func _process(_delta: float) -> void:
    var camera = get_tree().root.get_camera_3d()
    velocity = camera.basis * (left_right.value_axis_3d + Vector3(0, up_down.value_axis_3d.x, 0)) * movement_speed

    if swing_left.is_triggered():
        print("swing left!")

    move_and_slide()

    var extent = position - initial_pos
    if not slide_bounds.has_point(extent):
        if extent.x > slide_bounds.end.x:
            extent.x = slide_bounds.end.x
        elif extent.x < slide_bounds.position.x:
            extent.x = slide_bounds.position.x

        if extent.y > slide_bounds.end.y:
            extent.y = slide_bounds.end.y
        elif extent.y < slide_bounds.position.y:
            extent.y = slide_bounds.position.y

        if extent.z > slide_bounds.end.z:
            extent.z = slide_bounds.end.z
        elif extent.z < slide_bounds.position.z:
            extent.z = slide_bounds.position.z

        position = initial_pos + extent
