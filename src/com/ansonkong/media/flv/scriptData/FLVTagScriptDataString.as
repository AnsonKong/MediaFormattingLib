package com.ansonkong.media.flv.scriptData
{
	import com.ansonkong.media.flv.rule.FLVTagScriptDataType;
	
	import flash.utils.ByteArray;

	public class FLVTagScriptDataString extends FLVTagScriptData
	{
		/**String*/
		public function FLVTagScriptDataString(data:Object)
		{
			super(data);
		}
		override public function get type():int
		{
			return FLVTagScriptDataType.STRING;
		}
		override protected function _generateMessage():ByteArray
		{
			var result:ByteArray = new ByteArray();
			var temp:ByteArray = new ByteArray();
			temp.writeUTFBytes(_data as String);
			//2字节记录字符串长度
			result.writeShort(temp.length);
			//写入数据
			result.writeBytes(temp);
			return result;
		}
	}
}