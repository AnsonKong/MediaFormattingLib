package com.ansonkong.media.flv.util
{
	import com.ansonkong.media.flv.rule.SoundBitRate;
	import com.ansonkong.media.flv.rule.SoundSampleRate;
	import com.ansonkong.media.flv.rule.SoundSampleSize;
	import com.ansonkong.media.flv.rule.SoundType;

	public class SoundDataUtil
	{
		/**采样率*/
		public static function getSampleRate(value:int):Number
		{
			switch(value)
			{
				case SoundSampleRate.RATE_5_5kHz:
					return 5512.5;
				case SoundSampleRate.RATE_11kHz:
					return 11025;
				case SoundSampleRate.RATE_22kHz:
					return 22050;
				case SoundSampleRate.RATE_44kHz:
					return 44100;
			}
			return -1;
		}
		/**采样位数*/
		public static function getSampleSize(value:int):Number
		{
			switch(value)
			{
				case SoundSampleSize.SIZE_8_BIT:
					return 8;
				case SoundSampleSize.SIZE_16_BIT:
					return 16;
			}
			return -1;
		}
		/**比特率*/
		public static function getBitRate(value:int):Number
		{
			switch(value)
			{
				case SoundBitRate.BIT_RATE_128KBPS:
					return 128;
				case SoundBitRate.BIT_RATE_192KBPS:
					return 192;
				case SoundBitRate.BIT_RATE_320KBPS:
					return 320;
			}
			return -1;
		}
		/**是否立体声*/
		public static function getStereo(value:int):Boolean
		{
			return value == SoundType.STEREO;
		}
	}
}