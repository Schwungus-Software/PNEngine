enum NetVarFlags {
	CREATE = 1 << 0,
	TICK = 1 << 1,
}

function NetVariable(_name, _flags, _read, _write) constructor {
	scope = noone
	name = _name
	hash = variable_get_hash(_name)
	value = undefined
	flags = _flags
	read = _read
	write = _write
}