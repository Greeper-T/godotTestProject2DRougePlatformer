class_name ItemData
extends Resource

enum Type {COMMON, UNCOMMON, RARE, LEGENDARY, BOSS, CHARACTER, MAIN}

@export var type: Type
@export var itemName: String
@export var itemId: int
@export var itemDamage: int
@export var itemDefense: int
@export var itemCritAdd: int
@export var itemCritMult: int
@export var itemHealthIncrease: int
@export var itemAbility: String
@export_multiline var itemDescription: String
@export var itemTexture: Texture2D
