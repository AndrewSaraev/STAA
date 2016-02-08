Shader "Hidden/STAA"
{
	Properties
	{
		_MainTex("", any) = "" {}
		_Tex0("", 2D) = "" {}
		_Tex1("", 2D) = "" {}
		_Tex2("", 2D) = "" {}
		_Tex3("", 2D) = "" {}
		_Tex4("", 2D) = "" {}
		_Tex5("", 2D) = "" {}
		_Tex6("", 2D) = "" {}
		_Tex7("", 2D) = "" {}
		_Jitter("", Vector) = (1,1,1,1)
	}

	SubShader
	{
		Pass // 0 - Compare
		{
			ZTest Always Cull Off ZWrite Off Fog { Mode Off }
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _Tex0;

			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 texcoord : TEXCOORD0;
			};

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord = float3(v.texcoord.x, v.texcoord.y, v.texcoord.y);
				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
				{
					o.texcoord.z = 1 - o.texcoord.z;
				}
				#endif				
				return o;
			}

			half4 frag(v2f i) : SV_Target0
			{
				half4 color = tex2D(_MainTex, i.texcoord.xy);
				half3 previous = tex2D(_Tex0, i.texcoord.xz);
				half3 comparison = abs(color.rgb - previous.rgb);
				color.a = max(comparison.r, max(comparison.g, comparison.b));
				return color;
			}
			ENDCG
		}

		Pass // 1 - Quincunx
		{
			ZTest Always Cull Off ZWrite Off Fog{ Mode Off }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _Tex0;
			sampler2D _Tex1;
			float4 _Jitter;

			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 texcoord : TEXCOORD0;
			};

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord = float3(v.texcoord.x, v.texcoord.y, v.texcoord.y);
				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
				{
					o.texcoord.z = 1 - o.texcoord.z;
				}
				#endif				
				return o;
			}

			half4 frag(v2f i) : SV_Target0
			{
				half4 color = tex2D(_MainTex, i.texcoord.xy + _Jitter.xy);
				half4 blend = tex2D(_Tex0, i.texcoord.xz);
				blend += tex2D(_Tex1, i.texcoord.xz - abs(_MainTex_TexelSize.xy) * 0.5);
				blend.rgb *= 0.5;
				blend.a *= _Jitter.z;

				half3 delta = color.rgb - blend.rgb;
				color.rgb = blend.rgb + min(abs(delta), blend.a) * sign(delta);
				return color;
			}
			ENDCG
		}

		Pass // 2 - x4
		{
			ZTest Always Cull Off ZWrite Off Fog { Mode Off }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _Tex0;
			sampler2D _Tex1;
			sampler2D _Tex2;
			sampler2D _Tex3;
			float4 _Jitter;

			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 texcoord : TEXCOORD0;
			};

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord = float3(v.texcoord.x, v.texcoord.y, v.texcoord.y);
				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
				{
					o.texcoord.z = 1 - o.texcoord.z;
				}
				#endif				
				return o;
			}

			half4 frag(v2f i) : SV_Target0
			{
				half4 color = tex2D(_MainTex, i.texcoord.xy + _Jitter.xy);
				half4 blend = tex2D(_Tex0, i.texcoord.xz);
				blend += tex2D(_Tex1, i.texcoord.xz);
				blend += tex2D(_Tex2, i.texcoord.xz);
				blend += tex2D(_Tex3, i.texcoord.xz);
				blend.rgb *= 0.25;
				blend.a *= _Jitter.z;

				half3 delta = color.rgb - blend.rgb;
				color.rgb = blend.rgb + min(abs(delta), blend.a) * sign(delta);
				return color;
			}
			ENDCG
		}

		Pass // 3 - x8
		{
			ZTest Always Cull Off ZWrite Off Fog{ Mode Off }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _Tex0;
			sampler2D _Tex1;
			sampler2D _Tex2;
			sampler2D _Tex3;
			sampler2D _Tex4;
			sampler2D _Tex5;
			sampler2D _Tex6;
			sampler2D _Tex7;
			float4 _Jitter;

			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 texcoord : TEXCOORD0;
			};

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord = float3(v.texcoord.x, v.texcoord.y, v.texcoord.y);
				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
				{
					o.texcoord.z = 1 - o.texcoord.z;
				}
				#endif				
				return o;
			}

			half4 frag(v2f i) : SV_Target0
			{
				half4 color = tex2D(_MainTex, i.texcoord.xy + _Jitter.xy);
				half4 blend = tex2D(_Tex0, i.texcoord.xz);
				blend += tex2D(_Tex1, i.texcoord.xz);
				blend += tex2D(_Tex2, i.texcoord.xz);
				blend += tex2D(_Tex3, i.texcoord.xz);
				blend += tex2D(_Tex4, i.texcoord.xz);
				blend += tex2D(_Tex5, i.texcoord.xz);
				blend += tex2D(_Tex6, i.texcoord.xz);
				blend += tex2D(_Tex7, i.texcoord.xz);
				blend.rgb *= 0.125;
				blend.a *= _Jitter.z;

				half3 delta = color.rgb - blend.rgb;
				color.rgb = blend.rgb + min(abs(delta), blend.a) * sign(delta);
				return color;
			}
			ENDCG
		}
	}

	Fallback Off
}