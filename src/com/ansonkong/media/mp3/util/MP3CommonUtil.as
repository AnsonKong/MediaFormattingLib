package com.ansonkong.media.mp3.util
{
	public class MP3CommonUtil
	{
		/**返回时长，秒*/
		public static function getDuration(totalFrameBytes:uint, bitrate:uint):Number
		{
			return totalFrameBytes / bitrate * 8;
		}
		/**返回帧长，毫秒*/
		public static function getFrameLength(samplingRate:uint):Number
		{
			return 1152 / samplingRate * 1000;
		}
		/**获取帧中采样数据长度*/
		public static function getFrameSampleDataSize(bitrate:uint, samplingRate:uint, paddingBit:uint):uint
		{
			return getFrameSize(bitrate, samplingRate, paddingBit) - 4;
		}
		/**获取帧大小*/
		public static function getFrameSize(bitrate:uint, samplingRate:uint, paddingBit:uint):uint
		{
			return (144 * bitrate) / samplingRate + paddingBit;
		}
	}
}