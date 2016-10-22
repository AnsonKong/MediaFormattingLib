package com.ansonkong.media.flv.tag
{
	import flash.utils.ByteArray;

	public class FLVTag
	{
		protected var _timestamp:uint;
		protected function get tagType():uint
		{
			return 0;
		}
		/**高1字节是timestamp extended，低3字节是timestamp*/
		public function set timestamp(value:uint):void
		{
			_timestamp = value;
		}
		public function get timestamp():uint
		{
			return _timestamp;
		}
		protected function get message():ByteArray
		{
			//override
			return null;
		}
		public function clear():void
		{
			_timestamp = 0;
		}
		final public function generate():ByteArray
		{
			var result:ByteArray = new ByteArray();
			var targetMessage:ByteArray = message;
			//写入TagType
			result.writeByte(tagType);
			//写入DataSize，取低3字节
			var temp:ByteArray = new ByteArray();
			temp.writeUnsignedInt(targetMessage.length);
			temp.position = 1;
			while(temp.bytesAvailable) result.writeByte(temp.readByte());
			//写入Timestamp
			temp = new ByteArray();
			temp.writeUnsignedInt(timestamp);
			//取低3字节，timestamp
			temp.position = 1;
			while(temp.bytesAvailable) result.writeByte(temp.readByte());
			//取高1字节，timestamp extended
			temp.position = 0;
			result.writeByte(temp.readByte());
			//写入StreamID，3字节的0
			result.writeByte(0);
			result.writeByte(0);
			result.writeByte(0);
			//写入Data
			result.writeBytes(targetMessage);
			result.position = 0;
			return result;
		}
	}
}