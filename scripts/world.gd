### world.gd
extends Node

@onready var player : Player = $Player
@onready var current_level : Node2D = $Level0

var player_prefab = preload("res://scenes/player.tscn")
var next_level_id := 0

func _ready() -> void:
	Global.current_level_id = next_level_id
	$Timer.set_wait_time(Global.timer_length)
	
	Events.timer_tick.emit($Timer.wait_time) #initialize timer display
	
	reset()
	_initialize_signals()

func _physics_process(_delta: float) -> void:
	if not $Timer.is_stopped():
		await get_tree().create_timer(1.0).timeout
		Events.timer_tick.emit($Timer.time_left + 1)

func _initialize_signals() -> void:
	Events.player_home.connect(on_player_home)
	Events.level_won.connect(on_level_won)

func clear_level() -> void:
	if current_level != null and is_instance_valid(current_level):
		current_level.queue_free()
	for frog in get_tree().get_nodes_in_group("Frog"):
		if is_instance_valid(frog):
			frog.queue_free()
	for splat in get_tree().get_nodes_in_group("Splat"):
		if is_instance_valid(splat):
			splat.queue_free()
	
func reset() -> void:
	ScoreManager.current_homes = 0
	clear_level()
	
	await get_tree().process_frame
	
	if not get_tree().get_nodes_in_group("Frog"):
		spawn_player()
	
	# Create the next level
	var next_level = Global.levels[next_level_id].instantiate()
	add_child(next_level)
	$Camera2D._init_camera_limits(next_level.get_node("Background/TileMap"))
	current_level = next_level
	
	$Timer.start(Global.timer_length)

func on_player_home(_home : Node2D) -> void:
	if not ScoreManager.current_homes == Global.homes_to_win:
		await get_tree().create_timer(0.8).timeout
		
		ScoreManager.set_current_score( \
			ScoreManager.current_score + ceili($Timer.time_left) * 10)
		
		$Timer.start()
		spawn_player()

func on_player_died() -> void:
	player = null
	
	if ScoreManager.current_lives > 0:
		spawn_player()
	else:
		Events.emit_signal("game_over")
		next_level_id = 0
		Global.current_level_id = next_level_id
		reset()

func on_level_won() -> void:
	next_level_id += 1
	Global.current_level_id = next_level_id
	
	player.queue_free()
	player = null

	if next_level_id == Global.levels.size():
		next_level_id = 0
		await Events.game_restarted
		ScoreManager.set_current_lives(Global.max_lives)
		reset()
	else :
		await Events.next_level
		reset()

func spawn_player() -> void:
	player = player_prefab.instantiate()
	
	call_deferred("add_child", player)
	
	if not player.is_in_group("frog"):
		player.add_to_group("frog")
		
	player.died.connect(on_player_died)
	player.position = Global.initial_position
	$Camera2D.player = player
	
	await get_tree().process_frame
	$Timer.start(Global.timer_length)

# for countdown
func _on_timer_timeout():
	if player != null and is_instance_valid(player):
		Events.emit_signal("time_up")
		player.die()
