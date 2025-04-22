extends Node3D

var time_alive #in seconds
var lifetime #in seconds

var firing_pos: Vector3
@export var flash: GPUParticles3D
@export var light: Light3D
#@export var flash_mesh: MeshInstance3D
var colour: Color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	#flash = $muzzle_flash
	#light = $muzzle_light
	
	light.light_color = colour
	flash.draw_pass_1.material.albedo_color = colour
	flash.draw_pass_1.material.emission = colour
	#if flash_mesh != null:
		#flash_mesh.mesh.material.albedo_color = colour
		#flash_mesh.mesh.material.emission = colour
	lifetime = flash.lifetime
	flash.emitting = true
	global_position = firing_pos
	time_alive = 0 # Replace with function body.
	visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_alive += delta
	if time_alive > lifetime:
		queue_free()
