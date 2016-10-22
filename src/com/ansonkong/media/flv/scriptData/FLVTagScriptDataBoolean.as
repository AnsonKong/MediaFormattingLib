package com.ansonkong.media.flv.scriptData
{
	import com.ansonkong.media.flv.rule.FLVTagScriptDataType;
	
	import flash.utils.ByteArray;

	public class FLVTagScriptDataBoolean extends FLVTagScriptData
	{
		/**true or false*/
		public function FLVTagScriptDataBoolean(data:Object)
		{
			super(data);
		}
		override public function get type():int
		{
			return FLVTagScriptDataType.BOOLEAN;
		}
		override protected function _generateMessage():ByteArray
		{
			var result:ByteArray = new ByteArray();
			//1字节记录Boolean
			result.writeByte(_data == true ? 0x01 : 0x00);
			return result;
		}
	}
}