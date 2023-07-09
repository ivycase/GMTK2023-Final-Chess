extends Control

@onready var background = get_node("Background")

var background_green = Color("81e39f")
var background_pink = Color("be81e3")

var shifting = false
var target = background_pink
var opposite_direction = Vector2(-1, 0)
var shift_interpolate = 0
var speed = 0.05

func _ready():
	randomize()
	background.position.x -= background.size.x / randf_range(2, 5)
	background.position.y -= background.size.y / randf_range(2, 5)
	
func _process(delta):
	if shifting && shift_interpolate <= 1:
		shift_interpolate += delta * speed
		
		var current_color = background.material.get_shader_parameter("color_shift")
		var new_color = current_color.lerp(target, shift_interpolate)
		background.material.set_shader_parameter("color_shift", new_color)
		
		var current_direction = background.material.get_shader_parameter("scroll_direction")
		var new_direction = current_direction.lerp(opposite_direction, shift_interpolate)
		background.material.set_shader_parameter("scroll_direction", new_direction)
	

func bg_color_shift(shift_green):
	shifting = true
	target = background_green if shift_green else background_pink
	opposite_direction = -opposite_direction
	shift_interpolate = 0
	
