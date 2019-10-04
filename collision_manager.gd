extends BaseCollisionManager

func _ready():	
	addMapping(Node2D, Bullet, funcref(self, "_handleBullet"))	
	addMapping(TileMap, KinematicBody2D, funcref(self, "_playerTileHandle"))
	addMapping(Item2, Player, funcref(self,"_playerItemHandle2"))
	addMapping(Item, Player, funcref(self,"_playerItemHandle"))

		

# See docs for KinematicBody2D:move_and_collide 
func moveAndCollide(entity : KinematicBody2D, velocity : Vector2, delta,
		infinite_inertia : bool =true, exclude_raycast_shapes : bool =true, test_only : bool =false):
	
	var collision_info = entity.move_and_collide(velocity * delta, infinite_inertia, exclude_raycast_shapes, test_only)
	if collision_info:
		_handleCollision(entity, collision_info.collider, collision_info)

# See docs for KinematicBody2D:move_and_slide 
func moveAndSlide(entity : KinematicBody2D, velocity : Vector2, floor_normal : Vector2 = Vector2( 0, 0 ),
		stop_on_slope : bool = false, max_slides : int =4 , floor_max_angle : float =0.785398, 
		infinite_inertia : bool =true):

	entity.move_and_slide(velocity, floor_normal, stop_on_slope, max_slides, floor_max_angle, infinite_inertia)
	for i in entity.get_slide_count():
		var collision_info = entity.get_slide_collision(i)
		if _handleCollision(entity, collision_info.collider, collision_info):
			break

func _entities_valid(key, entity1, entity2):
	var validTypes = false
		
	if entity1 is key[0] and entity2 is key[1]:
		validTypes = true
	elif entity2 is key[0] and entity1 is key[1]:
		validTypes = true
		
	return validTypes

func _playerTileHandle(entity1, entity2, collisionData : KinematicCollision2D) -> bool:
	
	if not entity1 is KinematicBody2D || not entity2 is TileMap:
		return false

	var entity : KinematicBody2D = entity1
	var tileMap : TileMap = entity2
	
	var tileData = tile_manager.newData(entity, tileMap, collisionData)
	
	return tile_manager._handleCollision(entity, tileData, collisionData)
	

func _playerItemHandle2(entity1, entity2, collisionData : KinematicCollision2D) -> bool:

	if not entity1 is Player || not entity2 is Item2:
		return false

	var item : Item2 = entity2
	
	print("NEW HANDLE")
	
	item.remove()
	return true

func _playerItemHandle(entity1, entity2, collisionData : KinematicCollision2D) -> bool:

	if not entity1 is Player || not entity2 is Item:
		return false

	var item : Item = entity2
	
	item.remove()
	return true
	
func _handleBullet(entity1, entity2, collisionData : KinematicCollision2D) -> bool:
	
	if not entity1 is Bullet:
		return false
	
	var hitEntity = null
	
	#Can't process damage TileMap with regular bullets	
	if not entity2 is TileMap:
		hitEntity = entity2
	
	var bullet : Bullet = entity1
	
	return bullet.onHit(hitEntity)