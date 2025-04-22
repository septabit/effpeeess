extends Node3D

#visuals
var model
var tail
var effect
var light

var gun: RigidBody3D

#parameters
@export var colour: Color = Color(255, 255, 0)
#@export var colour_override: bool #override the colour fed in from the gun
@export var speed: float = 1
@export var size: float = 1


#code shit
var direction
var initial_position

@export var ricochet: PackedScene
@export var bullet_hole: PackedScene

@onready var hit_ray = $RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	model = $model
	tail = $tail
	effect = $effect
	light = $light
	model.mesh.material.albedo_color = colour
	model.mesh.material.emission = colour
	model.mesh.radius = 0.0125 * size
	model.mesh.height = 2 * (0.0125 * size)
	tail.mesh.material.albedo_color = colour
	tail.mesh.material.emission = colour
	tail.mesh.bottom_radius = 0.0125 * size
	effect.draw_pass_1.material.set_albedo(colour)
	light.light_color = colour
	global_position = initial_position.global_position + (0.5 * direction)
	visible = true
	look_at(global_position + direction)
	hit_ray.target_position = Vector3(0, 0, -0.5)
	
	if ricochet == null:
		ricochet = preload("res://ricochet.tscn")
	if bullet_hole == null:
		bullet_hole = preload("res://bullet_hole.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	hit_ray.target_position = Vector3(0, 0, -speed*delta)
	if hit_ray.is_colliding():
		print("hit_ray.get_collider(): " + str(hit_ray.get_collider()))
		if hit_ray.get_collider().get_collision_layer() == 1:
			var ricochet_instance = ricochet.instantiate()
			ricochet_instance.spawn_position = hit_ray.get_collision_point()
			ricochet_instance.colour = colour
			ricochet_instance.wall_normal = hit_ray.get_collision_normal()
			GAME.WORLD.PROJECTILES.add_child(ricochet_instance)
			#place bullet hole if hit wall.
			var bullet_hole_instance = bullet_hole.instantiate()
			bullet_hole_instance.spawn_position = hit_ray.get_collision_point()
			bullet_hole_instance.wall_normal = hit_ray.get_collision_normal()
			GAME.WORLD.PROJECTILES.add_child(bullet_hole_instance)
		elif hit_ray.get_collider().get_collision_layer() == 8:
			var ricochet_instance = ricochet.instantiate()
			ricochet_instance.spawn_position = hit_ray.get_collision_point()
			ricochet_instance.colour = colour
			ricochet_instance.wall_normal = hit_ray.get_collision_normal()
			GAME.WORLD.PROJECTILES.add_child(ricochet_instance)
			hit_ray.get_collider().entity.stats.damage(gun.damage, gun.elemental_type, gun.stagger_damage, hit_ray.get_collision_point(), hit_ray.get_collider().hitbox_type, -direction)
			#biped.shoot_ray.get_collider().
		queue_free()
	
	global_position += speed * direction * delta
