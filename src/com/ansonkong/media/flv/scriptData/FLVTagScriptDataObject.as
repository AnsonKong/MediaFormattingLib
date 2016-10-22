package com.ansonkong.media.flv.scriptData
{
	import com.ansonkong.media.flv.rule.FLVTagScriptDataType;
	
	import flash.utils.ByteArray;

	public class FLVTagScriptDataObject extends FLVTagScriptData
	{
		/**
		 * {
		 * 	propertyName: FLVTagScriptData,
		 * 	propertyName: FLVTagScriptData
		 * }
		 */
		public function FLVTagScriptDataObject(data:Object)
		{
			super(data);
		}
		override public function get type():int
		{
			return FLVTagScriptDataType.OBJECT;
		}
		override protected function _generateMessage():ByteArray
		{
			var result:ByteArray = new ByteArray();
			var temp:ByteArray;
			for(var propertyName:String in _data)
			{
				temp = new ByteArray();
				temp.writeUTFBytes(propertyName);
				//2字节记录PropertyName的字节长度
				result.writeShort(temp.length);
				//写入PropertyName
				result.writeBytes(temp);
				
				var propertyData:FLVTagScriptData = _data[propertyName];
				//根据ScriptData的不同，写入不同的字节数组
				result.writeBytes(propertyData.generate());
			}
			//List Terminator
			result.writeByte(0x00);
			result.writeByte(0x00);
			result.writeByte(0x09);
			return result;
		}
	}
}