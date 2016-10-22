package com.ansonkong.media.flv.scriptData
{
	import com.ansonkong.media.flv.rule.FLVTagScriptDataType;
	
	import flash.utils.ByteArray;

	public class FLVTagScriptDataNumber extends FLVTagScriptData
	{
		/**Number*/
		public function FLVTagScriptDataNumber(data:Object)
		{
			super(data);
		}
		override public function get type():int
		{
			return FLVTagScriptDataType.NUMBER;
		}
		override protected function _generateMessage():ByteArray
		{
			var result:ByteArray = new ByteArray();
			//8字节记录DOUBLE
			result.writeDouble(_data as Number);
			return result;
		}
	}
}