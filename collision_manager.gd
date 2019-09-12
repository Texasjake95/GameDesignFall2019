extends Node2D

const collisionMappping = Dictionary()

func addMapping(clazz1, clazz2, function : String):

	var key = [clazz1, clazz2]
	
	if not collisionMappping.has(key):
		collisionMappping[key] = function

func moveAndCollide(entity : Entity_Base, velocity : Vector2, delta):
	
	var collision_info = entity.move_and_collide(velocity * delta)
	if collision_info:
		handleCollision(entity, collision_info.collider, collision_info)
		
func moveAndSlide(entity : Entity_Base, velocity : Vector2):

	entity.move_and_slide(velocity)
	for i in entity.get_slide_count():
		var collision_info = entity.get_slide_collision(i)
		handleCollision(entity, collision_info.collider, collision_info)

		
func handleCollision(entity1, entity2, collisionData : KinematicCollision2D):
	
	if not entity1 || not entity2:
		return
	
	# Sometimes moveAndSlide does the same node several times if it was removed
	# at any point do not interact again
	if entity1.is_queued_for_deletion() || entity2.is_queued_for_deletion():
		return
	
	var functionName = null
	
	for key in collisionMappping:
		
		var entity1Valid = false
		var entity2Valid = false
		
		for type in key:
			
			if entity1 is type:
				entity1Valid = true
			elif entity2 is type:
				entity2Valid = true	
		
		if entity1Valid and entity2Valid:
			functionName = collisionMappping.get(key)
			break
	
	if not functionName:
		return
	
	call(functionName, entity1, entity2, collisionData)

func _ready():	
	addMapping(TileMap, Player, "playerTileHandle")
	addMapping(Item2, Player, "playerItemHandle2")
	addMapping(Item, Player, "playerItemHandle")

func getType(node):
		
	if node is String:
		return node
		
	var ret = node.get_script()
	if ret:
		return ret
	
	ret = typeof(node)
	return ret

func playerTileHandle(entity1 : Entity_Base, entity2 : Entity_Base, collisionData : KinematicCollision2D):
	#TODO call an external script to handle TileMap Entity interaction
	print("TILE HANDLED")
	

func playerItemHandle2(entity1 : Entity_Base, entity2 : Entity_Base, collisionData : KinematicCollision2D):

	if not entity1 is Player || not entity2 is Item2:
		return

	var item : Item2 = entity2
	var player : Player = entity1
	
	print("NEW HANDLE")
	
	item.remove()

func playerItemHandle(entity1 : Entity_Base, entity2 : Entity_Base, collisionData : KinematicCollision2D):

	if not entity1 is Player || not entity2 is Item:
		return

	var item : Item = entity2
	var player : Player = entity1
	
	item.remove()