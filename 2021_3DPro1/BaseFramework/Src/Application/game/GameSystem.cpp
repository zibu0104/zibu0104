#include "GameSystem.h"

void GameSystem::Init()
{
	m_sky.Load("Data/Models/sky/sky.gltf");
}

void GameSystem::Update()
{
	OutputDebugStringA("描写関数\n");
}

void GameSystem::Draw()
{
	SHADER->m_effectShader.SetToDevice();

	SHADER->m_effectShader.DrawModel(m_sky);
}

void GameSystem::Release()
{
	OutputDebugStringA("解放関数\n");
}
