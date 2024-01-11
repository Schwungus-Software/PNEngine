/// @description Load
var _type = global.flags[0].get("player_class")

if _type != undefined {
	thing_load(_type, special)
}