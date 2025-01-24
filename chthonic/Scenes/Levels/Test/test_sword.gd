extends Node3D

const DEBUG_CONTEXT: GUIDEMappingContext = preload("res://Resource/Input/Debug/DebugContext.tres")
const ENABLE_DEBUG: GUIDEAction = preload("res://Resource/Input/Debug/action/enable_debug.tres")
const TOGGLE_COMBAT: GUIDEAction = preload("res://Resource/Input/Debug/action/toggle_combat.tres")
var debug_mode: bool = false

@export var menu_context: GUIDEMappingContext

@export var escape: GUIDEAction = preload("res://Resource/Input/Menu/action/escape_back.tres")

@onready var ui_control: Control = %UIControl

var paused_contexts: Array[GUIDEMappingContext]



func _ready() -> void:
    GUIDE.enable_mapping_context(DEBUG_CONTEXT)
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
    if ENABLE_DEBUG.is_triggered():
        if debug_mode:
            get_tree().call_group("debug", "disable_debug")
            debug_mode = false
        else:
            get_tree().call_group("debug", "enable_debug")
            debug_mode = true

    if TOGGLE_COMBAT.is_triggered():
        get_tree().call_group(GROUP.PLAYER, "toggle_combat")

    if escape.is_triggered():
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
            ui_control.visible = true
            paused_contexts = GUIDE.get_enabled_mapping_contexts()
            GUIDE.enable_mapping_context(menu_context, true)
            GUIDE.enable_mapping_context(DEBUG_CONTEXT)
        else:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
            ui_control.visible = false
            GUIDE.disable_mapping_context(menu_context)
            for context in paused_contexts:
                GUIDE.enable_mapping_context(context)
            paused_contexts.clear()
