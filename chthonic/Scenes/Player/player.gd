# Allows us to see the sword in-editor
@tool

class_name Player extends WeaponController

var next_move: WeaponMove = null

func _ready() -> void:
    super._ready()
    weapon_obj.user_input_enabled = true
    enter_combat()

func _process(_delta: float) -> void:
    pass

func _physics_process(delta: float) -> void:
    super._physics_process(delta)
    pass

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

func _update_state(_delta: float) -> void:
    pass
