package com.ansonkong.media.flv.tag
{
	import flash.utils.ByteArray;

	public class FLVMP3AudioTag extends FLVAudioTag
	{
		protected var _frameData:ByteArray;
		override public function clear():void
		{
			if(_frameData) _frameData.clear();
			_frameData = null;
			super.clear();
		}
		public function set frameData(value:ByteArray):void
		{
			_frameData = value;
		}
		override protected function getVariousAudioData():ByteArray
		{
			return _frameData;
		}
	}
}