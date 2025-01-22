## Wrapper for AI memories
class_name Memory extends Resource

## How frequently to poll for new information
@export_range(0.01, 5) var poll_rate: float = 1

## Supported in some cases, when new information exceeds this value, the information is lost
## For example, when polling the distance to a target, large distances can clear memory
@export var threshold: float = 0

var _poll_time: float = 0
var _value: Variant

func set_memory(value) -> void:
    _value = value

func get_memory() -> Variant:
    return _value

func clear() -> void:
    _value = null
    _poll_time = poll_rate

func exists() -> bool:
    return _value != null

func is_gone() -> bool:
    return _value == null

func poll(delta: float) -> bool:
    _poll_time -= delta
    if _poll_time <= 0:
        _poll_time = poll_rate
        return true
    return false
