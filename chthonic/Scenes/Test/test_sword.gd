extends Node3D

@export var combat_context: GUIDEMappingContext
@export var sword_context: GUIDEMappingContext


func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    GUIDE.enable_mapping_context(combat_context, true)
    GUIDE.enable_mapping_context(sword_context)
