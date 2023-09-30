enum ShaderUniformTypes {
	FLOAT,
	FLOAT_ARRAY,
	FLOAT_BUFFER,
	INTEGER,
	INTEGER_ARRAY,
	MATRIX,
	MATRIX_ARRAY,
	SAMPLER,
}

function Shader(_shader, _uniforms = undefined) constructor {
	if not shader_is_compiled(_shader) {
		show_error($"!!! Shader: Failed to compile '{shader_get_name(_shader)}'", true)
	}
	
	shader = _shader
	uniforms = ds_map_create()
	
	if is_array(_uniforms) {
		var i = 0
		
		repeat array_length(_uniforms) div 2 {
			var _name = _uniforms[i]
			var _type = _uniforms[-~i]
			var _uniform = -1
			
			i += 2
			
			switch _type {
				case ShaderUniformTypes.SAMPLER:
					_uniform = shader_get_sampler_index(_shader, _name)
				break
				
				default:
					_uniform = shader_get_uniform(_shader, _name)
			}
			
			if _uniform == -1 {
				continue
			}
			
			switch _type {
				case ShaderUniformTypes.FLOAT:
					_type = shader_set_uniform_f
				break
				
				case ShaderUniformTypes.FLOAT_ARRAY:
					_type = shader_set_uniform_f_array
				break
				
				case ShaderUniformTypes.FLOAT_BUFFER:
					_type = shader_set_uniform_f_buffer
				break
				
				case ShaderUniformTypes.INTEGER:
					_type = shader_set_uniform_i
				break
				
				case ShaderUniformTypes.INTEGER_ARRAY:
					_type = shader_set_uniform_i_array
				break
				
				case ShaderUniformTypes.MATRIX:
					_type = shader_set_uniform_matrix
				break
				
				case ShaderUniformTypes.MATRIX_ARRAY:
					_type = shader_set_uniform_matrix_array
				break
				
				case ShaderUniformTypes.SAMPLER:
					_type = texture_set_stage
				break
			}
			
			ds_map_add(uniforms, _name, [_type, _uniform])
		}
	}
	
	static set = function () {
		shader_set(shader)
		global.current_shader = self
	}
	
	/// @func set_uniform(name, values...)
	static set_uniform = function (_name) {
		static _args = []
		
		/*if shader_current() != shader {
			return false
		}*/
		
		var _uniform = uniforms[? _name]
		
		if _uniform != undefined {
			array_resize(_args, argument_count)
			_args[0] = _uniform[1]
			
			var i = 1
			
			repeat argument_count - 1 {
				_args[i] = argument[i]
				++i
			}
			
			script_execute_ext(_uniform[0], _args)
			
			return true
		}
		
		return false
	}
}

global.world_shader = new Shader(shWorld, [
	"u_ambient_color", ShaderUniformTypes.FLOAT,
	"u_animated", ShaderUniformTypes.FLOAT,
	"u_bone_dq", ShaderUniformTypes.FLOAT_ARRAY,
	"u_color", ShaderUniformTypes.FLOAT,
	"u_fog_distance", ShaderUniformTypes.FLOAT,
	"u_fog_color", ShaderUniformTypes.FLOAT,
	"u_light_data", ShaderUniformTypes.FLOAT_ARRAY,
	"u_material_bright", ShaderUniformTypes.FLOAT,
	"u_material_color", ShaderUniformTypes.FLOAT,
	"u_material_scroll", ShaderUniformTypes.FLOAT,
	"u_material_specular", ShaderUniformTypes.FLOAT,
	"u_material_wind", ShaderUniformTypes.FLOAT,
	"u_time", ShaderUniformTypes.FLOAT,
	"u_uvs", ShaderUniformTypes.FLOAT,
	"u_wind", ShaderUniformTypes.FLOAT,
])

global.sky_shader = new Shader(shSky, [
	"u_color", ShaderUniformTypes.FLOAT,
	"u_uvs", ShaderUniformTypes.FLOAT,
])

global.bloom_shader = new Shader(shBloom, [
	"u_resolution", ShaderUniformTypes.FLOAT,
])

global.curve_shader = new Shader(shCurve, [
	"u_curve", ShaderUniformTypes.FLOAT,
])