//--------------------------------------------------------------------------------
// GBuffer
//
// Vertex shader and pixel shader for filling the G-Buffer of a classic
// deferred renderer
//--------------------------------------------------------------------------------

cbuffer Transforms
{
	matrix WorldMatrix;
	matrix WorldViewMatrix;
	matrix WorldViewProjMatrix;
};

cbuffer LightParameters
{
	float3 LightPositionWS;
	float4 LightColor;
	float3 ViewerPositionWS;
};

struct VSInput
{
	float4 Position : POSITION;
	float2 TexCoord : TEXCOORDS0;
	float3 Normal	: NORMAL;
	float4 Tangent	: TANGENT;
};

struct VSOutput
{
	float4 PositionCS	: SV_Position;
	float2 TexCoord		: TEXCOORD;
	float3 NormalWS		: NORMALWS;
	float3 PositionWS	: POSITIONWS;
	float3 TangentWS	: TANGENTWS;
	float3 BitangentWS	: BITANGENTWS;
};

struct PSInput
{
	float4 PositionSS	: SV_Position;
	float2 TexCoord		: TEXCOORD;
	float3 NormalWS		: NORMALWS;
	float3 PositionWS	: POSITIONWS;
	float3 TangentWS	: TANGENTWS;
	float3 BitangentWS	: BITANGENTWS;
};

//-------------------------------------------------------------------------------------------------
// Textures
//-------------------------------------------------------------------------------------------------
Texture2D       DiffuseMap : register( t0 );
Texture2D		NormalMap : register( t1 );

SamplerState    AnisoSampler : register( s0 );

//-------------------------------------------------------------------------------------------------
// Basic vertex shader, no optimizations
//-------------------------------------------------------------------------------------------------
VSOutput VSMain( in VSInput input )
{
	VSOutput output;

	// Convert position and normals to world space
	output.PositionWS = mul( input.Position, WorldMatrix ).xyz;
	float3 normalWS = normalize( mul( input.Normal, (float3x3)WorldMatrix ) );
	output.NormalWS = normalWS;

	// Reconstruct the rest of the tangent frame
	float3 tangentWS = normalize( mul( input.Tangent.xyz, (float3x3)WorldMatrix ) );
	float3 bitangentWS = normalize( cross( normalWS, tangentWS ) ) * input.Tangent.w;

	output.TangentWS = tangentWS;
	output.BitangentWS = bitangentWS;

	// Calculate the clip-space position
	output.PositionCS = mul( input.Position, WorldViewProjMatrix );

	// Pass along the texture coordinate
	output.TexCoord = input.TexCoord;

	return output;
}

//--------------------------------------------------------------------------------
float4 PSMain( in PSInput input ) : SV_Target
{
	float3x3 tangentFrameWS = float3x3( normalize( input.TangentWS ),
										normalize( input.BitangentWS ),
										normalize( input.NormalWS ) );

	// Sample the tangent-space normal map and decompress
	float3 normalTS = normalize(NormalMap.Sample(AnisoSampler, input.TexCoord).rgb * 2.0f - 1.0f);

		// Convert to world space
	float3 normalWS = mul(normalTS, tangentFrameWS);
	float3 I = LightColor.rgb*500;
	float3 kd = float3(0.2, 0.8, 0.3)/3.14;
	float3 L = LightPositionWS - input.PositionWS;
	float sqr_r = dot(L, L);
	L = normalize(L);
	float3 diffuse = kd * I / sqr_r * max(dot(normalWS, L), 0);

	float3 ks = float3(0.75, 0.75, 0.75);
	float p = 150;
	float3 E = normalize(ViewerPositionWS - input.PositionWS);
	float3 H = normalize(E + L);
	float3 specular = ks * I / sqr_r * pow(max(dot(H, normalWS), 0), p);

	float3 Ia = float3(0.1, 0.1, 0.1);
	float3 ambient = Ia * kd;

	// show object space normal, becase, the object rotate
	float4 color = float4(ambient + diffuse+specular, 1.0);
	
	return( color );
}
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
// DEBUG: show object-space normal
/*
float4 PSMain( in PSInput input ) : SV_Target
{
	float3x3 tangentFrameWS = float3x3( normalize( input.TangentWS ),
										normalize( input.BitangentWS ),
										normalize( input.NormalWS ) );

	// Sample the tangent-space normal map and decompress
	float3 normalTS = normalize(NormalMap.Sample(AnisoSampler, input.TexCoord).rgb * 2.0f - 1.0f);

	// Convert to world space
	float3 normalWS = mul(normalTS, tangentFrameWS);
	float3 normalOS = mul(normalWS, transpose((float3x3)WorldMatrix));
	// show object space normal, becase, the object rotate
	float4 color = float4(normalOS*0.5 + float3(.5, .5, .5), 1.0);
	
	return( color );
}
*/
//--------------------------------------------------------------------------------