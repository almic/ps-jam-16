# Allows us to see in-editor
@tool

class_name AIController extends WeaponController

## Enable to print debug info about AI state
const DEBUG_PRINT: bool = true


@onready var grab_point: Marker3D = %GrabPoint


@export_range(0.1, 3) var movement_speed: float = 1.3
@export_range(0.1, 2) var rotate_speed: float = 1.8

@export_category("Target Seeking")
## How close to approach targets
@export_range(0.01, 3) var approach_distance_squared: float = 1
## Margin of error when approaching targets
@export_range(0.01, 1) var approach_margin: float = 0.01

## How far to be aware of targets
@export_range(0.01, 25) var search_radius: float = 15

@export var brain: Brain

func _ready() -> void:
    super._ready()
    weapon_obj.position = grab_point.position
    weapon_obj.rotation = grab_point.rotation

    brain = Brain.make_unique(brain)
    brain.state = Brain.State.Idle

    if DEBUG_PRINT:
        print("%s is ready!" % name)

func _physics_process(delta: float) -> void:
    if Engine.is_editor_hint():
        return

    super._physics_process(delta)

    if not is_on_floor():
        velocity += get_gravity() * delta
    else:
        velocity = Vector3.ZERO

    match brain.state:
        Brain.State.Idle:
            if seek_target(delta):
                if DEBUG_PRINT:
                    print("%s is tracking a target" % name)
                brain.state = Brain.State.Tracking
        Brain.State.Tracking:
            if track_target(delta):
                pass
            else:
                if DEBUG_PRINT:
                    print("%s lost its target" % name)
                clear_target()
                brain.state = Brain.State.Idle
        Brain.State.Arrived:
            if check_target(delta):
                pass
            else:
                if DEBUG_PRINT:
                    print("%s lost its target" % name)
                clear_target()
                brain.state = Brain.State.Idle

    move_and_slide()

func clear_target() -> void:
    on_target_lost()
    brain.target.clear()
    brain.target_position.clear()

## Seeks a new target, returns true when a new target is found
func seek_target(delta: float) -> bool:
    if not brain.target.poll(delta):
        return false

    var target_controller = find_opponent_controller(search_radius)
    if target_controller == self:
        return false

    # Found a target!
    brain.target.set_memory(target_controller)
    brain.target_position.set_memory(target_controller.position)

    if DEBUG_PRINT:
        print("%s found a new target %s" % [name, target_controller.name])

    return true

## Returns false if the target does not exist. Changes state to Tracking if too far
func check_target(delta: float) -> bool:
    if not brain.target.poll(delta):
        return true

    if brain.target.is_gone():
        return false

    var target_controller: WeaponController = brain.target.get_memory() as WeaponController
    if not target_controller:
        return false

    brain.target_position.set_memory(target_controller.position)
    var distance = target_controller.position - position
    distance.y = 0

    # Too far, track target
    if distance.length_squared() > approach_distance_squared + approach_margin:
        if DEBUG_PRINT:
            print("%s is too far from its target, tracking now" % name)

        brain.state = Brain.State.Tracking

    return true

## Tracks the target if they exist, updating their position. Returns false if too far or gone.
## Updates state to Arrived when reaching the target
func track_target(delta: float) -> bool:
    if brain.target.is_gone():
        return false

    var target_controller: WeaponController = brain.target.get_memory() as WeaponController
    if not target_controller:
        return false

    # Poll for target position
    if brain.target_position.poll(delta):
        var pos: Vector3 = target_controller.position
        if pos.length() > brain.target_position.threshold:
            return false
        else:
            brain.target_position.set_memory(pos)

    if brain.target_position.is_gone():
        return false

    var target_pos: Vector3 = brain.target_position.get_memory() as Vector3
    if not target_pos:
        return false

    var direction: Vector3 = target_pos - position

    # Hard coded too far on the vertical range
    if abs(direction.y) > 20:
        return false
    direction.y = 0

    if not is_on_floor():
        return true

    var target_rot = wrapf(atan2(direction.x, direction.z) - rotation.y, -PI, PI)
    rotation.y += clampf(PI * rotate_speed * delta, 0, abs(target_rot)) * sign(target_rot)

    if direction.length_squared() > approach_distance_squared:
        velocity += direction.normalized() * movement_speed
    else:
        if DEBUG_PRINT:
            print("%s arrived at my target!" % name)
        brain.state = Brain.State.Arrived
        on_arrived()

    return true

## Implement in class. Called when tracking approaches the target
func on_arrived() -> void:
    pass

## Implement in class. Called when tracking loses a target. The target
## may still be in memory when this is called.
func on_target_lost() -> void:
    pass
