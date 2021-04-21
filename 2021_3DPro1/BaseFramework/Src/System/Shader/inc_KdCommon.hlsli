//=====================================================
//
// �S�V�F�[�_����
//
//=====================================================

//------------------------------
// �萔�o�b�t�@(�J����)
//------------------------------
cbuffer cbCamera : register(b7)
{
	// �J�������
	row_major float4x4  g_mView;	// �r���[�ϊ��s��
	row_major float4x4  g_mProj;	// �ˉe�ϊ��s��
	float3              g_CamPos;	// �J�������W

	// �t�H�O
	int     g_DistanceFogEnable;	// �t�H�O�L��/�����t���O
	float3  g_DistanceFogColor;		// �t�H�O�F
	float   g_DistanceFogDensity;	// �t�H�O������
};

//------------------------------
// �萔�o�b�t�@(���C�g)
//------------------------------
cbuffer cbLight : register(b8)
{
	// ����
	float3  g_AmbientLight;

	// ���s��
	float3  g_DL_Dir;    // ���̕���
	float3  g_DL_Color;  // ���̐F
	row_major float4x4  g_DL_mLightVP;  // ���s���̃r���[�s�� x �ˉe�s��
};