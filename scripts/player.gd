### player_movement.gd
extends CharacterBody2D
class_name Player

@export var speed = 5

@onready var splat_anim = preload("res://scenes/audio/splat_audio.tscn")
@onready var splash_anim = preload("res://scenes/audio/splash_audio.tscn")
@onready var bonk_anim = preload("res://scenes/audio/bonk_audio.tscn")

@onready var max_lane := 0

var at_river := false
var on_log   := false
var active   := false
var tween: Tween

signal died

func _ready() -> void:
	active = true
	on_log = false
	at_river = false
	$AnimatedSprite2D.speed_scale = speed
	
	max_lane = ScoreManager.max_lane
	self._initialize_signals()

func _initialize_signals() -> void:
	Events.game_paused.connect(_on_game_paused)
	Events.game_resumed.connect(_on_game_resumed)

	Events.player_home.connect(arrive_home)

# ---------------------- PROCESSES -----------------------------------------------
func _physics_process(delta : float) -> void:
	if !active:
		return
	
	if tween == null or not tween.is_running():
		if at_river and not on_log:
			drown()
			return
		
		_process_inputs()
		position += velocity * Global.tile_size * delta * Global.game_speed

func _process_inputs() -> void:
	if Input.is_action_pressed("move_up"):
		move(Vector2.UP)
		$AnimatedSprite2D.rotation_degrees = 0
	if Input.is_action_pressed("move_down"):
		move(Vector2.DOWN)
		$AnimatedSprite2D.rotation_degrees = 180
	if Input.is_action_pressed("move_left"):
		move(Vector2.LEFT)
		$AnimatedSprite2D.rotation_degrees = 270
	if Input.is_action_pressed("move_right"):
		move(Vector2.RIGHT)
		$AnimatedSprite2D.rotation_degrees = 90

func move(direction : Vector2) -> void:
	tween = self.create_tween()
	var end_position = position + direction * Global.tile_size  # Calculate the end position outside the method call
	tween.tween_property(self, "position", end_position, 1.0 / speed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.play()
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play()
	
	# Check for hop
	if direction == Vector2.UP:
		# Enter the river
		if position.y == (Global.initial_position.y - Global.tile_size * 9):
			if max_lane == 6:
				max_lane = 8
				ScoreManager.max_lane = max_lane
			at_river = true
			
		if position.y == (Global.initial_position.y - Global.tile_size * (max_lane + 1)) \
		and (max_lane < 6 \
		or (max_lane > 7 and max_lane < 13)):
			Events.emit_signal("player_hop")
			max_lane += 1
			ScoreManager.max_lane = max_lane
			
	# Leave the river
	elif direction == Vector2.DOWN:
		if position.y == (Global.initial_position.y - Global.tile_size * 10):
			at_river = false
			

func drown() -> void:
	active = false
	
	var splash = splash_anim.instantiate()
	splash.global_position = global_position
	get_parent().add_child(splash)
	
	self.die()

func die() -> void:
	active = false
	$AnimatedSprite2D.hide()
	
	await get_tree().create_timer(0.7).timeout
	Events.emit_signal("player_died")
	died.emit()
	
	self.queue_free()

func arrive_home(home : Node2D) -> void:
	active = false
	
	ScoreManager.max_lane = 0
	max_lane = ScoreManager.max_lane
	
	$Audio/WinAudio.play()
	
	await $Audio/WinAudio.finished
	
	if tween != null or tween.is_running():
		tween.kill()
	position = home.position
	$AnimatedSprite2D.rotation_degrees = 180

	home.queue_free()

func _on_death_collider_body_entered(body: Node2D) -> void:
	if body.get_groups().is_empty():
		return
	
	# Death triggers
	if body.is_in_group("car"):
		var splat_a = splat_anim.instantiate()
		splat_a.global_position = global_position
		get_parent().add_child(splat_a)
		self.die()
	elif body.is_in_group("barrier"):
		var bonk = bonk_anim.instantiate()
		bonk.global_position = global_position
		get_parent().add_child(bonk)
		self.die()
	
	# Misc triggers (logs, turtles)
	elif body.is_in_group("log") or body.is_in_group("turtle"):
		on_log = true
		self.velocity = body.velocity / Global.tile_size / Global.game_speed

func _on_death_collider_body_exited(body: Node2D) -> void:
	if not on_log:
		return
	
	if body.is_in_group("log"):
		on_log = false
		self.velocity = Vector2.ZERO
	elif body.is_in_group("turtle"):
		on_log = false
		self.velocity = Vector2.ZERO

func set_enabled(value: bool) -> void:
	if value:
		active = true
		self.set_process_unhandled_input(true) # idk what this does <3
		self.set_physics_process(true) # turn on/off _physics_process
	else:
		active = false
		self.set_process_unhandled_input(false)
		self.set_physics_process(false)

func _on_game_paused() -> void:
	self.set_enabled(false)

func _on_game_resumed() -> void:
	self.set_enabled(true)
