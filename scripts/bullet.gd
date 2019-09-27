extends Entity_Base



class_name Bullet

const MOTION_SPEED = 160 # Pixels/second



static func _fireBullet(firingEntity, direction):
	var bulletEntityScene = load("res://entity/bullet.tscn")
	var bullet = bulletEntityScene.instance()
	bullet.init(firingEntity, direction)
	firingEntity.get_parent().add_child(bullet)

static func fireBullet(firingEntity, direction, numberOfBullets=1):
	
	direction = direction.normalized()
	
	#At least one bullet should go in direction fired
	_fireBullet(firingEntity, direction)
	
	for i in range(1, numberOfBullets):
		
		#TODO randomize slightly
		var subDirection = direction
		_fireBullet(firingEntity, subDirection)

		pass

static func fireBulletPlayer(playerEntity, mousePos : Vector2, numberOfBullets=1):
	#See if this is right
	var direction = playerEntity.position - mousePos
	fireBullet(playerEntity, direction, numberOfBullets)
	pass

static func fireBulletAtEntity(firingEntity, targetEntity, numberOfBullets=1):
	#See if this is right
	var direction = firingEntity.position - targetEntity.position
	fireBullet(firingEntity, direction, numberOfBullets)


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var firingEntity
var direction
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init(firingEntity, direction):
	self.position = firingEntity.position
	self.firingEntity = firingEntity
	self.direction = direction.normalized()

func onHit(hitEntity=null) -> bool:
	if hitEntity == firingEntity or get_class() == hitEntity.get_class() :
		return false
	
	queue_free() # ONLY DO THIS IF ALL NODE (CHILDREN INCLUDED) NEED TO BE DELETED
	
	if hitEntity != null && hitEntity is Entity_Base:
		pass
	return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var motion = direction.normalized() * MOTION_SPEED
	
	collision_manager.moveAndSlide(self, motion)
