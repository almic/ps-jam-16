@tool
class_name KnightAI extends AIController

@export var attack_tree: AttackTree

var _tree: AttackTreeWalker

var next_move: WeaponMove

func _ready() -> void:
    super._ready()

    _tree = AttackTreeWalker.new(attack_tree)
    _tree.begin()

func on_arrived() -> void:
    var target = brain.target.get_memory()
    if not target:
        return

    if target is WeaponController:
        enter_combat()

        # Tell player to enter combat
        if target is Player:
            if DEBUG_PRINT:
                print("%s fight me, human!" % name)
            var player: Player = target as Player
            player.enter_combat()
        else:
            print("%s fight me, %s!" % [name, target.name])

func _should_act() -> bool:
    if stance != Combat.Stance.Idle:
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
