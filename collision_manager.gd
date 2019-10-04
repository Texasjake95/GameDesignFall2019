extends Node2D

const collisionMappping = Dictionary()

func _ready():	
	addMapping(Node2D, Bullet, funcref(self, "_handleBullet"))	
	addMapping(TileMap, KinematicBody2D, funcref(self, "_playerTileHandle"))
	addMapping(Item2, Player, funcref(self,"_playerItemHandle2"))
	addMapping(Item, Player, funcref(self,"_playerItemHandle"))
	
static func addMapping(clazz1, clazz2, function : FuncRef):

	var key = [clazz1, clazz2]
	
	if not collisionMappping.has(key):
		collisionMappping[key] = function
		

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

func _check(node):
	return not is_instance_valid(node) || node.is_queued_for_deletion()

func _handleCollision(entity1, entity2, collisionData : KinematicCollision2D) -> bool:
	
	if not entity1 || not entity2:
		return false
	
	# Sometimes moveAndSlide does the same node several times if it was removed
	# at any point do not interact again
	if _check(entity1) || _check(entity2):
		return false
	
	var function = null
	
	for key in collisionMappping:
		
		var validTypes = false
		
		if entity1 is key[0] and entity2 is key[1]:
			validTypes = true
		elif entity2 is key[0] and entity1 is key[1]:
			validTypes = true
		
		if validTypes:
			function = collisionMappping.get(key)
			break
	
	if not function:
		return false
	
	return function.call_func(entity1, entity2, collisionData)


func getType(node):
		
	if node is String:
		return node
		
	var ret = node.get_script()
	if ret:
		return ret
	
	ret = typeof(node)
	return ret

func _playerTileHandle(entity1, entity2, collisionData : KinematicCollision2D) -> bool:
	
	if not entity1 is KinematicBody2D || not entity2 is TileMap:
		return false
	
	var entity : KinematicBody2D = entity1
	var tileMap : TileMap = entity2
	
	var tileData = tile_manager.newData(entity, tileMap, collisionData)
	
	return tile_manager.handleCollision(entity, tileData, collisionData)
	

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