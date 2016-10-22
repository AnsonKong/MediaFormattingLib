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

	/**
	 * MP3转换为FLV格式播放，流式构建FLV，用于在网络上使用NetStream.appendBytes进行流式播放
	 */
	public class MP3ToFLVStreamBuilder
	{
		/**MP3的字节缓冲数据*/
		protected var _buffer:ByteArray;
		/**接收FLV字节数据的回调方法*/
		protected var _flvBytesReceiver:Function;
		/**FLV头部是否已经创建*/
		protected var _flvHeaderCreated:Boolean;
		/**MP3信息*/
		protected var _mp3Info:MP3Info;
		/**当前FLVMP3AudioTag的时间戳，毫秒*/
		protected var _currentTimestamp:uint;
		/**每帧的间隔毫秒frameLength*/
		protected var _frameLength:uint;
		/**mp3一共的字节长度*/
		protected var _mp3TotalBytesLength:uint;
		/**码率320kbps*/
		protected var _bitrate:Number;
		/**采样率44100*/
		protected var _samplingRate:Number;
		/**压缩音频采样大小总是16-bit*/
		protected var _sampleSize:Number;
		/**是否为双声道*/
		protected var _stereo:Boolean;
		/**MP3长度，秒*/
		protected var _duration:Number;
		/**临时FLVMP3AudioTag*/
		protected var _tempMP3Tag:FLVMP3AudioTag;
		
		public function clear():void
		{
			if(_buffer) _buffer.clear();
			_buffer = null;
			if(_tempMP3Tag) _tempMP3Tag.clear();
			_tempMP3Tag = null;
			_mp3Info = null;
			_flvBytesReceiver = null;
			_flvHeaderCreated = false;
			_currentTimestamp = 0;
			_frameLength = 0;
			_mp3TotalBytesLength = 0;
		}
		public function init(flvBytesReceiver:Function, mp3TotalBytesLength:uint):void
		{
			clear();
			_flvBytesReceiver = flvBytesReceiver;
			_mp3TotalBytesLength = mp3TotalBytesLength;
		}
		/**添加字节数组*/
		public function addBytes(bytes:ByteArray):void
		{
			if(!_buffer) _buffer = new ByteArray();
			/**尾部追加字节*/
			_buffer.position = _buffer.length;
			_buffer.writeBytes(bytes);
			
			var resultBytes:ByteArray;
			/**尚未创建FLV头部*/
			if(!_flvHeaderCreated)
			{
				_mp3Info = MP3Parser.parseInfo(_buffer, _mp3TotalBytesLength);
				if(_mp3Info)
				{
					_bitrate = MP3ValueParser.parseBitrate(_mp3Info.bitrate) / 1000;
					_samplingRate = MP3ValueParser.parseSamplingRate(_mp3Info.samplingRate, _mp3Info.mpegVersion);
					_sampleSize = 16;
					_stereo = MP3ValueParser.parseStereo(_mp3Info.channelMode);
					_duration = _mp3Info.duration;
					_frameLength = MP3CommonUtil.getFrameLength(_samplingRate);
					_flvHeaderCreated = true;
					
					_tempMP3Tag = new FLVMP3AudioTag();
					_tempMP3Tag.soundFormat = SoundFormat.MP3;
					_tempMP3Tag.soundRate = SoundFlagParser.parseSamplingRateFlag(_samplingRate);
					_tempMP3Tag.soundSize = SoundFlagParser.parseSampleSize(_sampleSize);
					_tempMP3Tag.soundType = SoundFlagParser.parseSoundType(_stereo);

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
						propertyData: new FLVTagScriptDataNumber(_bitrate)
					});
					//采样率44100，22050
					ecmaArray.push({
						propertyName: MetaDataProperty.AUDIO_SAMPLE_RATE, 
						propertyData: new FLVTagScriptDataNumber(_samplingRate)
					});
					//采样位数8，16
					ecmaArray.push({
						propertyName: MetaDataProperty.AUDIO_SAMPLE_SIZE, 
						propertyData: new FLVTagScriptDataNumber(_sampleSize)
					});
					//时长，秒
					ecmaArray.push({
						propertyName: MetaDataProperty.DURATION,
						propertyData: new FLVTagScriptDataNumber(_duration)
					});
					//双声道
					ecmaArray.push({
						propertyName: MetaDataProperty.STEREO, 
						propertyData: new FLVTagScriptDataBoolean(_stereo)
					});
					
					var ecma:FLVTagScriptDataECMAArray = new FLVTagScriptDataECMAArray(ecmaArray);
					scriptDataTag.addData(ecma);
					//添加scriptDataTag
					flv.addTag(scriptDataTag);
					
					resultBytes = new ByteArray();
					resultBytes.writeBytes(flv.generateFLV());
				}
			}
			//下面搜索MP3的帧
			if(_mp3Info)
			{
				var result:Object = MP3Parser.parseFrames(_buffer, _mp3Info);
				var framepositions:Array = result["framepositions"];
				var frames:Array = result["frames"];
				if(framepositions.length && frames.length)
				{
					if(!resultBytes) resultBytes = new ByteArray();
					//找到MP3帧
					for(var i:uint = 0;i < frames.length;i++)
					{
						//更新帧数据
						_tempMP3Tag.frameData = frames[i];
						//更新时间戳
						_tempMP3Tag.timestamp = _currentTimestamp;
						//写入AudioTag
						var mp3AudioTagBytes:ByteArray = _tempMP3Tag.generate();
						resultBytes.writeBytes(mp3AudioTagBytes);
						//写入PreviousTagSize
						resultBytes.writeUnsignedInt(mp3AudioTagBytes.length);
						//添加时间戳
						_currentTimestamp += _frameLength;
					}
					//裁剪buffer
					var newBuffer:ByteArray = new ByteArray();
					//从最后一个MP3帧去截取后面的字节
					_buffer.position = framepositions[framepositions.length - 1] + frames[frames.length - 1].length;
					_buffer.readBytes(newBuffer);
					_buffer.clear();
					_buffer = newBuffer;
				}
			}
			
			//如果有新的字节数组，则写入
			if(resultBytes && _flvBytesReceiver != null) _flvBytesReceiver(resultBytes);
		}
	}
}