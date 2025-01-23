## Base class for weapons. Defines a moveable body that tracks with
## user input, a boundary for movement, an animation player, and a
## blade hit area for sparks.
class_name WeaponItem extends CharacterBody3D


## The controller of this weapon
@export var weapon_controller: WeaponController

@export var movement_speed: float = 1
var normal_movement_speed: float = 0

@export var slide_bounds: AABB = AABB(Vector3(-1, -0.25, 0), Vector3(2, 0.5, 0.1))

@export_category("Screen Motion")
## If the weapon movement tracks with user input. Also requires that the method
## `_can_move()` return `true` to track movement.
@export var user_input_enabled: bool = false
## Axis2D action that provides left/ right motion
@export var left_right: GUIDEAction = preload("res://Resource/Input/CombatGeneral/action/left_right.tres")
## Axis2D action that provides up/down motion
@export var up_down: GUIDEAction = preload("res://Resource/Input/CombatGeneral/action/up_down.tres")

@onready var anim_player: AnimationPlayer = %AnimationPlayer
@onready var blade_area: Area3D = %BladeHitArea

var targets: Array[Node3D] = []

func _ready() -> void:
    if not anim_player or not blade_area:
        push_warning("Missing an AnimationPlayer or BladeHitArea!")
    normal_movement_speed = movement_speed

    blade_area.body_entered.connect(_on_blade_hit_area_body_entered)
    blade_area.body_exited.connect(_on_blade_hit_area_body_exited)

    blade_area.area_entered.connect(_on_blade_hit_area_entered)
    blade_area.area_exited.connect(_on_blade_hit_area_exited)

    blade_area.add_to_group(GROUP.WEAPON_BLADE)

func _physics_process(delta: float) -> void:
    if user_input_enabled and weapon_controller.stance == Combat.Stance.Idle:
        move_left_right()

    # Apply physics when not controlled
    if not weapon_controller:
        velocity += get_gravity() * delta
        move_and_slide()
        return

    var to_erase: Array[Node3D] = []
    for target in targets:
        if target is WeaponController:
            if target._hit_by(weapon_controller):
                to_erase.append(target)

    for target in to_erase:
        targets.erase(target)

func move_left_right() -> void:

    var camera = Combat.get_camera(self)
    velocity = camera.global_basis * (left_right.value_axis_3d + Vector3(0, up_down.value_axis_3d.x, 0)) * movement_speed

    move_and_slide()

    var extent: Vector3 = position
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

        position = extent

## Implement in class to change the name of the idle animation to play
func _get_idle_anim() -> String:
    return "RESET"

## For animations, call this to set stance to `Combat.PreAction`. This is a
## "warm up" period of time before the main action, the time in which a reaction
## move is possible.
func _stance_pre_action() -> void:
    if not weapon_controller:
        return
    weapon_controller.stance = Combat.Stance.PreAction

## For animations, call this to set stance to `Combat.Action`. This is the main
## body of the animation. This is the non-reaction point of a move.
func _stance_action() -> void:
    if not weapon_controller:
        return
    weapon_controller.stance = Combat.Stance.Action

## For animations, call this to set stance to `Combat.PostAction`. By default,
## the end of the animation marks the PostAction point, but you can call this
## to set it earlier.
func _stance_post_action() -> void:
    if not weapon_controller:
        return
    weapon_controller.stance = Combat.Stance.PostAction

func _on_blade_hit_area_body_entered(body: Node3D) -> void:
    # don't hurt our controller
    if body == weapon_controller:
        return

    if not targets.has(body):
        targets.append(body)

func _on_blade_hit_area_body_exited(body: Node3D) -> void:
    targets.erase(body)

func _on_blade_hit_area_entered(area: Area3D) -> void:
    if area.is_in_group(GROUP.WEAPON_BLADE):
        print("Sparks fly!")

func _on_blade_hit_area_exited(_area: Area3D) -> void:
    pass
