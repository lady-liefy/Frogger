### gui.gd
extends Node

@export var score_counter : Label
@export var lives_counter : Label

@onready var time_left = $CanvasLayer/MarginContainer/Timer/Amount
@onready var button_play_again = $CanvasLayer/MarginContainer/VBoxContainer/ButtonPlayAgain
@onready var button_resume = $CanvasLayer/MarginContainer/VBoxContainer/ButtonResume
@onready var button_exit = $CanvasLayer/MarginContainer/VBoxContainer/ButtonExit
@onready var button_quit_game = $CanvasLayer/MarginContainer/VBoxContainer/ButtonQuitGame
@onready var button_next_level = $CanvasLayer/MarginContainer/VBoxContainer/ButtonNextLevel
@onready var time_up = $CanvasLayer/MarginContainer/VBoxContainer/TimeUp

@onready var level_won = $CanvasLayer/MarginContainer/VBoxContainer/LevelWon

@onready var scene_to_load = Global.scene_paths["Main_Menu"]

signal level_finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self._initialize_signals()
	self._initialize()

func _initialize_signals() -> void:
	ScoreManager.current_score_changed.connect(set_current_score)
	ScoreManager.current_lives_changed.connect(set_current_lives)
	Events.timer_tick.connect(set_current_time)
	
	Events.time_up.connect(on_time_up)
	Events.game_over.connect(_on_game_over)
	Events.game_paused.connect(_on_game_paused)
	Events.game_resumed.connect(_on_game_resumed)
	Events.level_won.connect(on_level_won)

func _initialize() -> void:
	set_current_score(ScoreManager.current_score)
	set_current_lives(ScoreManager.current_lives)

func _physics_process(_delta : float) -> void:	
	if Input.is_action_just_pressed("pause"):
		if not get_tree().is_paused():
			Events.emit_signal("game_paused")
		else:
			Events.emit_signal("game_resumed")

func set_current_score(value: int = -1) -> void:
	if value < 0:
		self.score_counter.text = str(ScoreManager.current_score)
	else:
		self.score_counter.text = str(value)

func set_current_lives(value: int = -1) -> void:
	if value < 0:
		self.lives_counter.text = str(ScoreManager.current_lives)
	else:
		self.lives_counter.text = str(value)

func set_current_time(value: int = -1) -> void:
	self.time_left.text = str(value)

func _on_play_again_button_pressed() -> void:
	get_tree().set_pause(false)
	level_won.hide()
	
	if Global.current_level_id != Global.levels.size():
		Events.emit_signal("game_restarted")
	else:
		Events.emit_signal("game_won")
	
	button_play_again.hide()
	button_exit.hide()
	button_quit_game.hide()

func on_time_up() -> void:
	time_up.show()
	get_tree().set_pause(true)
	await get_tree().create_timer(1.5).timeout
	time_up.hide()
	get_tree().set_pause(false)

func on_level_won() -> void:
	await get_tree().create_timer(0.6).timeout
	get_tree().set_pause(true)
	level_won.show()
	
	if Global.current_level_id != Global.levels.size():
		level_won.get_node("Label").text = "Level Complete!"
		level_won.get_node("Amount").text = "Current Score: " + str(ScoreManager.current_score)
		button_next_level.grab_focus()
		button_exit.set_focus_neighbor(SIDE_TOP, button_exit.get_path_to(button_next_level))
		button_next_level.show()
		button_exit.show()
		button_quit_game.show()
	else:
		level_won.get_node("Label").text = "You Win!"
		level_won.get_node("Amount").text = "Final Score: " + str(ScoreManager.current_score)
		_on_game_over()
		Events.emit_signal("game_won")


func _on_game_over() -> void:
	button_play_again.grab_focus()
	
	button_exit.set_focus_neighbor(SIDE_TOP, button_exit.get_path_to(button_play_again))
	button_play_again.show()
	button_exit.show()
	button_quit_game.show()

func _on_game_paused() -> void:
	get_tree().set_pause(true)
	
	button_resume.grab_focus()
	button_exit.set_focus_neighbor(SIDE_TOP, button_exit.get_path_to(button_resume))
	button_resume.show()
	button_exit.show()
	button_quit_game.show()

func _on_game_resumed() -> void:
	get_tree().set_pause(false)
	button_resume.hide()
	button_exit.hide()
	button_quit_game.hide()

func _on_button_exit_pressed() -> void:
	get_tree().set_pause(false)
	
	Global._reset()
	get_tree().change_scene_to_packed(Global.scene_paths["Main_Menu"])

func _on_button_resume_pressed() -> void:
	Events.emit_signal("game_resumed")

func _on_button_quit_game_pressed():
	get_tree().quit()

func _on_button_next_level_pressed():
	Events.emit_signal("next_level")
	get_tree().set_pause(false)
	
	level_won.hide()
	button_next_level.hide()
	button_exit.hide()
	button_quit_game.hide()
