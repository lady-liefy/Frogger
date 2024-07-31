extends Obstacle
class_name Turtle

@export var will_dive   : bool = false
@export var time_down   : float = 1.5
@export var time_up     : float = 3.0
@export var start_delay : float = 0.0

var animated_sprites : Array = []
var is_underwater : bool = false
var flash_on : bool = false
var timer : Timer
var flash_timer : Timer

func _ready():
	animated_sprites = self.find_children("AnimatedSprite2D*", "AnimatedSprite2D")
	
	for sprite in animated_sprites:
		sprite.play("default")
		sprite.speed_scale = Global.game_speed * self.speed
	
	super._ready()
	
	if not will_dive:
		return
	
	_init_timers()

func _init_timers() -> void:
	flash_timer = Timer.new()
	timer = Timer.new()
	add_child(flash_timer)
	add_child(timer)
	
	flash_timer.set_wait_time(0.15)
	flash_timer.set_autostart(false)
	flash_timer.connect("timeout", flash)

	timer.set_wait_time(time_up)
	timer.set_autostart(false)
	timer.connect("timeout", _on_timer_timeout)
	
	await get_tree().create_timer(start_delay).timeout
	timer.start(time_up)

func _on_timer_timeout() -> void:
	timer.stop()
	
	if is_underwater:
		surface()
	elif not is_underwater:
		dive()

func flash() -> void:
	flash_on = not flash_on
	
	for sprite in animated_sprites:
		if flash_on:
			sprite.modulate = Color(10, 10, 10, 10)
		else:
			sprite.modulate = Color.WHITE

func dive() -> void:
	flash_timer.start()
	
	await get_tree().create_timer(time_up).timeout
	flash_timer.stop()
	for sprite in animated_sprites:
		sprite.hide()
	
	$CollisionShape2D.set_deferred("disabled", true)
	is_underwater = true
	flash_on = false
	await get_tree().process_frame
	timer.start(time_down)

func surface() -> void:
	for sprite in animated_sprites:
		sprite.modulate = Color.WHITE
		sprite.show()
	
	is_underwater = false
	$CollisionShape2D.set_deferred("disabled", false)
	await get_tree().process_frame
	timer.start(time_up)
