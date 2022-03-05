extends KinematicBody2D

#Spawn location of projectile
onready var projectileSpawn:Node2D = $ProjectileSpawn

#The path of the scene that will spawn as projectile can be changed in editor if needed
export var projectileToSpawn:String = "res://scenes/Projectiles/Plant Projectile/Plant Projectile.tscn"
#How much force the rigidbody projectile will apply on instance
export var projectileForceX:int = -50
export var delayBetweenShots = 5
export var desiredDamage = 10
export var isFliped = false
export var health = 20

#Do note the plant enemy does damage by colliding projectiles and not itself, refer to plant projectile or
#its projectile its spawning

func _ready():
	if isFliped:
		flip()
	var timer = $DelayBetweenShots
	timer.wait_time = delayBetweenShots
	
func hurt(var d:float = 0):
#	state_machine.travel("Hurt")
	health -= d
#	print("health: ", health)
	if health <= 0:
		die()
	
func die():
#	state_machine.travel("Die")
	#print("lives: ", lives)
	queue_free()

#Flip the sprite around and direction of shooting if needed
func flip():
	projectileSpawn.position = Vector2(-projectileSpawn.position.x,projectileSpawn.position.y)
	projectileForceX *= -1
	$sprite.flip_h = !$sprite.flip_h
	
#The function that handles the shooting of the desired projectile
func shoot():
	var loadedProjectile = load(projectileToSpawn)
	var projectile:RigidBody2D = loadedProjectile.instance()
	get_parent().add_child(projectile)
	projectile.damage = desiredDamage
	projectile.global_position = projectileSpawn.global_position
	projectile.linear_velocity.x = projectileForceX

func _on_DelayBetweenShots_timeout():
	shoot()
