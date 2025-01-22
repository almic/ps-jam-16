# Allows us to see in-editor
@tool

class_name AIController extends WeaponController

const SEEK_DISTANCE_SQR: float = pow(1, 2)

@export_range(0.1, 3) var movement_speed: float = 1.3
@export_range(0.1, 2) var rotate_speed: float = 1.8

var target: WeaponController = null
var seek_rate: float = 2

var seek_time: float = 0

func _physics_process(delta: float) -> void:
    if Engine.is_editor_hint():
        return

    super._physics_process(delta)

    if not is_on_floor():
        velocity += get_gravity() * delta
    else:
        velocity = Vector3.ZERO

    seek_target(delta)

    move_and_slide()

func seek_target(delta: float) -> void:
    if target == null:
        seek_time -= delta

        if seek_time <= 0:
            seek_time = seek_rate

            target = find_opponent_controller()
            if target == self:
                target = null
        return

    if not is_on_floor():
        return

    var direction = target.position - position
    direction.y = 0

    var target_rot = wrapf(atan2(direction.x, direction.z) - rotation.y, -PI, PI)
    rotation.y += clampf(PI * rotate_speed * delta, 0, abs(target_rot)) * sign(target_rot)

    if direction.length_squared() > SEEK_DISTANCE_SQR:
        velocity += direction.normalized() * movement_speed
