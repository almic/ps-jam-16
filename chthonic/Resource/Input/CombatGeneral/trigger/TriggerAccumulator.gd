@tool

class_name TriggerAccumulator extends GUIDETrigger

## How much input must be accumulated to activate this trigger
@export var threshold: Vector3 = Vector3(1, 0, 0)

## Multiplied by the input before accumulating, necessary to handle negative inputs
@export var multiplier: Vector3 = Vector3(1, 1, 1)

## How long to wait after actuation stops before resetting accumulation
@export var delay: float = 0

## A list of required actions that must be triggered before accumulating.
## Leave empty to ignore.
@export var requirements: Array[GUIDEAction] = []


var _accumulated: Vector3 = Vector3(0, 0, 0)
var _reset_timer: float = 0

func _update_state(input: Vector3, delta: float, value_type: GUIDEAction.GUIDEActionValueType) -> GUIDETriggerState:
    # Ensure requirements are presently triggered before doing anything
    if not requirements.is_empty():
        for req in requirements:
            if not req.is_triggered():
                _reset()
                return GUIDETriggerState.NONE

    if not _is_actuated(input, value_type):
        # Accumulate delta time until reset
        _reset_timer += delta
        if _reset_timer >= delay:
            _reset()
            return GUIDETriggerState.NONE

        # Keep getting calls until we reset or trigger
        return GUIDETriggerState.ONGOING

    # When actuated, set reset timer to zero
    _reset_timer = 0

    # Accumulate
    _accumulated.x += input.x * multiplier.x
    _accumulated.y += input.y * multiplier.y
    _accumulated.z += input.z * multiplier.z

    if meets_threshold():
        _reset()
        print("accumulator is triggered")
        return GUIDETriggerState.TRIGGERED

    return GUIDETriggerState.ONGOING

func _reset() -> void:
    _reset_timer = 0
    _accumulated.x = 0
    _accumulated.y = 0
    _accumulated.z = 0

func meets_threshold() -> bool:
    return (
            _accumulated.x >= threshold.x
        and _accumulated.y >= threshold.y
        and _accumulated.z >= threshold.z
    )

func _editor_name() -> String:
    return "Accumulator"

func _editor_description() -> String:
    return ("Accumulates input until it reaches a threshold, then triggers. Use the\n" +
        "multiplier parameter to accumulate negative inputs by inverting them first.")
