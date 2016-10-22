package com.ansonkong.media.flv.tag
{
	import com.ansonkong.media.flv.rule.FLVTagType;
	
	import flash.utils.ByteArray;

	public class FLVAudioTag extends FLVTag
	{
		protected var _soundFormat:uint;
		protected var _soundRate:uint;
		protected var _soundSize:uint;
		protected var _soundType:uint;
		override public function clear():void
		{
			_soundFormat = 0;
			_soundRate = 0;
			_soundSize = 0;
			_soundType = 0;
			super.clear();
		}
		override protected function get tagType():uint
		{
			return FLVTagType.AUDIO;
		}
		
		public function set soundFormat(value:uint):void
		{
			_soundFormat = value;
		}
		
		public function set soundRate(value:uint):void
		{
			_soundRate = value;
		}
		
		public function set soundSize(value:uint):void
		{
			_soundSize = value;
		}
		
		public function set soundType(value:uint):void
		{
			_soundType = value;
		}
		
		override protected function get message():ByteArray
		{
			var result:ByteArray = new ByteArray();
			var firstByte:uint;
			//SoundFormat UB[4]   2 = MP3  0010
			var tempSoundFormat:uint = _soundFormat << 4;
			firstByte |= tempSoundFormat;
			//SoundRate UB[2]   3 = 44kHz 11
			var tempSoundRate:uint = _soundRate << 2;
			firstByte |= tempSoundRate;
			//SoundSize UB[1]   0 = 8-bit 1 = 16-bit
			var tempSoundSize:uint = _soundSize << 1;
			firstByte |= tempSoundSize;
			//SoundType UB[1]   0 = Mono 1 = Stereo
			var tempSoundType:uint = _soundType;
			firstByte |= tempSoundType;
			
			result.writeByte(firstByte);
			var audioBytes:ByteArray = getVariousAudioData();
			//写入audio数据
			result.writeBytes(audioBytes);
			
			result.position = 0;
			return result;
		}
		/**根据不同类型，自行生成tag，to override*/
		protected function getVariousAudioData():ByteArray
		{
			return null;
		}
	}
}