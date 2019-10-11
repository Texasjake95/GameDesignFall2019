extends BaseCollisionManager

var validDirs = []
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for x in range(-1, 2):
		for y in range(-1, 2):
			validDirs.push_back(Vector2(x, y))
	
	addMapping(KinematicBody2D, "wall", funcref(self, "wallHandle"))
	addMapping(KinematicBody2D, "column", funcref(self, "wallHandle"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func wallHandle(entity, tileData: TileData, collisionData : KinematicCollision2D):
	tileData.setCell(-1)
	return true
	
	
func _check(entity):
	
	if entity is TileData:
		return entity.notValid()
		
	return ._check(entity)

func _entities_valid(key, entity, tile):
	
	var tileType = ""
	var entityType = null
	
	#Find the string in the array 
	#to compare the tile properly
	if key[0] is String:
		tileType = key[0]
		entityType = key[1]
	else:
		tileType = key[1]
		entityType = key[0]
	
	return tile.sameTile(tileType) and entity is entityType
	
	
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
		
		for v in collision_manager.tile_manager.validDirs:
			
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