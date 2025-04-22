extends enemy_state
class_name enemy_melee

var timer
var melee_time = 1

var has_hit:Array = []

func enter():
	timer = 0
	entity.model_anim.melee_oneshot(randi() % 3)
	for i in entity.melee_array:
		i.enabled
	has_hit = [entity]

func exit():
	for i in entity.melee_array:
		i.disabled

func update(delta):
	pass

func physics_update(delta):
	entity.velocity = lerp (entity.velocity, Vector3(0, entity.velocity.y, 0), 1)
	timer += delta
	if timer >= melee_time:
		transition_to_state("enemy_combat")
		
	for i in entity.melee_array:
		
		if i.is_colliding():
			if i.get_collider().get_collision_layer() == 1:
				print("clink")
			elif i.get_collider().get_collision_layer() == 8:
				if i.get_collider().entity not in has_hit:
					#print("damage to: " + str(weapon.damage_ray.get_collider().entity))
					i.get_collider().entity.stats.damage(entity.melee_damage, entity.melee_elemental_type, entity.melee_stagger_damage, i.get_collision_point(), i.get_collider().hitbox_type, Vector3(0, 0, -1).rotated(Vector3.UP, entity.rotation.y).rotated(Vector3(1, 0, 0), entity.rotation.x))
					has_hit.append(i.get_collider().entity)
