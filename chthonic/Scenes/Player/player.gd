# Allows us to see the sword in-editor
@tool

class_name Player extends CharacterBody3D


@onready var first_person_marker: Marker3D = %FirstPersonMarker
@onready var third_person_marker: Marker3D = %ThirdPersonMarker
@onready var camera: Camera3D = %Camera
@onready var pivot: Node3D = %Pivot
@onready var infini_level: Node3D = $".."


@export_range(0.1, 2) var movement_speed: float = 1.5

@export_category("Input")
@export var move: GUIDEAction
@export var rotate_camera: GUIDEAction
## Travel input context
@export var travel_mapping_context: GUIDEMappingContext
## Combat input context
@export var combat_mapping_context: GUIDEMappingContext

@export_category("Weapon")
## The "player's" weapon
@export var weapon: CombatWeapon
## The player's puppet
@export var puppet: PuppetAI
## The scene to use for puppets
@export var puppet_scene: PackedScene

var camera_locked: bool = false
var next_move: WeaponMove = null

## Reference to the WeaponItem of the actual weapon object
var weapon_obj: WeaponItem

## Track the current move's index position in the move set, used for priority
## overriding when two moves share inputs
var move_index: int = -1

## Tracks combat state
var in_combat: bool = false

func _ready() -> void:
    add_to_group(GROUP.PLAYER)


    weapon_obj = weapon.weapon_scene.instantiate() as WeaponItem
    add_child(weapon_obj)

    # grrr
    if Engine.is_editor_hint():
        return

    # Make top-level. Left on for editor convenience + initial positioning
    pivot.top_level = true

    # probably not right. call this just to ensure state is good.
    exit_combat()

## Process inputs per-frame.
## Combat actually happens on physics frames from the puppet
func _process(delta: float) -> void:
    if Engine.is_editor_hint():
        return

    if not in_combat:
        _do_move_input(delta)

    pivot.rotation_degrees.y += rotate_camera.value_axis_1d

    pass

func _physics_process(delta: float) -> void:
    if Engine.is_editor_hint():
        return

    # Kill velocity of sword when in combat
    if in_combat:
        velocity = Vector3()

    if not puppet and not is_on_floor():
        velocity += get_gravity() * delta

    if velocity.length_squared() > 0: #updates player position, calculates distance traveled by z vector
        var curr_pos = self.global_position.z
        move_and_slide()
        var trav_diff = self.global_position.z - curr_pos
        infini_level.total_distance_traveled = (infini_level.total_distance_traveled) + trav_diff
        infini_level.distance_trav += trav_diff

## Called by the puppet when it enters combat
func enter_combat() -> void:
    # just in case
    if not puppet:
        print("Player cannot enter combat, no puppet!")
        return

    print("Player entering combat!")
    in_combat = true

    if puppet and not puppet.in_combat:
        puppet.enter_combat()

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
    GUIDE.enable_mapping_context(combat_mapping_context)
    GUIDE.enable_mapping_context(weapon.mapping_context)

## Called by the puppet when it exits combat, or by us when it dies
func exit_combat() -> void:
    print("Player leaving combat")
    in_combat = false

    if puppet and puppet.in_combat:
        puppet.exit_combat()

    # Move camera into position
    camera.reparent(third_person_marker, true)
    camera_locked = false # Unlock camera motion
    var tween = get_tree().create_tween()
    tween.set_parallel()
    tween.tween_property(camera, "position", Vector3(), 0.8)
    tween.tween_property(camera, "rotation", Vector3(), 0.8)

    # Stop weapon follow, enable travel
    weapon_obj.user_input_enabled = false
    GUIDE.disable_mapping_context(combat_mapping_context)
    GUIDE.disable_mapping_context(weapon.mapping_context)
    GUIDE.enable_mapping_context(travel_mapping_context)

func toggle_combat() -> void:
    if in_combat:
        exit_combat()
    else:
        enter_combat()

## Used by puppet to ask if it wants to act
func _should_act() -> bool:
    ## Activate higher priority moves during pre-action
    ## Remember, priorities are in the WeaponMoveSet resource! Not input!
    if puppet.stance == Combat.Stance.PreAction and puppet.current_move:
        var idx: int = 0
        for weapon_move in weapon.move_set.moves:
            if idx >= move_index:
                break

            # NOTE: cannot trigger follow-ups in PreAction
            if weapon_move.after_enabled:
                idx += 1
                continue

            if weapon_move.action.is_triggered():
                next_move = weapon_move
                move_index = idx
                return true

            idx += 1

    # Follow-up moves which can be activated during post-action
    if puppet.stance == Combat.Stance.PostAction and puppet.current_move:
        var idx: int = 0
        for weapon_move in weapon.move_set.moves:
            if idx >= move_index:
                break

            if not weapon_move.after_enabled or not weapon_move.after_move == puppet.current_move:
                idx += 1
                continue

            if not weapon_move.action.is_triggered():
                idx += 1
                continue

            if (not weapon_move.after_result == Combat.MoveResult.Unset
                and not puppet.current_move_result == weapon_move.after_result
                ):
                idx += 1
                continue

            # Triggered and possible follow-up move
            next_move = weapon_move
            move_index = idx
            return true

    if not puppet.stance == Combat.Stance.Idle:
        return false

    # These are from idle only
    var index: int = 0
    for weapon_move in weapon.move_set.moves:
        if weapon_move.after_enabled:
            index += 1
            continue

        if weapon_move.action.is_triggered():
            next_move = weapon_move
            move_index = index
            return true
        index += 1

    return false

## Used by puppet to ask for the move to perform
func _pick_move() -> WeaponMove:
    return next_move


func _do_move_input(_delta: float) -> void:
    if puppet:
        if not puppet.is_on_floor():
            return
    elif not is_on_floor():
        return

    var direction = camera.global_basis * move.value_axis_3d
    direction.y = 0
    var displacement = direction.normalized() * movement_speed

    if puppet:
        puppet.velocity = displacement
    else:
        velocity = displacement

## TODO: Called by weapon controller when it takes damage from our puppet
func _on_dealt_damage(_amount: int) -> void:
    pass

## Called by any WeaponController when it wants the become a puppet
## TODO: make it so players can reject this, returning `false`
func _request_puppet_claim(host: WeaponController) -> bool:
    puppet = puppet_scene.instantiate() as PuppetAI

    # we must initialize the puppet's nodes before adding to the scene
    puppet._claim(self, host)
    add_sibling(puppet)

    # then we assign the puppet's basis (position, rotation, scale)
    puppet.global_transform = host.global_transform

    # queue a tween for the pickup
    var tween = get_tree().create_tween()

    tween.set_parallel(true)
    tween.tween_property(self, "global_position", puppet.remote_transform_3d.global_position, 0.8)
    tween.tween_property(self, "global_rotation", puppet.remote_transform_3d.global_rotation, 0.8)
    tween.set_parallel(false)

    tween.tween_callback(
        func ():
            if not puppet:
                return
            puppet.remote_transform_3d.remote_path = get_path()
    )

    # free the host, which is now just an empty Node3D
    host.queue_free()

    # parent the old weapon to the world so it drops
    for child in puppet.get_children():
        if child is WeaponItem:
            child.reparent(self.get_parent(), true)

    return true

## Called by the puppet when it dies
func _on_puppet_died() -> void:
    exit_combat()
    puppet = null
