extends Node

const PLAYER_START_POS: = Vector2i(288,936)
const CAM_START_POS: = Vector2i(960, 536)

var speed : float
var screen_size: Vector2i
const START_SPEED: float = 10.0
const MAX_SPEED: int = 25

func _ready():
	screen_size = get_window().size
	new_game()
	pass
	
func new_game():
	$Player.position = PLAYER_START_POS
	$Player.velocity = Vector2i(0,0)
	$Camera2D.position = CAM_START_POS
	pass

func _process(_delta):
	speed = START_SPEED
	$Player.position.x += speed
	$Camera2D.position.x += speed
	
	#update ground position
	if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
		$Ground.position.x +=screen_size.x
		$Ceiling.position.x +=screen_size.x
	pass
