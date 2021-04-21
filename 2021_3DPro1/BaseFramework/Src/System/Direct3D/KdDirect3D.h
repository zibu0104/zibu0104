﻿#pragma once

class KdTexture;
class KdShaderManager;

// サンプラステート
enum class KdSamplerFilterMode {
	Point,			// ポイントフィルタ
	Linear,			// 線形フィルタ
	Anisotropic,	// 異方性フィルタ
};

enum class KdSamplerAddressingMode {
	Wrap,			// ラップモード
	Clamp,			// クランプモード
};

// ブレンドモード用定数
enum class KdBlendMode {
	NoBlend,		// ブレンドをしない
	Alpha,			// 半透明ブレンド
	Add				// 加算ブレンド
};

//=======================================================================================
//
// Direct3Dクラス
//
//	Direct3D11に必要な変数や、よく行う操作をまとめています。
//
//
//=======================================================================================
class KdDirect3D {
public:

	//==============================================================
	//
	// 取得
	//
	//==============================================================

	// Direct3Dデバイス取得
	ID3D11Device*				WorkDev() { return m_pDevice; }

	// Direct3Dデバイスコンテキスト取得
	ID3D11DeviceContext*		WorkDevContext() { return m_pDeviceContext; }

	// SwapChain取得
	IDXGISwapChain*				WorkSwapChain() { return m_pGISwapChain; }

	// バックバッファ取得
	std::shared_ptr<KdTexture>	WorkBackBuffer() { return m_backBuffer; }

	// Zバッファ取得
	std::shared_ptr<KdTexture>	WorkZBuffer() { return m_zBuffer; }

	// ビューポート取得
	void						GetViewport(Math::Viewport& out) const;

	// 1x1 白テクスチャ取得
	const std::shared_ptr<KdTexture>	GetWhiteTex() const { return m_texWhite; }

	// 1x1 Z向き法線マップ取得
	const std::shared_ptr<KdTexture>	GetNormalTex() const { return m_texNormal; }

	//==============================================================
	//
	// 初期化・解放
	//
	//==============================================================

	// 初期化
	// ・hWnd			… ウィンドウのハンドル
	// ・w				… X解像度
	// ・h				… Y解像度
	// ・debugDevice	… デバッグモード
	// ・errMsg			… (出力)エラーメッセージが入ってくる
	bool Init(HWND hWnd, int w, int h, bool deviceDebug, std::string& errMsg);

	// 解放
	void Release();

	//==============================================================
	//
	// パイプラインステート作成関数
	//
	//==============================================================

	// 深度ステンシルステート作成
	// ・device				… D3Dデバイス
	// ・zEnable			… 深度テスト有効
	// ・zWriteEnable		… 深度書き込み有効
	ID3D11DepthStencilState* CreateDepthStencilState(bool zEnable, bool zWriteEnable) const;

	// ラスタライザーステート作成
	// ・device				… D3Dデバイス
	// ・cullMode			… カリングモード
	// ・fillMode			… 三角形の描画モード
	// ・depthClipEnable	… Zクリッピングを有効にする
	// ・scissorEnable		… 切り抜き範囲を有効にする
	ID3D11RasterizerState* CreateRasterizerState(D3D11_CULL_MODE cullMode, D3D11_FILL_MODE fillMode, bool depthClipEnable, bool scissorEnable) const;

	// サンプラーステート作成
	// ・device				… D3Dデバイス
	// ・filterType			… 0:補間なし 1:線形フィルタ 2:異方性フィルタ
	// ・maxAnisotropy		… 異方性フィルタ時の最大値　2, 4, 6, 8, 10, 12, 14, 16 のいずれか
	// ・addressingMode		… テクスチャアドレッシングモード 0:Wrap 1:Clamp
	// ・comparisonModel	… 比較モードON　シャドウマッピングなどで使用する
	ID3D11SamplerState* CreateSamplerState(KdSamplerFilterMode filterType, UINT maxAnisotropy, KdSamplerAddressingMode addressingMode, bool comparisonModel) const;

	// ブレンドステート作成
	// ・device				… D3Dデバイス
	// ・mode				… 合成モード
	ID3D11BlendState* CreateBlendState(KdBlendMode mode) const;

	//==============================================================

	// 頂点を描画する簡易的な関数
	// ・topology		… 頂点をどのような形状で描画するか　D3D_PRIMITIVE_TOPOLOGYマクロを使用
	// ・vertexCount	… 頂点数
	// ・pVertexStream	… 頂点配列の先頭アドレス
	// ・stride			… １頂点のバイトサイズ
	void DrawVertices(D3D_PRIMITIVE_TOPOLOGY topology, int vertexCount, const void* pVertexStream, UINT stride);

	//==============================================================

	// 
	~KdDirect3D() {
		Release();
	}

	std::unique_ptr<KdShaderManager>& WorkShaderManager();

private:

	ID3D11Device*				m_pDevice = nullptr;			// Direct3D11の中心になるクラス。全体の管理とバッファ、シェーダ、テクスチャなどのリソース作成などを行う。D3D9とは違って、このクラスは描画関係のメンバ関数を持たない。
	ID3D11DeviceContext*		m_pDeviceContext = nullptr;		// 描画処理を行うクラス。
																// 内部的には、レンダリングコマンドと呼ばれるバイナリデータを作成し、GPUに送る。GPUがレンダリングコマンドを解析することで実際の描画処理が行われる。
	IDXGISwapChain*				m_pGISwapChain = nullptr;		// ウインドウへの表示やダブルバッファリングなどを行うクラス。マルチサンプリング、リフレッシュレートなどの設定もできるみたい。

	std::unique_ptr<KdShaderManager>	m_shadermanager = nullptr;

	// バッファ
	std::shared_ptr<KdTexture>	m_backBuffer;					// バックバッファ
	std::shared_ptr<KdTexture>	m_zBuffer;						// Zバッファ

	// DrawVertices用 頂点バッファ
	KdBuffer					m_tempFixedVertexBuffer[10];	// 固定長 頂点バッファ
	KdBuffer					m_tempVertexBuffer;				// 可変長 頂点バッファ

	//------------------------
	// 便利テクスチャ
	//------------------------
	// 1x1 白テクスチャ
	std::shared_ptr<KdTexture>	m_texWhite;

	// デフォルト法線マップ（1x1 Z向き）
	std::shared_ptr<KdTexture>	m_texNormal;

//-------------------------------
// シングルトン
//-------------------------------
private:

	KdDirect3D() { }

public:
	static KdDirect3D &GetInstance() {
		static KdDirect3D instance;
		return instance;
	}
};

// 簡単にアクセスできるようにするためのマクロ
#define D3D KdDirect3D::GetInstance()

#define SHADER D3D.WorkShaderManager()
