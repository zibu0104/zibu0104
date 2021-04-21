#include "../inc_KdCommon.hlsli"
#include "inc_KdStandardShader.hlsli"

VSOutput main(
	float4 pos : POSITION,	// ���_���W
	float2 uv : TEXCOORD0,	// �e�N�X�`��UV���W
	float3 normal : NORMAL,	// �@���x�N�g��
	float4 col : COLOR,		// ���_�F
	uint4 skinIndex : SKININDEX,	// �X�L�����b�V���̃{�[���C���f�b�N�X
	float4 skinWeight : SKINWEIGHT	// �{�[���̉e���x
)
{
	// �X�L�j���O---------------->
	// �s�������
	row_major float4x4 mBones = 0; // �s���0����
	[unroll]
	for (int i = 0; i < 4; i++)
	{
		mBones += g_mBones[skinIndex[i]] * skinWeight[i];
	}
	
	// ���W�Ɩ@���ɓK�p
	pos = mul(pos, mBones);
	normal = mul(normal, (float3x3)mBones);
	
	// <----------------�X�L�j���O
	
	VSOutput Out;
	
	// �L�����N�^�[�̍��W�ϊ� : ���[�J�����W�n -> ���[���h���W�n�֕ϊ�
	Out.Pos = mul(pos, g_mWorld);
	Out.wPos = Out.Pos.xyz;
	
	// �J�����̋t�����ɕϊ� : ���[���h���W�n -> �r���[���W�n�֕ϊ�
	Out.Pos = mul(Out.Pos, g_mView);
	
	// �ˉe��Ԃɕϊ� : �r���[���W�n -> �ˉe���W�n�֕ϊ�
	Out.Pos = mul(Out.Pos, g_mProj);
	
	// UV�ƒ��_�F�͂��̂܂�
	Out.UV = uv;
	Out.Color = col;
	
	// �@��
	Out.wN = mul(normal, (float3x3) g_mWorld);
	return Out;
}