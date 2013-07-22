/** 
 * @file diffuseIndexedF.glsl
 *
 * $LicenseInfo:firstyear=2007&license=viewerlgpl$
 * Second Life Viewer Source Code
 * Copyright (C) 2007, Linden Research, Inc.
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation;
 * version 2.1 of the License only.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 * 
 * Linden Research, Inc., 945 Battery Street, San Francisco, CA  94111  USA
 * $/LicenseInfo$
 */

#ifdef DEFINE_GL_FRAGCOLOR
out vec4 frag_data[3];
#else
#define frag_data gl_FragData
#endif

VARYING vec3 vary_normal;
VARYING vec4 vertex_color;
VARYING vec2 vary_texcoord0;

vec2 encode_normal(vec3 n)
{
	float f = sqrt(8 * n.z + 8);
	return n.xy / f + 0.5;
}

vec3 srgb_to_linear(vec3 cs)
{
	
/*        {  cs / 12.92,                 cs <= 0.04045
    cl = {
        {  ((cs + 0.055)/1.055)^2.4,   cs >  0.04045*/

	return pow((cs+vec3(0.055))/vec3(1.055), vec3(2.4));
}

vec3 linear_to_srgb(vec3 cl)
{
	    /*{  0.0,                          0         <= cl
            {  12.92 * c,                    0         <  cl < 0.0031308
    cs = {  1.055 * cl^0.41666 - 0.055,   0.0031308 <= cl < 1
            {  1.0,                                       cl >= 1*/

	return 1.055 * pow(cl, vec3(0.41666)) - 0.055;
}

void main() 
{
	vec3 col = vertex_color.rgb * srgb_to_linear(diffuseLookup(vary_texcoord0.xy).rgb);
	
	vec3 spec;
	spec.rgb = vec3(vertex_color.a);

	frag_data[0] = vec4(linear_to_srgb(col), 0.0);
	frag_data[1] = vec4(spec, vertex_color.a); // spec
	vec3 nvn = normalize(vary_normal);
	frag_data[2] = vec4(encode_normal(nvn.xyz), vertex_color.a, 0.0);
}
