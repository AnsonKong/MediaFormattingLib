package com.ansonkong.media.flv.scriptData
{
	import com.ansonkong.media.flv.rule.FLVTagScriptDataType;
	
	import flash.utils.ByteArray;

	public class FLVTagScriptDataECMAArray extends FLVTagScriptData
	{
		/**
		 * [ 
		 * 	{ propertyName: String, propertyData: FLVTagScriptData}
		 * 	{ propertyName: String, propertyData: FLVTagScriptData}
		 * ]
		 */
		public function FLVTagScriptDataECMAArray(data:Object)
		{
			super(data);
		}
		override public function get type():int
		{
			return FLVTagScriptDataType.ECMA_ARRAY;
		}
		override protected function _generateMessage():ByteArray
		{
			var result:ByteArray = new ByteArray();
			var ecmaArray:Array = _data as Array;
			//4字节记录有多少个键值对
			result.writeUnsignedInt(ecmaArray.length);
			//遍历数组，分别写入PropertyName和PropertyData
			var temp:ByteArray;
			for each(var obj:Object in ecmaArray)
			{
				var propertyName:String = obj["propertyName"];
				var scriptData:FLVTagScriptData = obj["propertyData"];
				temp = new ByteArray();
				temp.writeUTFBytes(propertyName);
				//2字节记录PropertyName的字节长度
				result.writeShort(temp.length);
				//写入PropertyName
				result.writeBytes(temp);
				//根据ScriptData的不同，写入不同的字节数组
				result.writeBytes(scriptData.generate());
			}
			//List Terminator
			result.writeByte(0x00);
			result.writeByte(0x00);
			result.writeByte(0x09);
			return result;
		}
	}
}