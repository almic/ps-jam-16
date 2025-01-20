## Outputs a constant input value, intended for non-bound actions that
## activate via other actions, such as with Chorded triggers
@tool
class_name ModifierConstant extends GUIDEModifier

@export var output: Vector3 = Vector3(1, 0, 0)

func _modify_input(_input: Vector3, _delta: float, _value_type: GUIDEAction.GUIDEActionValueType) -> Vector3:
    return output

func _editor_name() -> String:
    return "Constant"


func _editor_description() -> String:
    return "Outputs a constant value, intended for non-bound actions or actions\n" + \
        "which should always start with an initial output"
