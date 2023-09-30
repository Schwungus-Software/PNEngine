function net_typeof(_value) {
	switch typeof(_value) {
		case "number": return NetDataTypes.REAL
		case "string": return NetDataTypes.STRING
		case "array": return NetDataTypes.ARRAY
		case "bool": return NetDataTypes.BOOL
		case "int32": return NetDataTypes.INT32
		case "struct": return NetDataTypes.STRUCT
	}
	
	return NetDataTypes.UNDEFINED
}