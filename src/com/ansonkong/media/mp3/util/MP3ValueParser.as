package com.ansonkong.media.mp3.util
{
	import com.ansonkong.media.mp3.rule.Bitrate;
	import com.ansonkong.media.mp3.rule.ChannelMode;
	import com.ansonkong.media.mp3.rule.MPEGVersion;
	import com.ansonkong.media.mp3.rule.SamplingRate;

	public class MP3ValueParser
	{
		/**返回bps*/
		public static function parseBitrate(bitrate:uint):Number
		{
			switch(bitrate)
			{
				case Bitrate.BITRATE_128:
					return 128000;
				case Bitrate.BITRATE_192:
					return 192000;
				case Bitrate.BITRATE_320:
					return 320000;
			}
			return NaN;
		}
		
		public static function parseSamplingRate(samplingRate:uint, mpegVersion:uint):Number
		{
			switch(samplingRate)
			{
				case SamplingRate.VALUE_0:
					switch(mpegVersion)
					{
						case MPEGVersion.VERSION_1:
							return 44100;
						case MPEGVersion.VERSION_2:
							return 48000;
						case MPEGVersion.VERSION_2_5:
							return 32000;
					}
					break;
				case SamplingRate.VALUE_1:
					switch(mpegVersion)
					{
						case MPEGVersion.VERSION_1:
							return 22050;
						case MPEGVersion.VERSION_2:
							return 24000;
						case MPEGVersion.VERSION_2_5:
							return 16000;
					}
					break;
				case SamplingRate.VALUE_2:
					switch(mpegVersion)
					{
						case MPEGVersion.VERSION_1:
							return 11025;
						case MPEGVersion.VERSION_2:
							return 12000;
						case MPEGVersion.VERSION_2_5:
							return 8000;
					}
					break;
			}
			return NaN;
		}
		
		public static function parseStereo(channelMode:uint):Boolean
		{
			switch(channelMode)
			{
				case ChannelMode.STEREO:
				case ChannelMode.JOINT_STEREO:
					return true;
			}
			return false;
		}
	}
}