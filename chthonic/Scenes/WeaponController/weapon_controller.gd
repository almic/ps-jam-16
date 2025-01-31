@tool
class_name WeaponController extends AIController


@onready var weapon_point: Marker3D = %WeaponPoint


## Health of this weapon controller
@export var health: int = 100

## Currently owned weapon of this controller
@export var weapon: CombatWeapon

## Blood particle to spawn when taking damage
@export var blood_particle: PackedScene

## The opponent collision mask to detect opponents
@export_flags_3d_physics var opponent_mask: int


## Current stance of this controller
var stance: Combat.Stance = Combat.Stance.Unset

## Reference to the WeaponItem of the actual weapon object
var weapon_obj: WeaponItem

## The currently playing weapon move
var current_move: WeaponMove

## The result of the current move, changes to Unset when the animation completes
## or a new move is triggered. Will never be Miss.
var current_move_result: Combat.MoveResult = Combat.MoveResult.Unset

## For completeness, I don't think this will be used anywhere
var last_move_result: Combat.MoveResult = Combat.MoveResult.Unset

## When true, activates physics process to check for actions
var in_combat: bool = false

## Immunity frames counter, decremented once per physics frame
var i_frames: int = 0

func _ready() -> void:
    super._ready()

    add_to_group(GROUP.WEAPON_CONTROLLER)

    weapon_obj = weapon.weapon_scene.instantiate()
    weapon_obj.weapon_controller = self

    grab_point.add_child(weapon_obj)

func _physics_process(delta: float) -> void:
    super._physics_process(delta)

    if Engine.is_editor_hint():
        return

    if i_frames > 0:
        i_frames -= 1

    if not alive:
        return

    if not in_combat:
        return

    # Change to idle
    if current_move and weapon_obj.anim_player.current_animation == "":
        stance = Combat.Stance.Idle

        if current_move_result == Combat.MoveResult.Unset:
            last_move_result = Combat.MoveResult.Miss
        else:
            last_move_result = current_move_result

        current_move = null
        current_move_result = Combat.MoveResult.Unset
        weapon_obj.anim_player.play(weapon.animation_library + "/" + weapon.anim_idle_name)

    if _should_act():
        current_move = _pick_move()
        current_move_result = Combat.MoveResult.Unset
        stance = Combat.Stance.PreAction
        weapon_obj.anim_player.play(weapon.animation_library + "/" + current_move.anim_name)

## Called by weapons when their blade hitbox collides with us. Return `true` to
## tell the weapon to stop requesting we take damage.
func _hit_by(other: WeaponController) -> bool:
    if i_frames > 0:
        return false # Ignore if hit recently

    i_frames = 30
    var damage: int = 0
    var hit_taken: bool = false

    ## NOTE: maybe someday a hit can be rejected?
    other.current_move_result = Combat.MoveResult.Hit

    if other.current_move:
        match other.stance:
            # Take full damage in action stance
            Combat.Stance.Action:
                damage = other.current_move.damage
                hit_taken = true
            # Take partial damage if hit by post action
            Combat.Stance.PostAction:
                damage = int(float(other.current_move.damage) / 2.0)
                hit_taken = true
            # Otherwise, chip damage
            _: damage = 5
    else:
        # Take damage according to weapon multiplier
        damage = int(10 * other.weapon.damage_multiplier)

    # Try to spawn blood
    if damage > 0:
        var location = PHYSICS.intersection_location(self, other.weapon_obj.blade_area)
        if not location.is_empty():
            var blood: GPUParticles3D = blood_particle.instantiate()
            blood.one_shot = true
            add_sibling(blood)
            blood.global_position = location.point
            blood.global_rotation = -location.normal

    if _damage(damage):
        die.call_deferred()

    # Probably a terrible idea. This is spaghetti. Oh well!
    if other is PuppetAI:
        other.master._on_dealt_damage(damage)

    return hit_taken

func _next_target() -> Node3D:
    # Try to look for a nearby player first
    var target: Node3D = find_nearest_target(
        self,
        search_radius / 2,
        [GROUP.PLAYER]
    )

    if target is Player:
        if not target.puppet:
            return target

    # Look for opponents to fight
    target = find_nearest_target(
        self,
        search_radius,
        [GROUP.WEAPON_CONTROLLER, GROUP.ALIVE],
        [],
        opponent_mask
    )

    if target == self:
        return null

    if target is WeaponController:
        return target

    return null

## Implement in class, return `true` if this controller should decide to act
func _should_act() -> bool:
    return false

## Implement in class, return a WeaponMove to perform.
## This always returns a move.
func _pick_move() -> WeaponMove:
    return null

## Implement in class, take damage and return `true` if this controller should die
## Take care to not return `true` more than once!
func _damage(_amount: int) -> bool:
    return false

## Instructs the weapon controller to set up combat state
func enter_combat() -> void:
    in_combat = true
    stance = Combat.Stance.Idle
    weapon_obj.anim_player.play(weapon.animation_library + "/" + weapon.anim_idle_name)

## Instructs the weapon controller to tear down combat state
func exit_combat() -> void:
    in_combat = false
    stance = Combat.Stance.Unset
    weapon_obj.anim_player.play(weapon.animation_library + "/RESET")
