class_name Brain extends Resource


enum State {
    Unset,

    ## AI is doing nothing
    Idle,

    ## Tracking a target
    Tracking,

    ## Arrived at a target
    Arrived
}

@export var state: State = State.Unset

## Target memory details. Poll determines how often it will search for targets
@export var target: Memory

## Target position details. Poll determines how often it updates where to approach,
## and the threshold is used to determine when to "forget" about distance targets
@export var target_position: Memory

## Additional memories unique to different AI
@export var memories: Array[Memory]

func _init() -> void:
    pass

## Clones the memory so this brain is unique
static func make_unique(brain: Brain) -> Brain:
    var new_brain = brain.duplicate(true)
    var index = 0
    for memory in brain.memories:
        new_brain.memories[index] = memory.duplicate(true)
        index += 1

    return new_brain

