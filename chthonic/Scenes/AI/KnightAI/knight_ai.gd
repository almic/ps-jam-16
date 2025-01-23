@tool
class_name KnightAI extends WeaponController

@export var attack_tree: AttackTree

var _tree: AttackTreeWalker

var next_move: WeaponMove

func _ready() -> void:
    super._ready()

    if Engine.is_editor_hint():
        return

    _tree = AttackTreeWalker.new(attack_tree)
    _tree.begin()

func _on_arrived() -> void:
    var target = brain.target.get_memory()
    if not target:
        return

    # Become a puppet?
    if target is Player:
        if DEBUG_PRINT:
            print("%s ooo, what's this weapon?" % name)
        target._request_puppet_claim(self)
        return

    if target is WeaponController:
        enter_combat()

        # Tell puppet to enter combat
        if target is PuppetAI:
            if DEBUG_PRINT:
                print("%s fight me, human!" % name)
            target.enter_combat()
        else:
            print("%s fight me, %s!" % [name, target.name])

func check_target(delta: float) -> bool:
    var result: bool = super.check_target(delta)

    if not result:
        return false

    if not is_target_player() and not is_target_alive():
        if DEBUG_PRINT:
            print("%s killed em!" % name)
        return false

    return result

func track_target(delta: float) -> bool:
    var result: bool = super.track_target(delta)

    if not result:
        return false

    if not is_target_player() and not is_target_alive():
        if DEBUG_PRINT:
            print("%s died before I got to em!" % name)
        return false

    return result

func _should_act() -> bool:
    if stance != Combat.Stance.Idle:
        return false

    if not is_target_alive():
        exit_combat()
        return false

    if not _tree.match_move_set(weapon.move_set):
        _tree.begin()
        return false

    var decision = _tree.next()
    if not decision:
        _tree.begin()
        return false

    if decision is DecisionRandom:
        if _tree.handle_random(decision as DecisionRandom):
            decision = _tree.next()
        else:
            _tree.begin()
            return false

    if decision is DecisionPick:
        decision = _tree.handle_pick(decision)

    if decision is DecisionAttack:
        next_move = decision.move
        return true

    return false

func _pick_move() -> WeaponMove:
    return next_move

func _damage(amount: int) -> bool:
    # We can only die once
    if not alive or health <= 0:
        return false

    health -= amount
    if DEBUG_PRINT:
        print("%s gah! I took %s damage!" % [name, amount])

    return health <= 0

func _die() -> void:
    if DEBUG_PRINT:
        print("%s gah! I die!" % name)
    alive = false

func _on_target_lost() -> void:
    if in_combat:
        exit_combat()

func is_target_alive() -> bool:
    var target = brain.target.get_memory()
    if target is WeaponController and target.alive:
        return true
    return false

func is_target_player() -> bool:
    var target = brain.target.get_memory()
    return target is Player
