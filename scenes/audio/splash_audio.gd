extends Node2D

func _ready():
	$Splash.emitting = true
	$Splash2.emitting = true
	await get_tree().create_timer(5.0).timeout
	queue_free()
