# Allows us to see the sword in-editor
@tool

class_name Player extends WeaponController

@export_range(0.1, 2) var movement_speed: float = 1.5

@export_category("Input")
@export var move: GUIDEAction
@export var travel_mapping_context: GUIDEMappingContext

var next_move: WeaponMove = null

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
    weapon_obj.user_input_enabled = true
    GUIDE.disable_mapping_context(travel_mapping_context)

func exit_combat(_ignored: bool = false) -> void:
    super.exit_combat(true)
    weapon_obj.user_input_enabled = false
    GUIDE.enable_mapping_context(travel_mapping_context)


func _should_act() -> bool:
    if not stance == Combat.Stance.Idle:
        return false

    for move in weapon.move_set.moves:
        if move.action.is_triggered():
            next_move = move
            print("Activating move " + next_move.name)
            return true

    return false

func _pick_move() -> WeaponMove:
    return next_move


func do_move_input(delta: float) -> void:
    if not is_on_floor():
        return

    var camera = Combat.get_camera(self)
    var direction = camera.global_basis * move.value_axis_3d
    var displacement = direction.normalized() * movement_speed

    velocity = displacement
