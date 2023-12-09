/* ---------------------
   SMF DEPTH ÜBERSHADER
   Original by TheSnidr
         Forked by
   Can't Sleep & nonk123
       for PNEngine
   --------------------- */

#define MAX_BONES 64

/* ----------
   ATTRIBUTES
   ---------- */

attribute vec3 in_Position; // (x, y, z) 
attribute vec3 in_Normal; // (x, y, z)
attribute vec2 in_TextureCoord; // (u, v)
attribute vec4 in_Colour; // (r, g, b, a)
attribute vec4 in_Colour2; // (bone 1, bone 2, weight 1, weight 2)
attribute vec4 in_Colour3; // (bone 1, bone 2, weight 1, weight 2)

/* --------
   VARYINGS
   -------- */

varying vec2 v_texcoord;
varying vec4 v_color;
varying float v_light_depth;

/* --------
   UNIFORMS
   -------- */

uniform float u_time;

uniform vec4 u_wind; // strength, xyz

uniform vec2 u_material_scroll;
uniform vec3 u_material_wind; // waviness, lock bottom, speed

uniform float u_animated;
uniform vec4 u_bone_dq[2 * MAX_BONES];

//	Simplex 4D Noise 
//	by Ian McEwan, Ashima Arts
vec4 permute(vec4 x) {
	return mod(((x * 34.) + 1.) * x, 289.);
}

float permute(float x) {
	return floor(mod(((x * 34.) + 1.) * x, 289.));
}

vec4 taylor_inv_sqrt(vec4 r) {
	return 1.79284291400159 - 0.85373472095314 * r;
}

float taylor_inv_sqrt(float r) { 
	return 1.79284291400159 - 0.85373472095314 * r;
}

vec4 grad4(float j, vec4 ip) {
	const vec4 ones = vec4(1., 1., 1., -1.);
	vec4 p, s;
	
	p.xyz = floor(fract(vec3(j) * ip.xyz) * 7.) * ip.z - 1.;
	p.w = 1.5 - dot(abs(p.xyz), ones.xyz);
	s = vec4(lessThan(p, vec4(0.)));
	p.xyz = p.xyz + (s.xyz * 2. - 1.) * s.www; 
	
	return p;
}

float snoise(vec4 v) {
	const vec2 C = vec2(0.138196601125010504,  // (5 - sqrt(5))/20  G4
                        0.309016994374947451); // (sqrt(5) - 1)/4   F4
	
	// First corner
	vec4 i  = floor(v + dot(v, C.yyyy));
	vec4 x0 = v - i + dot(i, C.xxxx);
	
	// Other corners
	// Rank sorting originally contributed by Bill Licea-Kane, AMD (formerly ATI)
	vec4 i0;
	vec3 is_x = step(x0.yzw, x0.xxx);
	vec3 is_yz = step(x0.zww, x0.yyz);
	
	//i0.x = dot(is_x, vec3(1.));
	i0.x = is_x.x + is_x.y + is_x.z;
	i0.yzw = 1. - is_x;
	//i0.y += dot(is_yz.xy, vec2(1.));
	i0.y += is_yz.x + is_yz.y;
	i0.zw += 1. - is_yz.xy;
	i0.z += is_yz.z;
	i0.w += 1. - is_yz.z;
	
	// i0 now contains the unique values 0,1,2,3 in each channel
	vec4 i3 = clamp(i0, 0., 1.);
	vec4 i2 = clamp(i0 - 1., 0., 1.);
	vec4 i1 = clamp(i0 - 2., 0., 1.);
	
	//x0 = x0 - 0.0 + 0.0 * C 
	
	vec4 x1 = x0 - i1 + 1. * C.xxxx;
	vec4 x2 = x0 - i2 + 2. * C.xxxx;
	vec4 x3 = x0 - i3 + 3. * C.xxxx;
	vec4 x4 = x0 - 1. + 4. * C.xxxx;
	
	// Permutations
	i = mod(i, 289.);
	
	float j0 = permute(permute(permute(permute(i.w) + i.z) + i.y) + i.x);
	vec4 j1 = permute(permute(permute(permute(
              i.w + vec4(i1.w, i2.w, i3.w, 1.))
            + i.z + vec4(i1.z, i2.z, i3.z, 1.))
            + i.y + vec4(i1.y, i2.y, i3.y, 1.))
            + i.x + vec4(i1.x, i2.x, i3.x, 1.));
	
	// Gradients
	// ( 7*7*6 points uniformly over a cube, mapped onto a 4-octahedron.)
	// 7*7*6 = 294, which is close to the ring size 17*17 = 289.
	vec4 ip = vec4(1. / 294., 1. / 49., 1. / 7., 0.) ;
	vec4 p0 = grad4(j0, ip);
	vec4 p1 = grad4(j1.x, ip);
	vec4 p2 = grad4(j1.y, ip);
	vec4 p3 = grad4(j1.z, ip);
	vec4 p4 = grad4(j1.w, ip);
	
	// Normalise gradients
	vec4 norm = taylor_inv_sqrt(vec4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
	
	p0 *= norm.x;
	p1 *= norm.y;
	p2 *= norm.z;
	p3 *= norm.w;
	p4 *= taylor_inv_sqrt(dot(p4,p4));
	
	// Mix contributions from the five corners
	vec3 m0 = max(0.6 - vec3(dot(x0, x0), dot(x1, x1), dot(x2, x2)), 0.);
	vec2 m1 = max(0.6 - vec2(dot(x3, x3), dot(x4, x4)), 0.);
	
	m0 = m0 * m0;
	m1 = m1 * m1;
	
	return 49. * (dot(m0 * m0, vec3(dot(p0, x0), dot(p1, x1), dot(p2, x2)))
               + dot(m1 * m1, vec2(dot(p3, x3), dot(p4, x4))));
}

void main() {
	// Get bone indices and weights
	int bone = int(in_Colour2.r * 510.);
	int bone2 = int(in_Colour2.g * 510.);
	int bone3 = int(in_Colour2.b * 510.);
	int bone4 = int(in_Colour2.a * 510.);
	
	vec4 r0 = u_bone_dq[bone];
	vec4 d0 = u_bone_dq[bone + 1];
	vec4 r1 = u_bone_dq[bone2];
	vec4 d1 = u_bone_dq[bone2 + 1];
	vec4 r2 = u_bone_dq[bone3];
	vec4 d2 = u_bone_dq[bone3 + 1];
	vec4 r3 = u_bone_dq[bone4];
	vec4 d3 = u_bone_dq[bone4 + 1];
	float w0 = in_Colour3.r;
	float w1 = in_Colour3.g * sign(dot(r0, r1));
	float w2 = in_Colour3.b * sign(dot(r0, r2));
	float w3 = in_Colour3.a * sign(dot(r0, r3));
	
	// Blend bones
	vec4 blend_real = mix(vec4(0., 0., 0., 1.), r0 * w0 + r1 * w1 + r2 * w2 + r3 * w3, u_animated);
	vec4 blend_dual = mix(vec4(0.), d0 * w0 + d1 * w1 + d2 * w2 + d3 * w3, u_animated);
	
	// Normalize resulting dual quaternion
	float blend_normal_real = 1. / length(blend_real);
	
	blend_real *= blend_normal_real;
	blend_dual = (blend_dual - blend_real * dot(blend_real, blend_dual)) * blend_normal_real;
	
	// Vertex & normal transformation, rotation & translation
	vec3 animation = 2. * cross(blend_real.xyz, cross(blend_real.xyz, in_Position) + blend_real.w * in_Position) + 2. * (blend_real.w * blend_dual.xyz - blend_dual.w * blend_real.xyz + cross(blend_real.xyz, blend_dual.xyz));
	mat4 world_matrix = gm_Matrices[MATRIX_WORLD];
	mat4 view_matrix = gm_Matrices[MATRIX_VIEW];
	vec4 object_space_position_vec4 = world_matrix * vec4(in_Position + animation, 1.);
	
	// Wind effect: Move vertices around using 4D simplex noise
	if (u_material_wind.x > 0.) {
		float wind_time = u_time * u_material_wind.z;
		float wind_strength = u_wind.x;
		float wind_weight = (1. - (u_material_wind.y * clamp(in_TextureCoord.y, 0., 1.))) * wind_strength * u_material_wind.x;
		float vx = in_Position.x;
		float vy = in_Position.y;
		float vz = in_Position.z;
	
		object_space_position_vec4.x += u_wind.y * snoise(vec4(vx, -vy, -vz, wind_time)) * wind_weight;
		object_space_position_vec4.y += u_wind.z * snoise(vec4(-vx, vy, -vz, wind_time)) * wind_weight;
		object_space_position_vec4.z += u_wind.w * snoise(vec4(-vx, -vy, vz, wind_time)) * wind_weight;
	}
	
	gl_Position = gm_Matrices[MATRIX_PROJECTION] * view_matrix * object_space_position_vec4;
	v_texcoord = in_TextureCoord + (u_time * u_material_scroll);
	v_color = in_Colour;
	v_light_depth = gl_Position.z / gl_Position.w;
}