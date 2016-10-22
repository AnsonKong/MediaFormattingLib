package com.ansonkong.media.flv.util
{
	import com.ansonkong.media.flv.rule.SoundSampleRate;
	import com.ansonkong.media.flv.rule.SoundSampleSize;
	import com.ansonkong.media.flv.rule.SoundType;

	public class SoundFlagParser
	{
		/**传入44100、22050等*/
		public static function parseSamplingRateFlag(samplingRate:Number):uint
		{
			switch(samplingRate)
			{
				case 5512.5:
					return SoundSampleRate.RATE_5_5kHz;
				case 11025:
					return SoundSampleRate.RATE_11kHz;
				case 22050:
					return SoundSampleRate.RATE_22kHz;
				case 44100:
					return SoundSampleRate.RATE_44kHz;
			}
			return 0;
		}
		/**传入8或16*/
		public static function parseSampleSize(sampleSize:Number):uint
		{
			switch(sampleSize)
			{
				case 8:
					return SoundSampleSize.SIZE_8_BIT;
				case 16:
					return SoundSampleSize.SIZE_16_BIT;
			}
			return 0;
		}
		/**传入是否双声道*/
		public static function parseSoundType(stereo:Boolean):uint
		{
			return stereo ? SoundType.STEREO : SoundType.MONO;
		}
	}
}