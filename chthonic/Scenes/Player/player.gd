# Allows us to see the sword in-editor
@tool

class_name Player extends Node3D

@export var weapon_scene: PackedScene = preload("res://Objects/Weapon/sword_b/sword_b.tscn")

var weapon: SwordItem


func _ready() -> void:
    weapon = weapon_scene.instantiate()
    add_child(weapon)


func _process(delta: float) -> void:

    if Engine.is_editor_hint():

        return

    # Normal player stuff
