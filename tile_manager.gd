extends Node

var validDirs = []
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for x in range(-1, 2):
		for y in range(-1, 2):
			validDirs.push_back(Vector2(x, y))
	
	print(validDirs)
	addMapping(Bullet, "wall", funcref(self, "bulletHandle"))
	addMapping(KinematicBody2D, "wall", funcref(self, "wallHandle"))
	addMapping(KinematicBody2D, "column", funcref(self, "wallHandle"))


func bulletHandle(entity : Bullet, tileData: TileData, collisionData : KinematicCollision2D):
	entity.onHit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func wallHandle(entity, tileData: TileData, collisionData : KinematicCollision2D):
	tileData.setCell(-1)
	

const collisionMappping = Dictionary()

#param 2 tileName?
static func addMapping(clazz1, clazz2, function : FuncRef):

	var key = [clazz1, clazz2]
	
	if not collisionMappping.has(key):
		collisionMappping[key] = function
		
func _check(node):
	return not is_instance_valid(node) || node.is_queued_for_deletion()
	
func handleCollision(entity, tile: TileData, collisionData : KinematicCollision2D) -> bool:
	
	if not entity || not tile:
		return false
	 
	# Sometimes moveAndSlide does the same node several times if it was removed
	# at any point do not interact again
	if _check(entity) || tile.notValid():
		return false
	
	var function = null
	
	for key in collisionMappping:
		
		var entity1Valid = false
		var entity2Valid = false
		
		for type in key:
			
			if type is String:
				entity2Valid = tile.sameTile(type)
			elif entity is type:
				entity1Valid = true
		
		if entity1Valid and entity2Valid:
			function = collisionMappping.get(key)
			break
	
	if not function:
		return false
	
	function.call_func(entity, tile, collisionData)
	return true

	
func newData(entity, tileMap: TileMap, collisionData : KinematicCollision2D):
	var ret = TileData.new()
	ret.init(tileMap, collisionData)
	return ret;
	
class TileData:
	
	var tileMap : TileMap
	var tilePos : Vector2
	var tileID : int
	var tileName : String
	
	func init(tileMap: TileMap, collisionData : KinematicCollision2D):
		
		var entPos = collisionData.position
		var currentTile = tileMap.world_to_map(entPos)
		
		var dist = tileMap.cell_size.length_squared() * 1000
		var tile = Vector2(0,0)
		
		for v in tile_manager.validDirs:
			
			var tilePos = currentTile + v
			
			var tileID = tileMap.get_cellv(tilePos)
			
			if tileID == -1:
				continue
			
			var dirTile = tileMap.map_to_world(currentTile + v)
			if dirTile.distance_squared_to(entPos) < dist:
				dist = dirTile.distance_squared_to(entPos)
				tile = v
		
		init_pos(tileMap, currentTile + tile)
	
	func init_pos(tileMap: TileMap, tilePos : Vector2):
		self.tileMap = tileMap
		self.tilePos = tilePos
		self.tileID = tileMap.get_cellv(tilePos)
		if tileID == -1:
			self.tileName = "NULL"
		else:
			self.tileName = tileMap.tile_set.tile_get_name(tileID)
	
	func setCell(newID: int):
		self.tileMap.set_cellv(tilePos, newID)
	
	func notValid():
		return self.tileID == -1
	
	func sameTile(other):
		return other == tileName