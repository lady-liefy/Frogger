### main_camera.gd
extends Camera2D
class_name MainCamera

@export var player : Player

func _ready() -> void:
	_init_camera_limits(get_node("/root/World/Level0/Background/TileMap")) 

func _physics_process(_delta : float) -> void:
	if not is_instance_valid(player):
		return
	
	set_position(player.get_position())

func _init_camera_limits(tilemap : TileMap) -> void:
	var map_limits = tilemap.get_used_rect()
	var map_cellsize = tilemap.tile_set.tile_size
	
	self.limit_left = map_limits.position.x * map_cellsize.x
	self.limit_right = map_limits.end.x * map_cellsize.x - 128
	self.limit_top = map_limits.position.y * map_cellsize.y + 128
	self.limit_bottom = map_limits.end.y * map_cellsize.y + 64
