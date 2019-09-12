extends Node2D

const collisionMappping = Dictionary()

#TODO create a TileMap version of this script that this script will call in the event there is a TileMap involved
func addMapping(clazz1, clazz2, function : String):

	var key = [clazz1, clazz2]
	
	print(key)
	
	if not collisionMappping.has(key):
		collisionMappping[key] = function

func moveAndCollide(entity : Entity_Base, velocity : Vector2, delta):
	
	var collision_info = entity.move_and_collide(velocity * delta)
	if collision_info:
		handleCollision(entity, getFromCollision(collision_info), collision_info)

func handleCollision(entity1, entity2, collisionData : KinematicCollision2D):
	
	if not entity1 || not entity2:
		return
	
	var functionName = null
	
	for key in collisionMappping.keys():
		
		var entity1Valid = false
		var entity2Valid = false
		
		for type in key:
			print(type)
			
			if entity1 is type:
				entity1Valid = true
			elif entity2 is type:
				entity2Valid = true	
		
		if entity1Valid and entity2Valid:
			functionName = collisionMappping.get(key)
			break
	
	if not functionName:
		var key = [getType(entity1), getType(entity2)]	
		key.sort()
		
		print("NOT FOUND:")
		print(key)
		return
	
	call(functionName, entity1, entity2, collisionData)

func _ready():	
	addMapping(Item2, Player, "playerItemHandle2")
	addMapping(Item, Player, "playerItemHandle")


func getFromCollision(collisionData : KinematicCollision2D):
	var node = collisionData.collider
	
	if node is TileMap:
		var tile_pos = node.world_to_map(collisionData.position)
		tile_pos -= collisionData.normal
		var tile_id = node.get_cellv(tile_pos)
		
		return "TileMap: " + node.tile_set.tile_get_name(tile_id)
	
	return node
		

func getType(node):
		
	if node is String:
		return node
		
	var ret = node.get_script()
	if ret:
		return ret
	
	ret = typeof(node)
	return ret
	
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