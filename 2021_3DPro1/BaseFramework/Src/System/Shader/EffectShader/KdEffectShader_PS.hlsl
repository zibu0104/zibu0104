#include "../inc_KdCommon.hlsli"
#include "inc_KdEffectShader.hlsli"

// テクスチャ
Texture2D g_tex : register(t0);

// サンプラ
SamplerState g_ss : register(s0);

//================================
// エフェクト用ピクセルシェーダ
//================================
float4 main(VSOutput In) : SV_Target0
{
	float4 color = g_tex.Sample(g_ss, In.UV) * g_Material.BaseColor * In.Color;

	return color;
}
