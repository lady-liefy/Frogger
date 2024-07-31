### level.gd
extends Node
class_name Level

func _ready() -> void:
	_reset()
	self._initialize_signals()

func _initialize_signals() -> void:
	Events.game_restarted.connect(on_game_restarted)

func on_game_restarted() -> void:
	_reset()

func _reset() -> void:
	$Background/River/AnimationPlayer.play("default")
	$Background/River/AnimationPlayer.speed_scale = Global.game_speed

func _on_arrival_home(home : Node2D) -> void:
	Events.emit_signal("player_home", home)
