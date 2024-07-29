extends Resource

class_name PointInfo

var is_fall_tile: bool = false
var is_left_edge: bool = false
var is_right_edge: bool = false
var is_left_wall: bool = false
var is_right_wall: bool = false
var is_position_point: bool = false
var point_id: int = 0
var position: Vector2 = Vector2()

func _init(point_id: int = -10000, position: Vector2 = Vector2()):
	self.point_id = point_id
	self.position = position


