extends "res://scripts/items/class_item.gd"
class_name weapon_gun

#one handed (two hands), two handed (rifle), one handed (one hand) ( revolver), (flashlight)
enum animation_sets {one_handed2, two_handed, one_handed, flashlight_handed, melee}
enum element {kinetic, thermal, shock, holy}

@export_subgroup("Weapon Parameters")
@export var animation_set: animation_sets = 0











#gun behaviour
@export_subgroup("Firing Parameters")
@export var damage: int = 0
@export var firing_rpm: int = 200
@export var stagger_damage: int = 0
@export var elemental_type: element = 0
@export var is_automatic: bool = false
@export var burst_amount: int = 1 #the amount fired per trigger pull.
@export var burst_time: float = 0.1 #the amount of time between burst shots
@export var magazine_size: int = 8 #how many bullets in a magazine
@export var ammo_name: String = "bullets" #the name of the ammo type, will check inventory for it.

@export_subgroup("Melee Parameters")
#melee settings
@export var melee_damage: int = 0
@export var melee_stagger_damage: int = 0
@export var melee_rpm: int = 60
@export var melee_elemental_type: element = 0
@export var swings_num = 1 # the amount of melee swing anims

#tracer settings
@export_subgroup("Tracer Parameters")
@export var tracer_colour: Color = Color("ffff00") #default is yellow for physical

@export_subgroup("Projectile Parameters")
#projectile settings
@export var is_projectile: bool = false #sets whether to use hitscan or projectile code
@export var projectile: PackedScene #set a custom projectile.

#firing visuals
@export_subgroup("Visuals")
@export var tracer: PackedScene #customise the beam
@export var flash: PackedScene #customise the muzzle flash
@export var ricochet: PackedScene
@export var bullet_hole: PackedScene

@export_subgroup("Sounds")
#firing sounds
@export var sound: PackedScene
#@export var firing_sound: PackedScene
#@export var ricochet_sound: PackedScene

#functional variables
var burst_counter: int #counts shots in burst
var current_ammo = 0




#independant variables
#var damage
var balance #analogous to stability
var weight #analogous to handling

#damage_ray for melee
@export_subgroup("Weapon Nodes")
@export var damage_ray: RayCast3D
@export var firing_location: Node3D
var current_firing_location:Node3D

#dependant variables
@export var recoil_amount: int = 100 #the amount of recoil (stablity)
@export var stow_speed: float = 0.5 #how long to stow weapon in seconds
@export var draw_speed: float = 0.5 #how long to draw weapon in seconds
@export var reload_speed: float = 1 #how long to reload weapon in seconds

func update_stats():
	pass

@export var has_animations = false
var model_anim




func weapon_ready():
	if has_animations:
		model_anim = $model/AnimationTree
	is_weapon = true
	is_gun = true
	current_ammo = magazine_size
	if tracer == null:
		tracer = preload("res://tracer.tscn")
	if flash == null:
		flash = preload("res://flash.tscn")
	if ricochet == null:
		ricochet = preload("res://ricochet.tscn")
	if bullet_hole == null:
		bullet_hole = preload("res://bullet_hole.tscn")
	if sound == null:
		sound = preload("res://sound.tscn")
	if projectile == null and is_projectile:
		projectile = preload("res://projectile.tscn")

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	is_gun = true
	weapon_ready()

func _process(delta: float) -> void:
	pass


var muzzle_flash_timer = 0.05
var muzzle_flash_timer_max = 0.05


func shoot_muzzle_flash():
	var flash_instance = flash.instantiate()
	flash_instance.firing_pos = current_firing_location.global_position
	flash_instance.colour = tracer_colour
	current_firing_location.add_child(flash_instance)
	#item.state_handler.current_state.weapon_model

func create_sound():
	var sound_instance = sound.instantiate()
	sound_instance.set_position = current_firing_location.global_position
	GAME.WORLD.SOUNDS.add_child(sound_instance)

func shoot_hitscan():
	create_sound()
	gun_kickback(recoil_amount)
	shoot_muzzle_flash()
	if biped.shoot_ray.is_colliding():
		print(biped.shoot_ray.get_collider())
		var tracer_instance = tracer.instantiate()
		tracer_instance.firing_pos = current_firing_location.global_position
		
		#tracer_instance.firing_rot = biped.playerViewRay.global_rotation
		tracer_instance.hit_pos = biped.shoot_ray.get_collision_point()
		tracer_instance.colour = tracer_colour
		tracer_instance.dist = current_firing_location.global_position.distance_to(biped.shoot_ray.get_collision_point())
		GAME.WORLD.PROJECTILES.add_child(tracer_instance)
		print(biped.shoot_ray.get_collision_mask_value(1))
		
		#spawn ricochet
		
		if biped.shoot_ray.get_collider().get_collision_layer() == 1:
			var ricochet_instance = ricochet.instantiate()
			ricochet_instance.spawn_position = biped.shoot_ray.get_collision_point()
			ricochet_instance.colour = tracer_colour
			ricochet_instance.wall_normal = biped.shoot_ray.get_collision_normal()
			GAME.WORLD.PROJECTILES.add_child(ricochet_instance)
			#place bullet hole if hit wall.
			var bullet_hole_instance = bullet_hole.instantiate()
			bullet_hole_instance.spawn_position = biped.shoot_ray.get_collision_point()
			bullet_hole_instance.wall_normal = biped.shoot_ray.get_collision_normal()
			GAME.WORLD.PROJECTILES.add_child(bullet_hole_instance)
		elif biped.shoot_ray.get_collider().get_collision_layer() == 8:
			var ricochet_instance = ricochet.instantiate()
			ricochet_instance.spawn_position = biped.shoot_ray.get_collision_point()
			ricochet_instance.colour = tracer_colour
			ricochet_instance.wall_normal = biped.shoot_ray.get_collision_normal()
			GAME.WORLD.PROJECTILES.add_child(ricochet_instance)
			print("hit_entity")
			print(biped.shoot_ray.get_collider())
			print(biped.shoot_ray.get_collider().entity.stats)
			biped.shoot_ray.get_collider().entity.stats.damage(damage, elemental_type, stagger_damage, biped.shoot_ray.get_collision_point(), biped.shoot_ray.get_collider().hitbox_type, current_firing_location.global_position - biped.shoot_ray.get_collision_point())
			#biped.shoot_ray.get_collider().
			#PUT FUNCTION IN STATS FOR THE TYPE OF BLOOD

func shoot_projectile():
	create_sound()
	shoot_muzzle_flash()
	var projectile_instance = projectile.instantiate()
	projectile_instance.initial_position = current_firing_location
	projectile_instance.direction = current_firing_location.global_position.direction_to(biped.shoot_ray.get_collision_point())
	projectile_instance.gun = self
	projectile_instance.colour = tracer_colour
	#projectile_instance.direction = Vector3(0, 0, -1).rotated(Vector3(1, 0, 0), biped.x_val).rotated(Vector3(0, 1, 0), biped.y_val)
	GAME.WORLD.PROJECTILES.add_child(projectile_instance)
	

#DELET THIS
#playerView.rotation.y = y_val
#playerViewRay.rotation.x = x_val

func primary_fire():
	if current_ammo > 0:
		biped.torso_handler.current_state.transition_to_state("torso_firing")
		burst_counter = burst_amount - 1
	else:
		biped.torso_handler.current_state.transition_to_state("torso_reload")
	

func secondary_fire():
	biped.torso_handler.current_state.transition_to_state("torso_swing")

func fire():
	if current_ammo > 0:
		if !is_projectile:
			shoot_hitscan()
		else:
			shoot_projectile()
		current_ammo -= 1
	#weapon kickback
	
	
	#biped.shoot_ray.rotation.x += 0.1
	#biped.shoot_ray.rotation.y += randi_range(-2, 2) * 0.01

func gun_kickback(amount: float):
	var effective_amount = amount
	if biped.stats.is_crouched:
		effective_amount /= 2
	biped.shoot_ray.rotation.x += 0.001 * effective_amount
	biped.shoot_ray.rotation.y += randi_range(-2, 2) * 0.0001 * effective_amount

func proc_reload():
	if current_ammo < magazine_size:
		biped.torso_handler.current_state.transition_to_state("torso_reload")

func reload():
	current_ammo = magazine_size
