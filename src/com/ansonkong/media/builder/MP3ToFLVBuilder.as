package com.ansonkong.media.builder
{
	import com.ansonkong.media.flv.rule.MetaDataProperty;
	import com.ansonkong.media.flv.rule.SoundFormat;
	import com.ansonkong.media.flv.scriptData.FLVTagScriptDataBoolean;
	import com.ansonkong.media.flv.scriptData.FLVTagScriptDataECMAArray;
	import com.ansonkong.media.flv.scriptData.FLVTagScriptDataNumber;
	import com.ansonkong.media.flv.scriptData.FLVTagScriptDataString;
	import com.ansonkong.media.flv.tag.FLVMP3AudioTag;
	import com.ansonkong.media.flv.tag.FLVScriptDataTag;
	import com.ansonkong.media.flv.util.SoundFlagParser;
	import com.ansonkong.media.mp3.info.MP3Info;
	import com.ansonkong.media.mp3.util.MP3CommonUtil;
	import com.ansonkong.media.mp3.util.MP3ValueParser;
	import com.ansonkong.media.parser.MP3Parser;
	
	import flash.utils.ByteArray;

	public class MP3ToFLVBuilder
	{
		/**
		 * mp3Bytes: mp3字节数组
		 * soundDataRate: 比特率 SoundBitRate中的值
		 * soundSampleRate: 采样率 SoundSampleRate中的值
		 * soundSampleSize: 采样位数 SoundSampleSize中的值
		 * duration: 时长，秒
		 * stereo: 立体声 SoundType中的值
		 * 
		 * 返回flv字节数组
		 */
		public static function build(mp3Bytes:ByteArray):ByteArray
		{
			var mp3Info:MP3Info = MP3Parser.parseInfo(mp3Bytes);
			//320kbps
			var bitrate:Number = MP3ValueParser.parseBitrate(mp3Info.bitrate) / 1000;
			//44100
			var samplingRate:Number = MP3ValueParser.parseSamplingRate(mp3Info.samplingRate, mp3Info.mpegVersion);
			//压缩音频采样大小总是16-bit
			var sampleSize:Number = 16;
			//是否为双声道
			var stereo:Boolean = MP3ValueParser.parseStereo(mp3Info.channelMode);
			//秒
			var duration:Number = mp3Info.duration;
			
			
			var flv:FLVBuilder = new FLVBuilder();
			//创建FLV头部
			flv.buildFLVHeader(true, false);
			//创建metaData的SCRIPTDATA TAG
			var scriptDataTag:FLVScriptDataTag = new FLVScriptDataTag();
			var metaData:FLVTagScriptDataString = new FLVTagScriptDataString("onMetaData");
			scriptDataTag.addData(metaData);
			
			var ecmaArray:Array = [];
			//编解码器
			ecmaArray.push({propertyName: MetaDataProperty.AUDIO_CODEC_ID, propertyData: new FLVTagScriptDataNumber(SoundFormat.MP3)});
			//比特率kbps(bit per second)
			ecmaArray.push({
				propertyName: MetaDataProperty.AUDIO_DATA_RATE, 
				propertyData: new FLVTagScriptDataNumber(bitrate)
			});
			//采样率44100，22050
			ecmaArray.push({
				propertyName: MetaDataProperty.AUDIO_SAMPLE_RATE, 
				propertyData: new FLVTagScriptDataNumber(samplingRate)
			});
			//采样位数8，16
			ecmaArray.push({
				propertyName: MetaDataProperty.AUDIO_SAMPLE_SIZE, 
				propertyData: new FLVTagScriptDataNumber(sampleSize)
			});
			//时长，秒
			ecmaArray.push({
				propertyName: MetaDataProperty.DURATION,
				propertyData: new FLVTagScriptDataNumber(duration)
			});
			//双声道
			ecmaArray.push({
				propertyName: MetaDataProperty.STEREO, 
				propertyData: new FLVTagScriptDataBoolean(stereo)
			});
			
			var ecma:FLVTagScriptDataECMAArray = new FLVTagScriptDataECMAArray(ecmaArray);
			scriptDataTag.addData(ecma);
			//添加scriptDataTag
			flv.addTag(scriptDataTag);
			
			//下面添加MP3的Tag
			var result:Object = MP3Parser.parseFrames(mp3Bytes);
			var mp3FrameDatas:Array = result["frames"];
			var currentTimestamp:uint = 0;
			//毫秒frameLength
			var frameLength:uint = MP3CommonUtil.getFrameLength(samplingRate);
			for each(var mp3FrameData:ByteArray in mp3FrameDatas)
			{
				var mp3AudioTag:FLVMP3AudioTag = new FLVMP3AudioTag();
				mp3AudioTag.soundFormat = SoundFormat.MP3;
				mp3AudioTag.soundRate = SoundFlagParser.parseSamplingRateFlag(samplingRate);
				mp3AudioTag.soundSize = SoundFlagParser.parseSampleSize(sampleSize);
				mp3AudioTag.soundType = SoundFlagParser.parseSoundType(stereo);
				mp3AudioTag.frameData = mp3FrameData;
				mp3AudioTag.timestamp = currentTimestamp;
				
				flv.addTag(mp3AudioTag);
				currentTimestamp += frameLength;
			}
			
			return flv.generateFLV();
		}
	}
}