### score_manager.gd
extends Node

@onready var current_score : int = 0
@onready var current_lives : int = Global.max_lives
@onready var current_homes : int = 0

var max_lane   : int = 0
var hop_score  : int = 10
var lane_score : int = 10
var home_score : int = 50
var win_score  : int = 1000

signal current_score_changed(new_score: int)
signal current_lives_changed(new_lives: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialize_signals()

func _initialize_signals() -> void:
	Events.game_over.connect(self.on_game_over)
	Events.game_restarted.connect(self.on_game_restarted)
	
	Events.player_hop.connect(self.on_player_hop)
	Events.player_died.connect(self.on_player_died)
	Events.player_home.connect(self.on_player_home)
	Events.level_won.connect(self.on_level_won)

func on_player_home(_home : Node2D) -> void:
	self.current_homes += 1
	self.set_current_score(current_score + home_score)
	
	if self.current_homes == Global.homes_to_win:
		await get_tree().create_timer(0.25).timeout
		Events.emit_signal("level_won")

func on_player_died() -> void:
	if current_lives >= 0:
		self.subtract_life()
	else:
		self.set_current_lives(0)

func on_player_hop() -> void:
	self.set_current_score(current_score + hop_score)

func on_level_won() -> void:
	self.current_homes = 0
	self.set_current_score(current_score + win_score)

func on_game_over() -> void:
	self.set_current_lives(0)

func on_game_restarted() -> void:
	self.set_current_lives(Global.max_lives)

func set_current_score(value: int) -> void:
	self.current_score = value
	
	# Gain a life at 20,000 points
	if current_score == 10000:
		set_current_lives(current_lives + 1)
	
	self.emit_signal("current_score_changed", current_score)

func set_current_lives(value: int) -> void:
	self.current_lives = value
	self.emit_signal("current_lives_changed", current_lives)

func subtract_life() -> void:
	self.current_lives -= 1
	self.emit_signal("current_lives_changed", current_lives)
