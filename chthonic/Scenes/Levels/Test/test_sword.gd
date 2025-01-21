extends Node3D

@export var combat_context: GUIDEMappingContext
@export var sword_context: GUIDEMappingContext
@export var menu_context: GUIDEMappingContext

@export var escape: GUIDEAction = preload("res://Resource/Input/Menu/action/escape_back.tres")

@onready var ui_control: Control = %UIControl

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    GUIDE.enable_mapping_context(combat_context, true)
    GUIDE.enable_mapping_context(sword_context)

func _process(_delta: float) -> void:
    if escape.is_triggered():
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
            ui_control.visible = true
            GUIDE.disable_mapping_context(combat_context)
            GUIDE.enable_mapping_context(menu_context)
        else:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
            ui_control.visible = false
            GUIDE.enable_mapping_context(combat_context)
            GUIDE.disable_mapping_context(menu_context)

