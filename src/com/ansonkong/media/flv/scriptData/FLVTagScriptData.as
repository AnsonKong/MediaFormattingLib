package com.ansonkong.media.flv.scriptData
{
	import flash.utils.ByteArray;

	public class FLVTagScriptData
	{
		protected var _data:Object;
		public function FLVTagScriptData(data:Object)
		{
			_data = data;
		}
		public function get type():int
		{
			//override
			return -1;
		}
		protected function _generateMessage():ByteArray
		{
			//override
			return null;
		}
		final public function generate():ByteArray
		{
			//写入类型
			var result:ByteArray = new ByteArray();
			result.writeByte(type);
			var message:ByteArray = _generateMessage();
			result.writeBytes(message);
			result.position = 0;
			return result;
		}
	}
}