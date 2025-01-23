# Allows us to see in-editor
@tool

class_name AIController extends CharacterBody3D

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

## Marks this controller as dead
var alive: bool = true

func _ready() -> void:
    add_to_group(GROUP.ALIVE)

    if Engine.is_editor_hint():
        return

    brain = Brain.make_unique(brain)
    brain.state = Brain.State.Idle

    if DEBUG_PRINT:
        print("%s is ready!" % name)

func _physics_process(delta: float) -> void:
    if Engine.is_editor_hint():
        return

    if not is_on_floor():
        velocity += get_gravity() * delta
    else:
        velocity = Vector3.ZERO

    if not alive:
        return

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
    _on_target_lost()
    brain.target.clear()
    brain.target_position.clear()

## Seeks a new target, returns true when a new target is found
func seek_target(delta: float) -> bool:
    if not brain.target.poll(delta):
        return false

    var new_target = _next_target()
    if not new_target:
        return false

    # Found a target!
    brain.target.set_memory(new_target)
    brain.target_position.set_memory(new_target.position)

    if DEBUG_PRINT:
        print("%s found a new target %s" % [name, new_target.name])

    return true

## Returns false if the target does not exist. Changes state to Tracking if too far
func check_target(delta: float) -> bool:
    if not brain.target.poll(delta):
        return true

    if brain.target.is_gone():
        return false

    var target: Node3D = brain.target.get_memory() as Node3D
    if not target:
        return false

    brain.target_position.set_memory(target.position)
    var distance = target.position - position
    distance.y = 0

    # Too far, track target
    if distance.length_squared() > approach_distance_squared + approach_margin:
        if DEBUG_PRINT:
            print("%s is too far from its target, tracking now" % name)

        brain.state = Brain.State.Tracking

    return true

## Tracks the target if they exist, updating their position.
## Returns false if too far or gone.
## Updates state to Arrived when reaching the target
func track_target(delta: float) -> bool:
    if brain.target.is_gone():
        return false

    var target: Node3D = brain.target.get_memory() as Node3D
    if not target:
        return false

    # Poll for target position
    if brain.target_position.poll(delta):
        var pos: Vector3 = target.position
        var distance = (position - pos).length()
        if distance > brain.target_position.threshold:
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

    # Only move on the floor
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
        _on_arrived()

    return true

## Implement in class. Called when seeking out a new target
func _next_target() -> Node3D:
    return null

## Implement in class. Called when tracking approaches the target
func _on_arrived() -> void:
    pass

## Implement in class. Called when tracking loses a target. The target
## may still be in memory when this is called.
func _on_target_lost() -> void:
    pass

## Locates the nearest target to this, favoring ones directly in-front,
## optionally including only targets that match all the provided groups, and
## excluding ones in certain groups or certain Node3D objects entirely.
## If no suitable target is found, returns `this` back
static func find_nearest_target(
        this: Node3D,
        max_distance: float,
        group: Array[String] = [],
        exclude: Array[Variant] = [],
        mask: int = -1,
        areas_allowed: bool = false
    ) -> Node3D:

    if group.is_empty():
        push_warning("Call to find_nearest_target without any groups is disallowed!")
        return this

    var space = this.get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.create(
        this.position,
        this.position - (this.basis.z * 100)
    )

    query.exclude = [this]
    query.collide_with_areas = areas_allowed

    if mask > 0:
        query.collision_mask = mask

    var result = space.intersect_ray(query)
    if result and _match_group_and_exclude(result.collider, group, exclude):
        return result.collider

    # Search for closest matching node in the world
    var max_dist_sqr = max_distance * max_distance
    var closest: Node3D = null
    var closest_distance_sqr: float = INF

    for other in this.get_tree().get_nodes_in_group(group[0]):
        if other == this:
            continue

        if not _match_group_and_exclude(other, group, exclude):
            continue

        var distance_sqr = (other.position - this.position).length_squared()
        if distance_sqr > max_dist_sqr:
            continue

        if distance_sqr < closest_distance_sqr:
            closest = other
            closest_distance_sqr = distance_sqr

    if closest:
        return closest

    return this

## Return `true` if the given node has all the groups and is not an excluded
## object or group
static func _match_group_and_exclude(
        node: Node3D,
        group: Array[String],
        exclude: Array[Variant]
    ) -> bool:

    if exclude.has(node):
        return false

    for e in exclude:
        if e is String and node.has_group(e):
            return false

    for g in group:
        if not node.is_in_group(g):
            return false

    return true
