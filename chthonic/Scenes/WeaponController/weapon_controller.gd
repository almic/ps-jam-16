@tool
class_name WeaponController extends CharacterBody3D

const GROUP: String = "weapon_controller"

## Currently owned weapon of this controller
@export var weapon: CombatWeapon

## The opponent collision mask to detect opponents
@export_flags_3d_physics var opponent_mask: int

## Current stance of this controller
var stance: Combat.Stance = Combat.Stance.Unset

## Reference to the WeaponItem of the actual weapon object
var weapon_obj: WeaponItem

## The currently playing weapon move
var current_move: WeaponMove

## When true, activates physics process to check for actions
var in_combat: bool = false

func _ready() -> void:
    add_to_group(GROUP)
    weapon_obj = weapon.weapon_scene.instantiate()
    weapon_obj.weapon_controller = self
    add_child(weapon_obj)

func _physics_process(_delta: float) -> void:
    if not in_combat:
        return

    # Change to idle
    if current_move and weapon_obj.anim_player.current_animation == "":
        stance = Combat.Stance.Idle
        current_move = null
        weapon_obj.anim_player.play(weapon.animation_library + "/" + weapon.anim_idle_name)

    if _should_act():
        current_move = _pick_move()
        stance = Combat.Stance.Action
        weapon_obj.anim_player.play(weapon.animation_library + "/" + current_move.anim_name)

## Implement in class, return `true` if this controller should decide to act
func _should_act() -> bool:
    return false

## Implement in class, return a WeaponMove to perform.
## This always returns a move.
func _pick_move() -> WeaponMove:
    return null

## Helper function to return either the weapon controller directly in front,
## or the nearest weapon controller. If no weapon controller is found, this
## returns `this` WeaponController, never null!
func find_opponent_controller() -> WeaponController:
    var space = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.create(
        self.position,
        self.position - (self.basis.z * 100),
        opponent_mask,
        [self]
    )

    var result = space.intersect_ray(query)
    if result:
        if result.collider is WeaponController:
            return result.collider

    # Search for closest WeaponController in the world
    var closest: WeaponController = null
    var closest_distance_sqr: float = INF
    for other in get_tree().get_nodes_in_group(GROUP):
        if other == self or not other is WeaponController:
            continue
        var otherController = other as WeaponController

        var distance_sqr = (otherController.position - position).length_squared()
        if distance_sqr < closest_distance_sqr:
            closest = otherController
            closest_distance_sqr = distance_sqr

    if closest:
        return closest

    return self
