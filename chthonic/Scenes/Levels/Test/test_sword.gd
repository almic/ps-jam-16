extends Node3D

@export var menu_context: GUIDEMappingContext

@export var escape: GUIDEAction = preload("res://Resource/Input/Menu/action/escape_back.tres")

@onready var ui_control: Control = %UIControl
@onready var player: Player = %Player

var paused_contexts: Array[GUIDEMappingContext]

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
    if escape.is_triggered():
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
            ui_control.visible = true
            paused_contexts = GUIDE.get_enabled_mapping_contexts()
            GUIDE.enable_mapping_context(menu_context, true)
        else:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
            ui_control.visible = false
            GUIDE.disable_mapping_context(menu_context)
            for context in paused_contexts:
                GUIDE.enable_mapping_context(context)
            paused_contexts.clear()
