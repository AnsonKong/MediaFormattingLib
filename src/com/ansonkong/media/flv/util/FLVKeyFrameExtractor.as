package com.ansonkong.media.flv.util
{
	import flash.utils.ByteArray;
	
	public class FLVKeyFrameExtractor
	{
		public static function extract(flvBytes:ByteArray, filepositionOffset:uint = 0):Object
		{
			var oldPosition:uint = flvBytes.position;
			flvBytes.position = 0;
			var result:Object = {};
			//存储秒
			var times:Array = [];
			//存储在文件中的字节位置
			var filepositions:Array = [];
			//从解密字节中搜索是否有可用的VideoTag
			//1字节VideoTag 0x09
			//3字节DataSize
			//3字节Timestamp
			//1字节TimestampExtended
			//3字节StreamID
			//1字节后面VideoTag，取高4位进行判断是否为0001，即keyframe
			//共12字节
			while(flvBytes.bytesAvailable >= 12)
			{
				var firstByte:uint = flvBytes.readUnsignedByte();
				if(firstByte == 0x09)
				{
					//记录当前VideoTag位置
					var videoTagPos:uint = flvBytes.position - 1;
					//跳过DataSize + Timestamp + TimestampExtended总共7个字节
					flvBytes.position += 7;
					var streamID0:uint = flvBytes.readUnsignedByte();
					var streamID1:uint = flvBytes.readUnsignedByte();
					var streamID2:uint = flvBytes.readUnsignedByte();
					var videoTagHeader:uint = flvBytes.readUnsignedByte();
					videoTagHeader = videoTagHeader >> 4;
					//videoTagHeader是1，代表是key frame
					if(streamID0 == 0 && streamID1 == 0 && streamID2 == 0 && videoTagHeader == 1)
					{
						//这是一个VideoTag的开始
						flvBytes.position = videoTagPos + 4;
						//现在要计算timestamp，毫秒
						var timestamp0:uint = flvBytes.readUnsignedByte();
						var timestamp1:uint = flvBytes.readUnsignedByte();
						var timestamp2:uint = flvBytes.readUnsignedByte();
						var timestampExtended:uint = flvBytes.readUnsignedByte();
						//临时字节数组
						var temp:ByteArray = new ByteArray();
						temp.writeByte(timestampExtended);
						temp.writeByte(timestamp0);
						temp.writeByte(timestamp1);
						temp.writeByte(timestamp2);
						temp.position = 0;
						//ms
						var timestamp:uint = temp.readUnsignedInt();
						//转s
						var seconds:Number = timestamp / 1000;
						
						times.push(seconds);
						filepositions.push(filepositionOffset + videoTagPos);
					}
					else
					{
						flvBytes.position = videoTagPos + 1;
					}
				}
			}
			flvBytes.position = oldPosition;
			result["times"] = times;
			result["filepositions"] = filepositions;
			return result;
		}
	}
}