extends CharacterBody2D

const ARROW = preload("res://Scenes/arrow.tscn")

const SPEED = 100.0
const ACCEL = 10.0
const JUMP_VELOCITY = -400.0

#State Variables
enum ENEMY_STATE {
	WALK,
	PARRY
}

var enemy_state = ENEMY_STATE.WALK
var parry_count: int = 300 + randi_range(1,3)
var direction: Vector2 = Vector2.RIGHT

func _ready():
	add_to_group("enemies")

func _physics_process(delta):
	
	match enemy_state:
		ENEMY_STATE.WALK:
			enemy_state_walk()
		ENEMY_STATE.PARRY:
			enemy_state_parry()

	move_and_slide()
	
func enemy_state_walk():
	direction = Vector2.RIGHT.rotated(global_position.angle_to_point(GameManager.player_node.global_position))
	velocity.x = move_toward(velocity.x, SPEED * sign(direction.x), ACCEL)
	velocity.y = move_toward(velocity.y, SPEED * sign(direction.y), ACCEL)
	
func enemy_state_parry():
	#pass
	velocity = Vector2.ZERO
	
func defend_function():
	pass


func _on_ball_collision_body_entered(body):
	
	if parry_count <= 0:
		queue_free()
		return
		
	parry_count -= 1	
	enemy_state = ENEMY_STATE.PARRY
	var arrow_instance = ARROW.instantiate()
	arrow_instance.set_deferred("global_position", global_position)
	GameManager.call_deferred("add_child",arrow_instance)
	arrow_instance.set_deferred("global_position", global_position)
