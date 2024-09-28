global.shaders = ds_list_create()
global.uniforms_amount = 0

global.world_shader = new Shader(shWorld)
global.world_pixel_shader = new Shader(shWorldPixel)
global.sky_shader = new Shader(shSky)
global.bloom_pass_shader = new Shader(shBloomPass)
global.bloom_up_shader = new Shader(shBloomUp)
global.bloom_down_shader = new Shader(shBloomDown)
global.curve_shader = new Shader(shCurve)
global.depth_shader = new Shader(shDepth)
global.dither_shader = new Shader(shDither)
global.bleed_shader = new Shader(shBleed)

global.u_ambient_color = new Uniform("u_ambient_color", UniformTypes.FLOAT)
global.u_animated = new Uniform("u_animated", UniformTypes.INTEGER)
global.u_bone_dq = new Uniform("u_bone_dq", UniformTypes.FLOAT_ARRAY)
global.u_color = new Uniform("u_color", UniformTypes.FLOAT)
global.u_stencil = new Uniform("u_stencil", UniformTypes.FLOAT)
global.u_fog_distance = new Uniform("u_fog_distance", UniformTypes.FLOAT)
global.u_fog_color = new Uniform("u_fog_color", UniformTypes.FLOAT)
global.u_light_data = new Uniform("u_light_data", UniformTypes.FLOAT_ARRAY)
global.u_material_alpha_test = new Uniform("u_material_alpha_test", UniformTypes.FLOAT)
global.u_material_bright = new Uniform("u_material_bright", UniformTypes.FLOAT)
global.u_material_color = new Uniform("u_material_color", UniformTypes.FLOAT)
global.u_material_scroll = new Uniform("u_material_scroll", UniformTypes.FLOAT)
global.u_material_specular = new Uniform("u_material_specular", UniformTypes.FLOAT)
global.u_material_rimlight = new Uniform("u_material_rimlight", UniformTypes.FLOAT)
global.u_material_wind = new Uniform("u_material_wind", UniformTypes.FLOAT)
global.u_time = new Uniform("u_time", UniformTypes.FLOAT)
global.u_uvs = new Uniform("u_uvs", UniformTypes.FLOAT)
global.u_texture_size = new Uniform("u_texture_size", UniformTypes.FLOAT)
global.u_max_lod = new Uniform("u_max_lod", UniformTypes.FLOAT)
global.u_mipmaps = new Uniform("u_mipmaps", UniformTypes.FLOAT_ARRAY)
global.u_mipmap_filter = new Uniform("u_mipmap_filter", UniformTypes.INTEGER)
global.u_wind = new Uniform("u_wind", UniformTypes.FLOAT)
global.u_threshold = new Uniform("u_threshold", UniformTypes.FLOAT)
global.u_intensity = new Uniform("u_intensity", UniformTypes.FLOAT)
global.u_texel = new Uniform("u_texel", UniformTypes.FLOAT)
global.u_curve = new Uniform("u_curve", UniformTypes.FLOAT)
global.u_material_can_blend = new Uniform("u_material_can_blend", UniformTypes.INTEGER)
global.u_material_blend = new Uniform("u_material_blend", UniformTypes.TEXTURE)
global.u_material_blend_uvs = new Uniform("u_material_blend_uvs", UniformTypes.FLOAT)
global.u_light_texture = new Uniform("u_light_texture", UniformTypes.TEXTURE)
global.u_light_uvs = new Uniform("u_light_uvs", UniformTypes.FLOAT)
global.u_light_repeat = new Uniform("u_light_repeat", UniformTypes.FLOAT)
global.u_dark_color = new Uniform("u_dark_color", UniformTypes.FLOAT)
global.u_bleed = new Uniform("u_bleed", UniformTypes.FLOAT)
global.u_lightmap_enable_vertex = new Uniform("u_lightmap_enable_vertex", UniformTypes.INTEGER)
global.u_lightmap_enable_pixel = new Uniform("u_lightmap_enable_pixel", UniformTypes.INTEGER)
global.u_lightmap = new Uniform("u_lightmap", UniformTypes.TEXTURE)
global.u_lightmap_uvs = new Uniform("u_lightmap_uvs", UniformTypes.FLOAT)