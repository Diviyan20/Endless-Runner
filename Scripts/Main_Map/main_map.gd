extends Node

const PLAYER_START_POS: = Vector2i(288,936)
const CAM_START_POS: = Vector2i(960, 536)

var speed : float
const START_SPEED: float = 10.0
const MAX_SPEED: int = 25

func _ready():
	new_game()
	pass
	
func new_game():
	$Player.position = PLAYER_START_POS
	$Player.velocity = Vector2i(0,0)
	$Camera2D.position = CAM_START_POS
	pass

func _process(delta):
	speed = START_SPEED
	$Player.position.x += speed
	$Camera2D.position.x += speed
	pass
