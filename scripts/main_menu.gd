extends Control
class_name MainMenu

@export var game_title : Label
@onready var scene_to_load : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	game_title.text = ProjectSettings.get("application/config/name")
	
	await get_tree().process_frame
	$MarginContainer/VBoxContainer/ButtonPlay.grab_focus()
	
func _on_button_quit_pressed():
	get_tree().quit()

func _on_button_play_pressed():
	get_tree().paused = false
	scene_to_load = load("res://scenes/world.tscn")
	get_tree().change_scene_to_packed(scene_to_load)
	
	Global._reset()
