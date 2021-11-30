#tool
extends KinematicBody

#Camera Config
const CAMERA_ROTATION_SPEED = 0.003
var CAMERA_X_ROT_MIN = -90#up
var CAMERA_X_ROT_MAX = 90#down
var cameraDistance = 0
var camera_x_rot = 0.0
onready var cameraPath = get_node("camera_base/camera_rot/camera_ray_cast")

#Player Movements
export var moveSpeed = 8
var root_motion = Transform()
var orientation = Transform()
var velocity = Vector3()
var GRAVITY = Vector3(0,-39.8, 0)
var JUMP_SPEED = 18

#Player Perspective
enum CameraMode {TPS_MODE, FPS_MODE}
export (CameraMode) var cameraMode

#Miscellaneous
var timer



func _init():
	cameraPath = get_node("camera_base/camera_rot/camera_ray_cast/Camera")

# Called when the node enters the scene tree for the first time.
func _ready():
	if !Engine.editor_hint:
		$mesh_root/CSGMesh.hide()
		CameraModeReady()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		
		timer = Timer.new() 		# Create a new Timer node
		timer.set_wait_time(1) 		# Set the wait time
		add_child(timer)			# Add it to the node tree as the direct child
		timer.start()			# Start it
		timer.autostart = true
		timer.one_shot = true
		
		#get_node("mesh_root/chibby animations/AnimationPlayer").play("Idle")
		#get_node("mesh_root/chibby animations/AnimationPlayer").get_animation("Idle").set_loop(true)
		pass # Replace with function body.


func _process(delta):
	
	pass

func _physics_process(delta):
	
	# BELOW -- CAMERA -- CAMERA --  CAMERA --  CAMERA --  CAMERA --  CAMERA --  CAMERA --  CAMERA --  CAMERA --  CAMERA --  CAMERA --  CAMERA -- 
	CameraModePhysicsProcess()
	
	var cam_z = -cameraPath.global_transform.basis.z
	var cam_x = cameraPath.global_transform.basis.x
	
	cam_z.y=0
	cam_z = cam_z.normalized()
	cam_x.y=0
	cam_x = cam_x.normalized()
	
	
	if (is_on_floor() and Input.is_action_just_pressed("jump")):
		velocity.y = JUMP_SPEED
	
	#if(Input.get_action_strength("move_right") or Input.get_action_strength("move_left") or Input.get_action_strength("move_forward") or Input.get_action_strength("move_backward")):
	var get_rot_cam = $camera_base.rotation_degrees
	$mesh_root.rotation_degrees.y = get_rot_cam.y
	#print_slowly($mesh_root.rotation_degrees.y)
	#pass
	
	$camera_base/camera_rot/RayCast.cast_to = cameraPath.transform.origin
	#$camera_base/camera_rot/RayCast.cast_to = cameraPath.transform.origin + Vector3(5,0,0)
	#$camera_base/camera_rot/RayCast.cast_to = cameraPath.transform.origin + Vector3(-5,0,0)
	#print($camera_base/camera_rot/RayCast.get_cast_to())
	#$camera_base/camera_rot/RayCast.cast_to = $camera_base/camera_rot/camera_ray_cast.transform.origin
	
	#print_slowly("Camera: " + str(cameraPath.global_transform.origin) + " Camera ray cast root: " + str($camera_base/camera_rot/camera_ray_cast/Camera.global_transform.origin))
	
	if $camera_base/camera_rot/RayCast.is_colliding():
		#print($camera_base/camera_rot/RayCast.get_collision_point())
		#cameraPath.global_transform.origin = $camera_base/camera_rot/RayCast.get_collision_point()
		$camera_base/camera_rot/camera_ray_cast.global_transform.origin = $camera_base/camera_rot/RayCast.get_collision_point()
		#print("Camera ray cast root: " + str($camera_base/camera_rot/camera_ray_cast.global_transform.origin))
		#print("Camera: " + str($camera_base/camera_rot/camera_ray_cast/Camera.global_transform.origin))
		
	
	# ABOVE -- CAMERA -- CAMERA --  CAMERA --  CAMERA --  CAMERA --  CAMERA --  CAMERA --  CAMERA --  CAMERA --  CAMERA --  CAMERA --  CAMERA -- 
	
	var inputX : float = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * moveSpeed;
	var inputZ : float = (Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")) * -moveSpeed;
	root_motion = Transform(transform.basis,$"mesh_root".transform * Vector3(inputX,0,inputZ))
	#print_slowly(str(inputZ))
	
	
	if inputX != 0 or inputZ != 0:
		
		#var test = get_node("mesh_root/chibby animations/AnimationTree").get("parameters/Blend2/blend_amount")
		get_node("mesh_root/chibby animations/AnimationTree").set("parameters/Transition/current", 1)
		#get_node("mesh_root/chibby animations/AnimationTree").set("parameters/Blend2/blend_amount",1)
		#get_node("mesh_root/chibby animations/AnimationTree").set("parameters/Blend2/blend_amount",1)
		#get_node("mesh_root/chibby animations/AnimationTree").get("parameters/Blend2/blend_amount")
		
		pass
	else:
		#get_node("mesh_root/chibby animations/AnimationTree").set("parameters/Blend2/blend_amount",0)
		get_node("mesh_root/chibby animations/AnimationTree").set("parameters/Transition/current",0)
		pass
	
	
	# apply root motion to orientation
	orientation = root_motion
	
	var h_velocity = orientation.origin / delta
	
	velocity.x = h_velocity.x * delta
	velocity.z = h_velocity.z * delta
	
	#Glitch fixing (issues with player when moving up on slopes and stops and would jump based on its remaining remainder on its y axis)
	if not is_on_floor():
		pass
	else:
		if Input.is_action_just_released("move_right") or Input.is_action_just_released("move_left") \
		or Input.is_action_just_released("move_forward") or Input.is_action_just_released("move_backward") \
		and !Input.is_action_just_released("jump"):
			velocity.y = 0
			pass
	velocity += GRAVITY * delta
	
	if !Engine.editor_hint:
		velocity = move_and_slide(velocity,Vector3(0,1,0),true)
	
	#$camera_base.rotate_y(.025)

func _input(event):
	if event is InputEventMouseMotion:
		
		$camera_base.rotate_y( -event.relative.x * CAMERA_ROTATION_SPEED )
		#$camera_base.rotation_degrees.y += -event.relative.x * CAMERA_ROTATION_SPEED #using this code as a replacement of rotate_y() DIDN'T WORK!!!! >:(
		#print_slowly($camera_base.rotation_degrees.y)
		$camera_base.orthonormalize() # after relative transforms, camera needs to be renormalized
		camera_x_rot = clamp(camera_x_rot + event.relative.y * CAMERA_ROTATION_SPEED,deg2rad(CAMERA_X_ROT_MIN), deg2rad(CAMERA_X_ROT_MAX) )
		$camera_base/camera_rot.rotation.x =  -camera_x_rot
		
	
	if event is InputEventMouse:
		if event.is_pressed():
			if event.get_button_mask() == BUTTON_LEFT:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				pass
	
	if event is InputEventKey:
		if event.is_pressed():
			if event.get_scancode() == KEY_ESCAPE:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				pass
	
	
	if Input.is_action_pressed("scroll_up") and cameraDistance > 3:
		cameraDistance -= 1
		#print(cameraDistance)
		if(cameraDistance == 3):
			cameraMode = CameraMode.FPS_MODE 
			CameraModeReady()
	elif Input.is_action_pressed("scroll_down") and cameraDistance < 15:
		if(cameraMode == CameraMode.FPS_MODE):
			cameraMode = CameraMode.TPS_MODE
			CameraModeReady()
			cameraDistance = 3
			
		cameraDistance += 1
		

func CameraModeReady():
	
	if(cameraMode == CameraMode.FPS_MODE):
		
		"""
		if(shapeType == ShapeType.Capsule):
			$CapsuleMesh.hide()
			pass
		elif (shapeType == ShapeType.Cylinder):
			$CylinderMesh.hide()
			pass
		
		#if(not $CapsuleCollision.disabled):
		#	$CapsuleMesh.hide()
		"""
		
		#$"mesh_root/CSGMesh".hide()
		$"model_mesh_root/CSGMesh".hide()
		
		$"mesh_root/chibby animations".hide()
		cameraDistance = 0
		CAMERA_X_ROT_MIN = -90#up
		CAMERA_X_ROT_MAX = 90#down
		pass
	elif(cameraMode == CameraMode.TPS_MODE):
		
		"""
		if(shapeType == ShapeType.Capsule):
			$CapsuleMesh.show()
			pass
		elif (shapeType == ShapeType.Cylinder):
			$CylinderMesh.show()
			pass
		"""
		cameraDistance = 4
		#$"mesh_root/CSGMesh".show()
		$"model_mesh_root/CSGMesh".show()
		
		$"mesh_root/chibby animations".show()
		CAMERA_X_ROT_MIN = -90#down
		CAMERA_X_ROT_MAX = 90#up
	
	if($camera_base/camera_rot.rotation.x > -deg2rad(CAMERA_X_ROT_MIN)):#down direction max of camera orbit
		$camera_base/camera_rot.rotation.x =  -deg2rad(CAMERA_X_ROT_MIN)
	
	if($camera_base/camera_rot.rotation.x < -deg2rad(CAMERA_X_ROT_MAX)):#up direction max of camera orbit
		$camera_base/camera_rot.rotation.x =  -deg2rad(CAMERA_X_ROT_MAX)

func CameraModePhysicsProcess():
	
	if(cameraMode == CameraMode.FPS_MODE):
		#cameraPath.transform = Transform(cameraPath.transform.basis,Vector3(0,0,0))
		$camera_base/camera_rot/camera_ray_cast.transform = Transform($camera_base/camera_rot/camera_ray_cast.transform.basis,Vector3(0,0,1))
		#print_slowly("FPS MODE")
	elif(cameraMode == CameraMode.TPS_MODE):
		#cameraPath.transform = Transform(cameraPath.transform.basis,Vector3(0,0,cameraDistance))
		$camera_base/camera_rot/camera_ray_cast.transform = Transform($camera_base/camera_rot/camera_ray_cast.transform.basis,Vector3(0,0,cameraDistance+1))
		pass
		#print_slowly("TPS MODE")

func print_slowly(text):
	#Problem: it did print out per sec, but it print a lot at the start
	if !Engine.editor_hint:
		if(timer.get_time_left() == 0):
			print(text)
			timer.start()






