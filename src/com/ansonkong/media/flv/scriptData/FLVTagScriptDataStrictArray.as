package com.ansonkong.media.flv.scriptData
{
	import com.ansonkong.media.flv.rule.FLVTagScriptDataType;
	
	import flash.utils.ByteArray;

	public class FLVTagScriptDataStrictArray extends FLVTagScriptData
	{
		/**
		 * [
		 * 	FLVTagScriptData,
		 * 	FLVTagScriptData
		 * ]
		 */
		public function FLVTagScriptDataStrictArray(data:Object)
		{
			super(data);
		}
		override public function get type():int
		{
			return FLVTagScriptDataType.STRICT_ARRAY;
		}
		override protected function _generateMessage():ByteArray
		{
			var result:ByteArray = new ByteArray();
			var strictArray:Array = _data as Array;
			//4字节记录数组长度
			result.writeUnsignedInt(strictArray.length);
			//遍历数组，分别写入PropertyName和PropertyData
			var temp:ByteArray;
			for each(var scriptData:FLVTagScriptData in strictArray)
			{
				//根据ScriptData的不同，写入不同的字节数组
				result.writeBytes(scriptData.generate());
			}
			return result;
		}
	}
}