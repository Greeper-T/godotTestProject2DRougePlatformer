extends Resource
class_name Item

enum Type {COMMON, UNCOMMON, RARE, LEGENDARY, BOSS, CHARACTER, MAIN}

@export_category("Information")
@export var type: Type
@export var itemName: String
@export var itemId: int
@export var itemTexture: Texture2D
@export_multiline var itemDescription: String

@export_category("Stats")
@export var itemDamage: int
@export var itemDefense: int
@export var itemCritAdd: int
@export var itemCritMult: int
@export var itemHealthIncrease: int
@export var itemSpeedIncrease: int
@export var itemAbility: String
