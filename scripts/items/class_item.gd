extends RigidBody3D
class_name item

#item descripters
@export var item_name: String #name of the object
@export var item_description: String #shows up in description of item.

#item stats
@export var item_health: int
@export var max_stack: int #The amount the item can be stacked.

#item flags
@export var is_weapon: bool
@export var is_gun: bool = false
@export var is_melee: bool
@export var is_breakable: bool
@export var is_usabled: bool #Can you use the item? Potions etc.
@export var has_battery: bool


#state parameters
var state_handler

#physical parameters
var model
var collider
var item_ray #for enemy collision
#var item_area #doesn't seem to work with current implementation
#var item_area_collider

#world associations
var biped = null


# Called when the node enters the scene tree for the first time.w
func _ready() -> void:
	base_item_ready()
	

func throw_hit():
	item_ray.get_collider().entity.stats.damage(0, 0, linear_velocity.length() * mass, global_position, item_ray.get_collider().hitbox_type, linear_velocity)
	linear_velocity = -linear_velocity/3

func base_item_physics(delta):
	if linear_velocity.length() > 5 and item_ray.enabled == false:
		item_ray.enabled = true
		print("ray_enabled")
	elif linear_velocity.length() < 5 and item_ray.enabled == true:
		item_ray.enabled = false
		print("ray_disabled")
	
	if item_ray.enabled and state_handler.current_state.name == "item_object":
		if item_ray.is_colliding():
			print(item_ray.get_collider())
			throw_hit()
	####################################
	#AREA ATTEMPT
	#if linear_velocity.length() > 5 and item_area.monitoring == false:
		#item_area.monitoring = true
		#print("ray_enabled")
	#elif linear_velocity.length() < 5 and item_area.monitoring == true:
		#item_area.monitoring = false
		#print("ray_disabled")
	#
	#if item_area.monitoring and state_handler.current_state.name == "item_object":
		#print("item_area.has_overlapping_bodies(): " + str(item_area.has_overlapping_bodies()))
		#if item_area.has_overlapping_bodies():
			#print("item_area.get_overlapping_bodies()[0]:" + str(item_area.get_overlapping_bodies()[0]))
			#item_ray.get_overlapping_bodies()[0].entity.stats.damage(0, linear_velocity.length() * mass, global_position)
			#linear_velocity = -linear_velocity/3

func base_item_ready():
	if item_name != "":
		name = item_name
	else:
		name = "item"
	continuous_cd = true #continuous collision detection on (stops from falling throuhg floor)
	set_collision_layer_value(1, false)
	set_collision_layer_value(3, true)
	set_collision_mask_value(1, true)
	set_collision_mask_value(3, true)
	
	#create_state_handler()
	state_handler = load("res://scenes/items/item_subnodes/item_state_handler.tscn").instantiate()
	add_child(state_handler)
	
	if $collider:
		collider = $collider
	
	if $model:
		model = $model
	
	
	#throw hit collision ray init
	item_ray = RayCast3D.new()
	item_ray.enabled = false
	item_ray.target_position = Vector3(0, 0, -0.5)
	item_ray.set_collision_mask_value(1, false)
	item_ray.set_collision_mask_value(4, true)
	add_child(item_ray)
	
	#throw hit collision area init
	#item_area = Area3D.new()
	#item_area.monitoring = false
	#item_area_collider = collider.duplicate()
	#item_area.set_collision_mask_value(1, false)
	#item_area.set_collision_mask_value(4, true)
	#item_area.add_child(item_area_collider)
	#add_child(item_area)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	base_item_physics(delta)

func interact(interacter):
	if is_weapon:
		changeOwnership(interacter, true)
	else:
		pass

func changeOwnership(desired_biped, yesno: bool):
	#If yes, then add to equip (if nothing equipped) or inventory (if space)
	if yesno:
		biped = desired_biped
		if is_weapon and biped.inventory.equipped == null: #if pick up weapon
			biped.inventory.equipped = self
			state_handler.current_state.transition_to_state("item_equipped")
			biped.torso_handler.current_state.transition_to_state("torso_draw")
		elif is_weapon and biped.inventory.equipped != null: #if already holding something
			print("you already have something equipped.")
	else:
		state_handler.current_state.transition_to_state("item_object")
		biped = null
		
