extends Node2D

var player_node = null
var camera_node: Camera2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func angle_to_angle_neg(angle):
	return rad_to_deg(int(angle + 180 + 360) % 360 - 180)

func get_camera():
	return camera_node
