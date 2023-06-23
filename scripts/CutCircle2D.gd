@tool
extends Node2D
class_name CutCircle2D
@export var color: Color = Color("000000")
@export var radius: float 
@export var angle_from: float 
@export var angle_to: float 

func _ready():
	queue_redraw()

# from https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html
func draw_circle_arc_poly(center:Vector2, radius:float, angle_from:float, angle_to:float, color:Color, num_points:int = 32):
	var points_arc = PackedVector2Array()
	var colors = PackedColorArray([color])
	for i in range(num_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to - angle_from) / num_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)

func _draw():
	draw_circle_arc_poly(Vector2(0.0,0.0), radius, angle_from, angle_to, color)


