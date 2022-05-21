!!ver 100 450

!!permu FULLBRIGHT
!!permu FOG
!!permu LIGHTSTYLED

!!cvardf r_fakesoftware = 0

!!samps diffuse
!!samps colourmap=0 paletted=1
!!samps =SPECULAR specular
!!samps !VERTEXLIT lightmap
!!samps =LIGHTSTYLED lightmap1 lightmap2 lightmap3
!!samps =DELUXE deluxemap
!!samps =LIGHTSTYLED =DELUXE deluxemap1 deluxemap2 deluxemap3
!!samps =FAKESHADOWS shadowmap

#if defined(ORM) || defined(SG)
	#define PBR
#endif

#include "sys/defs.h"
#include "sys/fog.h"

#ifdef VERTEX_SHADER

	void main ()
	{
		#if defined(OFFSETMAPPING) || defined(SPECULAR) || defined(REFLECTCUBEMASK) || defined(PBR)
		vec3 eyeminusvertex = e_eyepos - v_position.xyz;
		eyevector.x = dot(eyeminusvertex, v_svector.xyz);
		eyevector.y = dot(eyeminusvertex, v_tvector.xyz);
		eyevector.z = dot(eyeminusvertex, v_normal.xyz);
		#endif
		#if defined(REFLECTCUBEMASK) || defined(BUMPMODELSPACE)
		invsurface = mat3(v_svector, v_tvector, v_normal);
		#endif
		tc = v_texcoord;
		#ifdef FLOW
		tc.s += e_time * -0.5;
		#endif
		#ifdef VERTEXLIT
		#ifdef LIGHTSTYLED
		vc = v_colour * e_lmscale[0];
		#else
		vc = v_colour * e_lmscale;
		#endif
		#else
		lm0 = v_lmcoord;
		#ifdef LIGHTSTYLED
		lm1 = v_lmcoord2;
		lm2 = v_lmcoord3;
		lm3 = v_lmcoord4;
		#endif
		#endif
		#ifdef TESS
		vertex = v_position;
		normal = v_normal;
		#endif
		#ifdef FAKESHADOWS 
		gl_Position = ftetransform();
		vtexprojcoord = (l_cubematrix*vec4(v_position.xyz, 1.0));
		#else
		gl_Position = ftetransform();
		#endif
	}
#endif
#if defined(TESS_CONTROL_SHADER)
layout(vertices = 3) out;
in vec3 vertex[];
out vec3 t_vertex[];
in vec3 normal[];
out vec3 t_normal[];
#if defined(OFFSETMAPPING) || defined(SPECULAR) || defined(REFLECTCUBEMASK) || defined(PBR)
in vec3 eyevector[];
out vec3 t_eyevector[];
#endif
#ifdef REFLECTCUBEMASK
in mat3 invsurface[];
out mat3 t_invsurface[];
#endif
in vec2 tc[];
out vec2 t_tc[];
#ifdef VERTEXLIT
in vec4 vc[];
out vec4 t_vc[];
#else
in vec2 lm0[];
out vec2 t_lm0[];
#ifdef LIGHTSTYLED
in vec2 lm1[], lm2[], lm3[];
out vec2 t_lm1[], t_lm2[], t_lm3[];
#endif
#endif
void main()
{
#define id gl_InvocationID
t_vertex[id] = vertex[id];
t_normal[id] = normal[id];
#ifdef REFLECTCUBEMASK
t_invsurface[id] = invsurface[id];
#endif
t_tc[id] = tc[id];
#ifdef VERTEXLIT
t_vc[id] = vc[id];
#else
t_lm0[id] = lm0[id];
#ifdef LIGHTSTYLED
t_lm1[id] = lm1[id];
t_lm2[id] = lm2[id];
t_lm3[id] = lm3[id];
#endif
#endif
#if defined(SPECULAR) || defined(OFFSETMAPPING) || defined(REFLECTCUBEMASK) || defined(PBR)
t_eyevector[id] = eyevector[id];
#endif
gl_TessLevelOuter[0] = float(r_tessellation_level);
gl_TessLevelOuter[1] = float(r_tessellation_level);
gl_TessLevelOuter[2] = float(r_tessellation_level);
gl_TessLevelInner[0] = float(r_tessellation_level);
}
#endif
#if defined(TESS_EVALUATION_SHADER)
layout(triangles) in;
in vec3 t_vertex[];
in vec3 t_normal[];
#if defined(OFFSETMAPPING) || defined(SPECULAR) || defined(REFLECTCUBEMASK) || defined(PBR)
in vec3 t_eyevector[];
#endif
#ifdef REFLECTCUBEMASK
in mat3 t_invsurface[];
#endif
in vec2 t_tc[];
#ifdef VERTEXLIT
in vec4 t_vc[];
#else
#ifdef LIGHTSTYLED
in vec2 t_lm0[], t_lm1[], t_lm2[], t_lm3[];
#else
in vec2 t_lm0[];
#endif
#endif
#define LERP(a) (gl_TessCoord.x*a[0] + gl_TessCoord.y*a[1] + gl_TessCoord.z*a[2])
void main()
{
#define factor 1.0
tc = LERP(t_tc);
#ifdef VERTEXLIT
vc = LERP(t_vc);
#else
lm0 = LERP(t_lm0);
#ifdef LIGHTSTYLED
lm1 = LERP(t_lm1);
lm2 = LERP(t_lm2);
lm3 = LERP(t_lm3);
#endif
#endif
vec3 w = LERP(t_vertex);
vec3 t0 = w - dot(w-t_vertex[0],t_normal[0])*t_normal[0];
vec3 t1 = w - dot(w-t_vertex[1],t_normal[1])*t_normal[1];
vec3 t2 = w - dot(w-t_vertex[2],t_normal[2])*t_normal[2];
w = w*(1.0-factor) + factor*(gl_TessCoord.x*t0+gl_TessCoord.y*t1+gl_TessCoord.z*t2);
#if defined(PCF) || defined(SPOT) || defined(CUBE)
vtexprojcoord = (l_cubematrix*vec4(w.xyz, 1.0));
#endif
#ifdef REFLECTCUBEMASK
invsurface = LERP(t_invsurface);
#endif
#if defined(SPECULAR) || defined(OFFSETMAPPING) || defined(REFLECTCUBEMASK) || defined(PBR)
eyevector = LERP(t_eyevector);
#endif
gl_Position = m_modelviewprojection * vec4(w,1.0);
}
#endif
#ifdef FRAGMENT_SHADER
#define s_colourmap s_t0
#include "sys/pbr.h"
#include "sys/pcf.h"
#ifdef OFFSETMAPPING
#include "sys/offsetmapping.h"
#endif
void main ()
{
#ifdef OFFSETMAPPING
vec2 tcoffsetmap = offsetmap(s_normalmap, tc, eyevector);
#define tc tcoffsetmap
#endif
#if r_fakesoftware == 1 && !defined(LIGHTSTYLED)
#if __VERSION__ >= 130 && !defined(VERTEXLIT)
vec2 lmsize = vec2(textureSize(s_lightmap0, 0));
#else
#define lmsize vec2(128.0,2048.0)
#endif
#define texelstolightmap (16.0)
vec2 lmcoord0 = floor(lm0 * lmsize*texelstolightmap)/(lmsize*texelstolightmap);
#define lm0 lmcoord0
#endif
vec4 col = texture2D(s_diffuse, tc);
#if defined(BUMP) && (defined(DELUXE) || defined(SPECULAR) || defined(REFLECTCUBEMASK))
vec3 norm = normalize(texture2D(s_normalmap, tc).rgb - 0.5);
#elif defined(PBR) || defined(SPECULAR) || defined(DELUXE) || defined(REFLECTCUBEMASK)
vec3 norm = vec3(0, 0, 1); //specular lighting expects this to exist.
#endif
#ifdef VERTEXLIT
#ifdef LIGHTSTYLED
vec3 lightmaps = vc.rgb;
#else
vec3 lightmaps = vc.rgb;
#endif
#define deluxe vec3(0.0,0.0,1.0)
#else
#ifdef LIGHTSTYLED
#define deluxe vec3(0.0,0.0,1.0)
vec3 lightmaps;
#ifdef DELUXE
lightmaps  = texture2D(s_lightmap0, lm0).rgb * e_lmscale[0].rgb * dot(norm, 2.0*texture2D(s_deluxemap0, lm0).rgb-0.5);
lightmaps += texture2D(s_lightmap1, lm1).rgb * e_lmscale[1].rgb * dot(norm, 2.0*texture2D(s_deluxemap1, lm1).rgb-0.5);
lightmaps += texture2D(s_lightmap2, lm2).rgb * e_lmscale[2].rgb * dot(norm, 2.0*texture2D(s_deluxemap2, lm2).rgb-0.5);
lightmaps += texture2D(s_lightmap3, lm3).rgb * e_lmscale[3].rgb * dot(norm, 2.0*texture2D(s_deluxemap3, lm3).rgb-0.5);
#else
lightmaps  = texture2D(s_lightmap0, lm0).rgb * e_lmscale[0].rgb;
lightmaps += texture2D(s_lightmap1, lm1).rgb * e_lmscale[1].rgb;
lightmaps += texture2D(s_lightmap2, lm2).rgb * e_lmscale[2].rgb;
lightmaps += texture2D(s_lightmap3, lm3).rgb * e_lmscale[3].rgb;
#endif
#else
vec3 lightmaps = (texture2D(s_lightmap, lm0) * e_lmscale).rgb;
#ifdef DELUXE
vec3 deluxe = (texture2D(s_deluxemap, lm0).rgb-0.5);
#ifdef BUMPMODELSPACE
deluxe = normalize(deluxe*invsurface);
#else
deluxe = normalize(deluxe);
lightmaps *= 2.0 / max(0.25, deluxe.z); //counter the darkening from deluxemaps
#endif
lightmaps *= dot(norm, deluxe);
#else
#define deluxe vec3(0.0,0.0,1.0)
#endif
#endif
#endif
#ifndef IOR
#define IOR 1.5 //Index Of Reflection.
#endif
#define dielectricSpecular pow(((IOR - 1.0)/(IOR + 1.0)),2.0)
#ifdef SPECULAR
vec4 specs = texture2D(s_specular, tc);//*factor_spec;
#ifdef ORM
#define occlusion specs.r
#define roughness specs.g
#define metalness specs.b
#define gloss (1.0-roughness)
#define ambientrgb (specrgb+col.rgb)
vec3 specrgb = mix(vec3(dielectricSpecular), col.rgb, metalness);
vec3 albedorgb = col.rgb * (1.0 - dielectricSpecular) * (1.0-metalness);
#elif defined(SG) //pbr-style specular+glossiness
#define roughness (1.0-specs.a)
#define gloss specs.a
#define specrgb specs.rgb
#define ambientrgb (specs.rgb+col.rgb)
#define albedorgb col.rgb
#elif defined(PBR) //PBR using legacy texturemaps
#define gloss specs.a
#define roughness (1.0-gloss)
vec3 specrgb, albedorgb;
specrgb = vec3(dielectricSpecular);
albedorgb = col.rgb;//+specs.rgb;
#define ambientrgb col.rgb
#else   //blinn-phong
#define gloss specs.a
#define specrgb specs.rgb
#endif
#else
#define roughness 0.3
#define specrgb 1.0 //vec3(dielectricSpecular)
#define albedorgb col.rgb
#endif
#ifdef PBR
col.rgb = DoPBR(norm, normalize(eyevector), deluxe, roughness, albedorgb, specrgb, vec3(0.0,1.0,1.0));//*e_light_mul + e_light_ambient*.25*ambientrgb;
#elif defined(gloss)
vec3 halfdir = normalize(normalize(eyevector) + deluxe); //this norm should be the deluxemap info instead
float spec = pow(max(dot(halfdir, norm), 0.0), FTE_SPECULAR_EXPONENT * gloss);
spec *= FTE_SPECULAR_MULTIPLIER;
col.rgb += spec * specrgb;
#endif
#ifdef REFLECTCUBEMASK
vec3 rtc = reflect(normalize(-eyevector), norm);
rtc = rtc.x*invsurface[0] + rtc.y*invsurface[1] + rtc.z*invsurface[2];
rtc = (m_model * vec4(rtc.xyz,0.0)).xyz;
col.rgb += texture2D(s_reflectmask, tc).rgb * textureCube(s_reflectcube, rtc).rgb;
#endif
#if r_fakesoftware == 1 //FIXME: with this extra flag, half the permutations are redundant.
lightmaps *= 0.5; //counter the fact that the colourmap contains overbright values and logically ranges from 0 to 2 intead of to 1.
float pal = texture2D(s_t1, tc).r; //the palette index. hopefully not interpolated.
lightmaps -= 1.0 / 128.0; //software rendering appears to round down, so make sure we favour the lower values instead of rounding to the nearest
col.r = texture2D(s_colourmap, vec2(pal, 1.0-lightmaps.r)).r; //do 3 lookups. this is to cope with lit files, would be a waste to not support those.
col.g = texture2D(s_colourmap, vec2(pal, 1.0-lightmaps.g)).g; //its not very softwarey, but re-palettizing is ugly.
col.b = texture2D(s_colourmap, vec2(pal, 1.0-lightmaps.b)).b; //without lits, it should be identical.
#else
col.rgb *= lightmaps.rgb;
#ifdef FULLBRIGHT
col.rgb += texture2D(s_fullbright, tc).rgb;
#endif
#endif
col *= e_colourident;
#ifdef FAKESHADOWS
col.rgb *= ShadowmapFilter(s_shadowmap, vtexprojcoord);
#endif
#if defined(MASK)
#if defined(MASKLT)
if (col.a < MASK)
discard;
#else
if (col.a >= MASK)
discard;
#endif
col.a = 1.0; //alpha blending AND alpha testing usually looks stupid, plus it screws up our fog.
#endif
gl_FragColor = fog4(col);
}
#endif
