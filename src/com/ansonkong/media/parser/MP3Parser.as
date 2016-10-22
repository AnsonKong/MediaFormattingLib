package com.ansonkong.media.parser
{
	import com.ansonkong.media.mp3.info.MP3Info;
	import com.ansonkong.media.mp3.rule.Layer;
	import com.ansonkong.media.mp3.rule.MPEGVersion;
	import com.ansonkong.media.mp3.util.MP3CommonUtil;
	import com.ansonkong.media.mp3.util.MP3ValueParser;
	
	import flash.utils.ByteArray;

	public class MP3Parser
	{
		public static function parseInfo(mp3Bytes:ByteArray, fixedMP3BytesLength:uint = 0):MP3Info
		{
			var info:MP3Info;
			var oldPosition:uint = mp3Bytes.position;
			mp3Bytes.position = 0;
			var firstFramePosition:uint;
			while(mp3Bytes.bytesAvailable >= 4)
			{
				var tempFirstByte:uint = mp3Bytes.readUnsignedByte();
				var tempSecondByte:uint = mp3Bytes.readUnsignedByte();
				var tempThirdByte:uint = mp3Bytes.readUnsignedByte();
				var tempForthByte:uint = mp3Bytes.readUnsignedByte();
				//查看下一个字节的高3位是否也是111，若是，则这里是一个frame的开始
				//向右移动5位，等于111即7
				//MpegVersion为Version1
				//Layer为3
				if(tempFirstByte == 0xFF &&
					tempSecondByte >> 5 == 7 &&
					(tempSecondByte >> 3 & 3) == MPEGVersion.VERSION_1 &&
					(tempSecondByte >> 1 & 3) == Layer.LAYER_3 &&
					tempThirdByte && 
					tempForthByte)
				{
					firstFramePosition = mp3Bytes.position - 4;
					
					info = new MP3Info();
					//MpegVersion
					info.mpegVersion = tempSecondByte >> 3 & 3;
					//Layer
					info.layer = tempSecondByte >> 1 & 3;
					//ProtectionBit
					info.protectionBit = tempSecondByte & 1;
					
					//Bitrate
					info.bitrate = tempThirdByte >> 4 & 15;
					//SamplingRate
					info.samplingRate = tempThirdByte >> 2 & 3;
					//PaddingBit skip
					
					//ChannelMode
					info.channelMode = tempForthByte >> 6 & 3;
					//ModeExtension skip
					
					//Copyright
					info.copyright = tempForthByte >> 3 & 1;
					//Original Media
					info.original = tempForthByte >> 2 & 1;
					//Emphasis
					info.emphasis = tempForthByte & 3;
					break;
				}
				else
				{
					mp3Bytes.position -= 3;
				}
			}
			if(info)
			{
				//bps,如320000
				var bitrate:Number = MP3ValueParser.parseBitrate(info.bitrate);
				//是否含有ID3V1信息，占用128字节
				var hasID3V1:Boolean = parseHasID3V1(mp3Bytes);
				//所有帧所占的字节长度
				var totalFrameBytesLength:uint = (fixedMP3BytesLength || mp3Bytes.length) - firstFramePosition - (hasID3V1 ? 128 : 0);
				//时长，秒（乘以8是把bitrate转化为字节，也就是每秒读取的字节长度）
				info.duration = MP3CommonUtil.getDuration(totalFrameBytesLength, bitrate);
			}
			
			mp3Bytes.position = oldPosition;
			return info;
		}
		public static function parseHasID3V1(mp3Bytes:ByteArray):Boolean
		{
			var oldPosition:uint = mp3Bytes.position;
			
			var result:Boolean = false;
			mp3Bytes.position = mp3Bytes.length - 128;
			var charT:uint = mp3Bytes.readUnsignedByte();
			var charA:uint = mp3Bytes.readUnsignedByte();
			var charG:uint = mp3Bytes.readUnsignedByte();
			if(charT == 0x54 && charA == 0x41 && charG == 0x47) result = true;
			
			mp3Bytes.position = oldPosition;
			return result;
		}
		public static function parseFrames(mp3Bytes:ByteArray, mp3Info:MP3Info = null):Object
		{
			var oldPosition:uint = mp3Bytes.position;
			mp3Bytes.position = 0;
			//获取MP3Info
			var info:MP3Info = mp3Info || parseInfo(mp3Bytes);
			//bps,如320000
			var bitrate:Number = MP3ValueParser.parseBitrate(info.bitrate);
			//44100
			var samplingRate:Number = MP3ValueParser.parseSamplingRate(info.samplingRate, info.mpegVersion);
			
			var result:Object= {};
			//记录帧在文件中的字节位置uint
			var framepositions:Array = [];
			//帧的字节数组ByteArray
			var frames:Array = [];
			//找到第一个帧的位置
			while(mp3Bytes.bytesAvailable >= 4)
			{
				var firstBytePos:uint = mp3Bytes.position;
				var tempFirstByte:uint = mp3Bytes.readUnsignedByte();
				var tempSecondByte:uint = mp3Bytes.readUnsignedByte();
				var tempThirdByte:uint = mp3Bytes.readUnsignedByte();
				var tempFourthByte:uint = mp3Bytes.readUnsignedByte();
				var frameFound:Boolean = false;
				//向右移动5位，等于111即7
				//MpegVersion为Version1
				//Layer为3
				if(tempFirstByte == 0xFF &&
					tempSecondByte >> 5 == 7 &&
					(tempSecondByte >> 3 & 3) == MPEGVersion.VERSION_1 &&
					(tempSecondByte >> 1 & 3) == Layer.LAYER_3 &&
					tempThirdByte && 
					tempFourthByte)
				{
					var paddingBit:uint = tempThirdByte >> 1 & 1;
					var size:uint = MP3CommonUtil.getFrameSampleDataSize(bitrate, samplingRate, paddingBit);
					if(mp3Bytes.bytesAvailable >= size)
					{
						var frameByteArray:ByteArray = new ByteArray();
						frameByteArray.writeByte(tempFirstByte);
						frameByteArray.writeByte(tempSecondByte);
						frameByteArray.writeByte(tempThirdByte);
						frameByteArray.writeByte(tempFourthByte);
						//写入sample数据
						mp3Bytes.readBytes(frameByteArray, frameByteArray.length, size);
						
						framepositions.push(firstBytePos);
						frames.push(frameByteArray);	
						
						frameFound = true;
					}
				}
				if(!frameFound)
				{
					mp3Bytes.position -= 3;
				}
			}
			result["framepositions"] = framepositions;
			result["frames"] = frames;
			mp3Bytes.position = oldPosition;
			return result;
		}
	}
}