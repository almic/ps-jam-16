extends Node3D

const DEBUG_CONTEXT: GUIDEMappingContext = preload("res://Resource/Input/Debug/DebugContext.tres")
const ENABLE_DEBUG: GUIDEAction = preload("res://Resource/Input/Debug/action/enable_debug.tres")
const TOGGLE_COMBAT: GUIDEAction = preload("res://Resource/Input/Debug/action/toggle_combat.tres")
const KILL_ALL: GUIDEAction = preload("res://Resource/Input/Debug/action/kill_all.tres")

var debug_mode: bool = false

const LivePlayer = preload("res://Scenes/Player/player.gd")

@export var menu_context: GUIDEMappingContext

@export var escape: GUIDEAction = preload("res://Resource/Input/Menu/action/escape_back.tres")

@onready var player: Player = %Player


@onready var tent_spawn_locations: Node = $"Player/Tent Spawns"
@export var Tent = preload("res://Objects/Structure/tent/tent.tscn")

@onready var ui_control: Control = %UIControl

var paused_contexts: Array[GUIDEMappingContext]
var rng = RandomNumberGenerator.new()

var total_distance_traveled = 0.0
var distance_trav = 0.0
var distance_to_tent = random_num(5, 30) #set the range for min and max tent spawns

func random_num(range1, range2):
    var ran_num = rng.randf_range(range1, range2)
    return ran_num

func _ready() -> void:
    GUIDE.enable_mapping_context(DEBUG_CONTEXT)
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
    if distance_trav >= distance_to_tent:
        spawn_tent()
        distance_trav = 0.0
        distance_to_tent = random_num(5, 30)#set the range for min and max tent spawns

    if ENABLE_DEBUG.is_triggered():
        if debug_mode:
            get_tree().call_group("debug", "disable_debug")
            debug_mode = false
        else:
            get_tree().call_group("debug", "enable_debug")
            debug_mode = true

    if TOGGLE_COMBAT.is_triggered():
        get_tree().call_group(GROUP.PLAYER, "toggle_combat")

    if KILL_ALL.is_triggered():
        get_tree().call_group(GROUP.ALIVE, "die")

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

func spawn_tent():
    var children = tent_spawn_locations.get_children()
    var tent_spawns = children[randi() % children.size()]
    var tent_obj = Tent.instantiate()
    tent_obj.position.z = player.position.z + random_num(10,20) #set these values to determine how far away the tents can spawn
    tent_obj.position.x = player.position.x + random_num(30,130)
    add_child(tent_obj)
