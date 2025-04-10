extends Resource
class_name Item

enum Type {COMMON, UNCOMMON, RARE, LEGENDARY, BOSS, CHARACTER, MAIN}

@export_category("Information")
@export var type: Type
@export var itemName: String
@export var itemId: int
@export var itemAmt: int
@export var itemCounted: int
@export var texture: Texture2D
@export_multiline var itemDescription: String

@export_category("Stats")
@export var itemRangedDamage: int
@export var itemMeleeDamage: int
@export var itemDefense: float
@export var itemCritAdd: int
@export var itemCritMult: int
@export var itemHealthIncrease: int
@export var itemSpeedIncrease: int
@export var itemJumpIncrease: int
@export var itemAbility: String
