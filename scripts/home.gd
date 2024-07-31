extends Area2D
class_name Home

var is_occupied := false

signal frog_arrived(home : Node2D)

func _on_body_entered(body : CharacterBody2D) -> void:
	if is_occupied:
		return
	
	if body is Player:
		is_occupied = true
		frog_arrived.emit(body)
		await get_tree().create_timer(0.6).timeout
		$Sprite2D.visible = true
