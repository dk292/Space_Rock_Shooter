extends RigidBody2D

enum { INIT, ALIVE, INVULNERABLE, DEAD }

@export var engine_power = 500
@export var spin_power = 8000
@export var bullet_scene: PackedScene
@export var firing_rate = 0.25

var state = INIT
var thrust = Vector2.ZERO
var rotation_dir = 0
var screensize = Vector2.ZERO
var can_shoot = true

func _ready():
	change_state(ALIVE)
	screensize = get_viewport_rect().size
	$GunCooldown.wait_time = firing_rate
	
func _process(_delta):
	get_input()
	
func _physics_process(_delta):
	constant_force = thrust
	constant_torque = rotation_dir * spin_power
	
func _integrate_forces(physics_state): # to access transform property directly in physics state
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0, screensize.x)
	xform.origin.y = wrapf(xform.origin.y, 0, screensize.y)
	physics_state.transform = xform
	
func change_state(new_state):
	match new_state:
		INIT:
			$CollisionShape2D.set_deferred("disabled", true)
		ALIVE:
			$CollisionShape2D.set_deferred("disabled", false)
		INVULNERABLE:
			$CollisionShape2D.set_deferred("disabled", true)
		DEAD:
			$CollisionShape2D.set_deferred("disabled", true)
	
	state = new_state

func get_input():
	thrust = Vector2.ZERO
	if state in [DEAD, INIT]:
		return
	
	if Input.is_action_pressed("thrust"):
		thrust = transform.x * engine_power
	
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")
	
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()
	
func shoot():
	if state == INVULNERABLE:
		return
	
	can_shoot = false
	$GunCooldown.start()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start($Muzzle.global_transform)

func _on_gun_cooldown_timeout():
	can_shoot = true	
	
	
	
	
	
	
	

