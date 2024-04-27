extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

#State Variables
enum ENEMY_STATE {
	WALK,
	PARRY
}

var enemy_state = ENEMY_STATE.WALK
var parry_count: int = randi_range(1,3)
var direction: Vector2 = Vector2.RIGHT

func _physics_process(delta):
	
	match enemy_state:
		ENEMY_STATE.WALK:
			enemy_state_walk()
		ENEMY_STATE.PARRY:
			enemy_state_parry()

	move_and_slide()
	
func enemy_state_walk():
	direction = Vector2.RIGHT.rotated(global_position.angle_to_point(GameManager.player_node.global_position))
	velocity.x = move_toward(velocity.x, 0, SPEED)
	velocity.y = move_toward(velocity.y, 0, SPEED)
	
func enemy_state_parry():
	velocity = Vector2.ZERO
	
func defend_function():
	pass
