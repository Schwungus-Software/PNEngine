function ModelMap() : AssetMap() constructor {
	static load = function (_name) {
		if ds_map_exists(assets, _name) {
			exit
		}
		
#region Load .bbmod File
		var _bbmod_file = mod_find_file("models/" + _name + ".bbmod")
		
		if _bbmod_file == "" {
			print($"! ModelMap.load: '{_name}' not found")
			
			exit
		}
		
		var _buffer = buffer_load(_bbmod_file)
		var _has_minor_version = false
		
		// Header
		switch buffer_read(_buffer, buffer_string) {
			case "bbmod": break
			
			case "BBMOD":
				_has_minor_version = true
			break
			
			default:
				show_error($"!!! ModelMap.load: '{_name}' does not have BBMOD header", true)
		}
		
		// Major version
		var _major_version = buffer_read(_buffer, buffer_u8)
		
		if _major_version != 3 {
			show_error($"!!! ModelMap.load: '{_name}' has invalid BBMOD major version {_major_version}, expected 3", true)
		}
		
		// Minor version
		var _minor_version = 0
		
		if _has_minor_version {
			_minor_version = buffer_read(_buffer, buffer_u8)
			
			if _minor_version < 3 or _minor_version > 21 {
				show_error($"!!! ModelMap.load: '{_name}' has invalid BBMOD minor version {_minor_version}, expected range [3, 21]", true)
			}
		}
		
		// Submodels
		var _submodel_count = buffer_read(_buffer, buffer_u32)
		var _submodels = array_create(_submodel_count)
		var i = 0
		
		repeat _submodel_count {
			var _submodel = new Submodel()
			
			with _submodel {
				// Store the material index for later use
				material_index = buffer_read(_buffer, buffer_u32)
				
				// Bounding box
				repeat 6 {
					buffer_read(_buffer, buffer_f32)
				}
				
				/* Vertex format
				   
				   PNEngine only needs the following attributes:
				   - Position
				   - Normals
				   - UVs
				   - Secondary UVs
				   - Colors
				   - Bone Indices
				   - Bone Weights
				   
				   TODO: Add support for tangents?
						 Normal maps would be nice... */
				var _position = buffer_read(_buffer, buffer_bool)
				var _normals = buffer_read(_buffer, buffer_bool)
				var _uvs = buffer_read(_buffer, buffer_bool)
				var _uvs2 = buffer_read(_buffer, buffer_bool)
				var _color = buffer_read(_buffer, buffer_bool)
				var _tangents = buffer_read(_buffer, buffer_bool)
				var _bones = buffer_read(_buffer, buffer_bool)
				var _id = buffer_read(_buffer, buffer_bool)
				
				// Primitive type
				buffer_read(_buffer, buffer_u32)
				
				vbo = vertex_create_buffer()
				vertex_begin(vbo, global.vbo_format)
				
				// Vertices
				var _vertex_count = buffer_read(_buffer, buffer_u32)
				
				repeat _vertex_count {
					// Position
					if _position {
						var _x = buffer_read(_buffer, buffer_f32)
						var _y = buffer_read(_buffer, buffer_f32)
						var _z = buffer_read(_buffer, buffer_f32)
						
						vertex_position_3d(vbo, _x, _y, _z)
					} else {
						vertex_position_3d(vbo, 0, 0, 0)
					}
					
					// Normals
					if _normals {
						var _nx = buffer_read(_buffer, buffer_f32)
						var _ny = buffer_read(_buffer, buffer_f32)
						var _nz = buffer_read(_buffer, buffer_f32)
						
						vertex_normal(vbo, _nx, _ny, _nz)
					} else {
						vertex_normal(vbo, 0, 0, 1)
					}
					
					// UVs
					if _uvs {
						var _u = buffer_read(_buffer, buffer_f32)
						var _v = buffer_read(_buffer, buffer_f32)
						
						vertex_texcoord(vbo, _u, _v)
					} else {
						vertex_texcoord(vbo, 0, 0)
					}
					
					// UVs 2
					if _uvs2 {
						var _u = buffer_read(_buffer, buffer_f32)
						var _v = buffer_read(_buffer, buffer_f32)
						
						vertex_texcoord(vbo, _u, _v)
					} else {
						vertex_texcoord(vbo, 0, 0)
					}
					
					// Color
					if _color {
						var _r = buffer_read(_buffer, buffer_u8)
						var _g = buffer_read(_buffer, buffer_u8)
						var _b = buffer_read(_buffer, buffer_u8)
						var _a = buffer_read(_buffer, buffer_u8)
						
						vertex_color(vbo, make_color_rgb(_r, _g, _b), _a * COLOR_INVERSE)
					} else {
						vertex_color(vbo, c_white, 1)
					}
					
					// Tangents
					if _tangents {
						repeat 4 {
							buffer_read(_buffer, buffer_f32)
						}
					}
					
					// Bones
					if _bones {
						var _bone1 = buffer_read(_buffer, buffer_f32)
						var _bone2 = buffer_read(_buffer, buffer_f32)
						var _bone3 = buffer_read(_buffer, buffer_f32)
						var _bone4 = buffer_read(_buffer, buffer_f32)
						var _weight1 = buffer_read(_buffer, buffer_f32)
						var _weight2 = buffer_read(_buffer, buffer_f32)
						var _weight3 = buffer_read(_buffer, buffer_f32)
						var _weight4 = buffer_read(_buffer, buffer_f32)
						
						vertex_float4(vbo, _bone1, _bone2, _bone3, _bone4)
						vertex_float4(vbo, _weight1, _weight2, _weight3, _weight4)
					} else {
						vertex_float4(vbo, 0, 0, 0, 0)
						vertex_float4(vbo, 0, 0, 0, 0)
					}
					
					// ID
					if _id {
						buffer_read(_buffer, buffer_f32)
					}
				}
				
				vertex_end(vbo)
				vertex_freeze(vbo)
			}
			
			_submodels[i++] = _submodel
		}
		
		// Nodes
		var _node_count = buffer_read(_buffer, buffer_u32)
		var _root_node = new Node().from_buffer(_buffer)
		
		// Bone offsets
		var _bone_count = buffer_read(_buffer, buffer_u32)
		var _bone_offsets = array_create(_bone_count * 8)
		
		repeat _bone_count {
			i = buffer_read(_buffer, buffer_f32) * 8
			
			repeat 8 {
				_bone_offsets[i++] = buffer_read(_buffer, buffer_f32)
			}
		}
		
		// Materials
		var _material_count = buffer_read(_buffer, buffer_u32)
		var _materials = array_create(_material_count)
		
		i = 0
		
		repeat _material_count {
			var _material_name = buffer_read(_buffer, buffer_string)
			
			_materials[i++] = global.materials.fetch(_material_name)
		}
		
		buffer_delete(_buffer)
		i = 0
		
		repeat _submodel_count {
			with _submodels[i++] {
				materials = [_materials[material_index]]
			}
		}
		
		var _model = new Model()
		
		with _model {
			name = _name
			submodels = _submodels
			submodels_amount = _submodel_count
			root_node = _root_node
			nodes_amount = _node_count
			bone_offsets = _bone_offsets
			bones_amount = _bone_count
		}
#endregion
		
#region Load JSON File
		var _json = json_load(mod_find_file("models/" + _name + ".json"))
		
		if is_struct(_json) {
#region Points
			var _points = force_type_fallback(_json[$ "points"], "struct")
			
			if _points != undefined {
				var _names = struct_get_names(_points)
				var i = 0
				
				repeat struct_names_count(_points) {
					var _point = force_type(_points[$ _names[i++]], "array")
					
					_point[3] = _model.get_node(force_type_fallback(_point[3], "string"))
				}
				
				_model.points = _points
			}
#endregion
			
#region Lightmap
			var _lightmap = force_type_fallback(_json[$ "lightmap"], "string")
			
			if _lightmap != undefined {
				global.images.load(_lightmap)
				_model.lightmap = _lightmap
			}
#endregion
		}
#endregion
		
		ds_map_add(assets, _name, _model)
		print($"ModelMap.load: Added '{_name}' ({_model})")
	}
}

global.models = new ModelMap()