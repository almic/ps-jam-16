@tool
class_name DayNightEnvironment extends Node3D

@onready var directional_light_3d: DirectionalLight3D = %DirectionalLight3D

@export_range(0, 24) var hour: float = 12:
    set(value):
        hour = value
        update_sky = true

@export_range(-90, 90) var latitude: float = 0:
    set(value):
        latitude = value
        update_sky = true

var update_sky: bool = true

func _ready() -> void:
    update_time()

func _process(_delta: float) -> void:
    if update_sky:
        update_time()

func set_time(to_hour: float) -> void:
    self.hour = to_hour
    update_time()

func update_time() -> void:
    update_sky = false
    var angle: float = PI / 12 * (hour + 6)

    rotation_degrees.z = -latitude
    directional_light_3d.rotation.x = angle

    if hour >= 18 or hour <= 6:
        directional_light_3d.visible = false
    else:
        directional_light_3d.visible = true

