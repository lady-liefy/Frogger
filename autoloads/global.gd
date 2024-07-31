### global.gd
extends Node2D

@export var game_speed := 1.0 : set = _set_game_speed
@export var speed_factor := 0.3
@export var tile_size := 64

@onready var initial_position := Vector2(224, 1056)

var levels = {
	0 : preload("res://scenes/level_0.tscn"),
	1 : preload("res://scenes/level_1.tscn"),
	2 : preload("res://scenes/level_2.tscn")
}
var current_level_id := 0

var timer_length  : int = 60
var max_lives     : int = 5
var homes_to_win  : int = 5
var scene_paths = {
	"World": preload("res://scenes/world.tscn"),
	"Main_Menu": preload("res://scenes/main_menu.tscn")
}

func _ready() -> void:
	Events.game_won.connect(on_game_won)
	Events.game_over.connect(on_game_over)
	_set_game_speed(game_speed)

func _set_game_speed(speed : float) -> void:
	game_speed = speed

func _reset() -> void:
	ScoreManager.set_current_score(0)
	ScoreManager.set_current_lives(max_lives)

func _clear_level() -> void:
	current_level_id = 0
	ScoreManager.current_homes = 0
	ScoreManager.max_lane = 0

func on_game_over() -> void:
	get_tree().paused = true
	_set_game_speed(1)
	
	_clear_level()
	_reset()

func on_game_won() -> void:
	_set_game_speed(game_speed + speed_factor)
	_clear_level()
