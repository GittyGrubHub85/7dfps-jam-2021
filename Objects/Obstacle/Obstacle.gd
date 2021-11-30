tool
extends StaticBody

export(float, 0, 1, .01) var r = 1
export(float, 0, 1, .01) var g = 1
export(float, 0, 1, .01) var b = 1

export(bool) var collision_isActivated = true

var rgb_script = preload("res://Other Scripts/rgb_script.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if collision_isActivated:
		$CollisionShape.disabled = false
	else:
		$CollisionShape.disabled = true
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	rgb_script.shift_material(r,g,b,$MeshInstance)
	
	pass

