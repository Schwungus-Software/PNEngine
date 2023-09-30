// Bloom fragment shader

varying vec2 v_texcoord;

uniform vec2 u_resolution;

void main() {
	vec4 sum = vec4(0.);
	float u = v_texcoord.x;
	float v = v_texcoord.y;
	float tu = (1. / u_resolution.x) * 4.;
	float tv = (1. / u_resolution.y) * 4.;
	
	// take nine samples, with the distance tu between them
	sum += texture2D(gm_BaseTexture, vec2(u - 4. * tu, v)) * 0.05;
	sum += texture2D(gm_BaseTexture, vec2(u - 3. * tu, v)) * 0.09;
	sum += texture2D(gm_BaseTexture, vec2(u - 2. * tu, v)) * 0.12;
	sum += texture2D(gm_BaseTexture, vec2(u - tu, v)) * 0.15;
	sum += texture2D(gm_BaseTexture, vec2(u, v)) * 0.16;
	sum += texture2D(gm_BaseTexture, vec2(u + tu, v)) * 0.15;
	sum += texture2D(gm_BaseTexture, vec2(u + 2. * tu, v)) * 0.12;
	sum += texture2D(gm_BaseTexture, vec2(u + 3. * tu, v)) * 0.09;
	sum += texture2D(gm_BaseTexture, vec2(u + 4. * tu, v)) * 0.05;
	
	// take nine samples, with the distance tv between them
	sum += texture2D(gm_BaseTexture, vec2(u, v - 4. * tv)) * 0.05;
	sum += texture2D(gm_BaseTexture, vec2(u, v - 3. * tv)) * 0.09;
	sum += texture2D(gm_BaseTexture, vec2(u, v - 2. * tv)) * 0.12;
	sum += texture2D(gm_BaseTexture, vec2(u, v - tv)) * 0.15;
	sum += texture2D(gm_BaseTexture, vec2(u, v)) * 0.16;
	sum += texture2D(gm_BaseTexture, vec2(u, v + tv)) * 0.15;
	sum += texture2D(gm_BaseTexture, vec2(u, v + 2. * tv)) * 0.12;
	sum += texture2D(gm_BaseTexture, vec2(u, v + 3. * tv)) * 0.09;
	sum += texture2D(gm_BaseTexture, vec2(u, v + 4. * tv)) * 0.05;
	
	gl_FragColor = sum;
}