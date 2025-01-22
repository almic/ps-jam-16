# Allows us to see the sword in-editor
@tool

class_name Player extends WeaponController

@export_range(0.1, 2) var movement_speed: float = 1.5

@export_category("Input")
@export var move: GUIDEAction
@export var travel_mapping_context: GUIDEMappingContext

var camera_locked: bool = false
var next_move: WeaponMove = null

@onready var first_person_marker: Marker3D = %FirstPersonMarker
@onready var third_person_marker: Marker3D = %ThirdPersonMarker
@onready var camera: Camera3D = %Camera

func _ready() -> void:
    super._ready()
    exit_combat()

func _process(delta: float) -> void:
    if Engine.is_editor_hint():
        return

    # Process input per-frame, but doesn't do movement yet
    if not in_combat:
        do_move_input(delta)
    elif velocity.length_squared() > 0:
        velocity = Vector3()

    pass

func _physics_process(delta: float) -> void:
    if Engine.is_editor_hint():
        return

    super._physics_process(delta)

    if not in_combat and not is_on_floor():
        velocity += get_gravity() * delta

    if velocity.length_squared() > 0:
        move_and_slide()

    pass

func enter_combat(_ignored: bool = false) -> void:
    super.enter_combat(true)
    print("Player entering combat!")

    # Move camera into position
    camera.reparent(first_person_marker, true)
    camera_locked = true # Lock camera motion
    var tween = get_tree().create_tween()
    tween.set_parallel()
    tween.tween_property(camera, "position", Vector3(), 0.8)
    tween.tween_property(camera, "rotation", Vector3(), 0.8)

    # Make weapon follow mouse, turn off travel
    weapon_obj.user_input_enabled = true
    GUIDE.disable_mapping_context(travel_mapping_context)

func exit_combat(_ignored: bool = false) -> void:
    super.exit_combat(true)

    # Move camera into position
    camera.reparent(third_person_marker, true)
    camera_locked = false # Unlock camera motion
    var tween = get_tree().create_tween()
    tween.set_parallel()
    tween.tween_property(camera, "position", Vector3(), 0.8)
    tween.tween_property(camera, "rotation", Vector3(), 0.8)

    # Stop weapon follow, enable travel
    weapon_obj.user_input_enabled = false
    GUIDE.enable_mapping_context(travel_mapping_context)


func _should_act() -> bool:
    if not stance == Combat.Stance.Idle:
        return false

    for weapon_move in weapon.move_set.moves:
        if weapon_move.action.is_triggered():
            next_move = weapon_move
            print("Activating move " + next_move.name)
            return true

    return false

func _pick_move() -> WeaponMove:
    return next_move


func do_move_input(_delta: float) -> void:
    if not is_on_floor():
        return

    var direction = camera.global_basis * move.value_axis_3d
    var displacement = direction.normalized() * movement_speed

    velocity = displacement
