extends Control

@onready var animated_sprite_2d: AnimatedSprite2D = $MarginContainer/AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

var x = 0


# Called when start game button is pressed
func _on_start_game_pressed() -> void:
    print("you clicked start")
    #animated_sprite_2d.play("SliceAnim")
    pass # Replace with function body.
