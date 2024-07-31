extends Node2D

func _ready():
	$Splat.emitting = true
	await get_tree().create_timer(8.0).timeout
	queue_free()
