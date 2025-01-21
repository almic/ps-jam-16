class_name SwordItem extends CharacterBody3D

@export var movement_speed: float = 1
var normal_movement_speed: float = 0

@export var slide_bounds: AABB = AABB(Vector3(-1, -0.25, 0), Vector3(2, 0.5, 0.1))

@export_category("Screen Motion")
@export var left_right: GUIDEAction = preload("res://Resource/Input/CombatGeneral/action/left_right.tres")
@export var up_down: GUIDEAction = preload("res://Resource/Input/CombatGeneral/action/up_down.tres")

@export_category("Attacks")
@export var activate: GUIDEAction = preload("res://Resource/Input/CombatGeneral/action/activate.tres")
@export var swing_left: GUIDEAction = preload("res://Resource/Input/Sword/action/swing_left.tres")
@export var swing_right: GUIDEAction = preload("res://Resource/Input/Sword/action/swing_right.tres")
@export var thrust: GUIDEAction = preload("res://Resource/Input/Sword/action/thrust.tres")
@export var kick: GUIDEAction = preload("res://Resource/Input/Sword/action/kick.tres")
@export var deflect_left: GUIDEAction = preload("res://Resource/Input/Sword/action/deflect_left.tres")
@export var deflect_right: GUIDEAction = preload("res://Resource/Input/Sword/action/deflect_right.tres")
@export var riposte_left: GUIDEAction = preload("res://Resource/Input/Sword/action/riposte_left.tres")
@export var riposte_right: GUIDEAction = preload("res://Resource/Input/Sword/action/riposte_right.tres")

@onready var anim_player: AnimationPlayer = %AnimationPlayer
@onready var blade_area: Area3D = %BladeHitArea

var initial_pos: Vector3
var action_playing: bool = false

func _ready() -> void:
    initial_pos = position
    normal_movement_speed = movement_speed
    idle_mode()

func _process(delta: float) -> void:

    if not anim_player.is_playing():
        idle_mode()

    # Cannot do anything while an action is active
    if action_playing:
        return

    move_left_right()

    check_actions()

func move_left_right() -> void:

    var camera = get_tree().root.get_camera_3d()
    velocity = camera.basis * (left_right.value_axis_3d + Vector3(0, up_down.value_axis_3d.x, 0)) * movement_speed

    move_and_slide()

    var extent: Vector3 = position - initial_pos
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

func check_actions() -> void:
    # slow speed while actuating
    if activate.is_triggered():
        movement_speed = normal_movement_speed * 0.2
    else:
        movement_speed = normal_movement_speed

    if swing_left.is_triggered():
        attack_swing_left()

    if thrust.is_triggered():
        attack_thrust()

func idle_mode() -> void:
    action_playing = false
    anim_player.play("SwordAnimations/idle_float")
    print("idle!")

func attack_swing_left() -> void:
    action_playing = true
    position = initial_pos
    anim_player.play("SwordAnimations/swing_left")
    print("swing left!")

func attack_thrust() -> void:
    action_playing = true
    position = initial_pos
    anim_player.play("SwordAnimations/thrust")
    print("thrust!")
