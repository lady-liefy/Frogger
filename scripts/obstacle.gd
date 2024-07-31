extends CharacterBody2D
class_name Obstacle

@export var vel: Vector2 = Vector2.ZERO
@export var speed: float = 1.0

func _ready() -> void:
	velocity = vel
	set_velocity(velocity * Global.tile_size * Global.game_speed * self.speed)
	self._initialize_signals()
	self.set_enabled(true)

func _initialize_signals() -> void:
	Events.game_paused.connect(on_game_paused)
	Events.game_over.connect(on_game_over)
	Events.game_restarted.connect(on_game_restarted)
	Events.game_resumed.connect(on_game_resumed)

func _physics_process(_delta: float) -> void:
	move_and_slide()
	
	# Reset positions once offscreen
	if velocity.x > 0 and global_position.x > 800:
		global_position.x -= 1200
	elif velocity.x < 0 and global_position.x < -250:
		global_position.x += 1600

func on_game_paused() -> void:
	self.set_enabled(false)

func on_game_over() -> void:
	self.set_enabled(false)

func on_game_restarted() -> void:
	self.set_enabled(true)
	
func on_game_resumed() -> void:
	self.set_enabled(true)

func set_enabled(value: bool) -> void:
	if value:
		self.set_physics_process(true)
	else:
		self.set_physics_process(false)
