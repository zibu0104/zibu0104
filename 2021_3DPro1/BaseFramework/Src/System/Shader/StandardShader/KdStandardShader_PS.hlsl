#include "../inc_KdCommon.hlsli"
#include "inc_KdStandardShader.hlsli"

// テクスチャ
Texture2D g_baseTex : register(t0);		// ベースカラーテクスチャ
Texture2D g_emissiveTex : register(t1);	// エミッシブテクスチャ
Texture2D g_mrTex : register(t2);		// メタリック/ラフネステクスチャ

// サンプラ
SamplerState g_ss : register(s0);

// BlinnPhong NDF
// ・lightDir    … ライトの方向
// ・vCam        … ピクセルからカメラへの方向
// ・normal      … 法線
// ・specPower   … 反射の鋭さ
float BlinnPhong(float3 lightDir, float3 vCam, float3 normal, float specPower)
{
	float3 H = normalize(-lightDir + vCam);
	// カメラの角度差(0～1)
	float NdotH = saturate(dot(normal, H));
	float spec = pow(NdotH, specPower);

	// 正規化Blinn-Phong
	return spec * ((specPower + 2) / (2 * 3.1415926535));
}

//================================
// ピクセルシェーダ
//================================
float4 main(VSOutput In) : SV_Target0
{
	// カメラへの方向
	float3 vCam = g_CamPos - In.wPos;
	float camDist = length(vCam);       // カメラ - ピクセル距離
	vCam = normalize(vCam);

	// 法線正規化
	float3 wN = normalize(In.wN);
	
	//------------------------------------------
	// 材質色
	//------------------------------------------

	float4 mr = g_mrTex.Sample(g_ss, In.UV);
	// 金属性
	float metallic = mr.b * g_Material.Metallic;
	// 粗さ
	float roughness = mr.g * g_Material.Roughness;
	
	// 材質の色
	float4 baseColor = g_baseTex.Sample(g_ss, In.UV) * g_Material.BaseColor * In.Color;

	//------------------------------------------
	//
	// ライティング
	//
	//------------------------------------------
	// 最終的な色
	float3 color = 0;

	// ライト有効時
	if(g_LightEnable)
	{
		// 材質の拡散色　非金属ほど材質の色になり、金属ほど拡散色は無くなる
		const float3 baseDiffuse = lerp(baseColor.rgb, float3(0, 0, 0), metallic);
		// 材質の反射色　非金属ほど光の色をそのまま反射し、金属ほど材質の色が乗る
		const float3 baseSpecular = lerp(0.04, baseColor.rgb, metallic);

		//------------------
		// 平行光
		//------------------

		// Diffuse(拡散光) 正規化Lambertを使用
		{
			// 光の方向と法線の方向との角度さが光の強さになる
			float lightDiffuse = dot(-g_DL_Dir, wN);
			lightDiffuse = saturate(lightDiffuse);  // マイナス値は0にする　0(暗)～1(明)になる

			// 正規化Lambert
			lightDiffuse /= 3.1415926535;

			// 光の色 * 材質の拡散色 * 透明率
			color += (g_DL_Color * lightDiffuse) * baseDiffuse * baseColor.a;
		}

		//// Specular(反射色) 正規化Blinn-Phong NDFを使用
		//{
		//	// 反射した光の強さを求める

		//	// ラフネスから、Blinn-Phong用のSpecularPowerを求める
		//	float smoothness = 1.0 - roughness;         // ラフネスを逆転させ「滑らか」さにする
		//	float specPower = pow(2, 13 * smoothness);  // 1～8192
	  
		//	// Blinn-Phong NDF
		//	float spec = BlinnPhong(g_DL_Dir, vCam, wN, specPower);
		
		//	// 光の色 * 反射光の強さ * 材質の反射色 * 正規化係数 * 透明率
		//	color += (g_DL_Color * spec) * baseSpecular * baseColor.a;
		//}

		//------------------
		// 環境光
		//------------------
		color += g_AmbientLight * baseColor.rgb * baseColor.a;

		//------------------
		// エミッシブ
		//------------------
		color += g_emissiveTex.Sample(g_ss, In.UV).rgb * g_Material.Emissive;
	}
	// ライト無効時
	else
	{
		// 材質の色をそのまま使用
		color = baseColor.rgb;
	}

	//------------------------------------------
	// 距離フォグ
	//------------------------------------------
	if (g_DistanceFogEnable && g_FogEnable)
	{
		// フォグ 1(近い)～0(遠い)
		float f = saturate(1.0 / exp(camDist * g_DistanceFogDensity));
		// 適用
		color.rgb = lerp(g_DistanceFogColor, color.rgb, f);
	}
	
	//------------------------------------------
	// 出力
	//------------------------------------------
	return float4(color, baseColor.a);
}