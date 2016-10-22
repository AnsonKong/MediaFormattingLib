package com.ansonkong.media.builder
{
	import com.ansonkong.media.flv.tag.FLVTag;
	
	import flash.utils.ByteArray;

	public class FLVBuilder
	{
		protected var _flvHeaderBytes:ByteArray;
		protected var _tags:Array;
		public function buildFLVHeader(typeFlagsAudio:Boolean = true,
									   typeFlagsVideo:Boolean = true,
									   version:int = 1):void
		{
			//写入FLV
			_flvHeaderBytes = new ByteArray();
			_flvHeaderBytes.writeByte(0x46);
			_flvHeaderBytes.writeByte(0x4C);
			_flvHeaderBytes.writeByte(0x56);
			//Version
			_flvHeaderBytes.writeByte(version);
			//TypeFlags
			var typeFlags:int = 0;
			if(typeFlagsAudio) typeFlags |= 4;
			if(typeFlagsVideo) typeFlags |= 1;
			_flvHeaderBytes.writeByte(typeFlags);
			//DataOffset，当version是1的时候，写入0x09
			if(version == 1) _flvHeaderBytes.writeUnsignedInt(0x09);
			_flvHeaderBytes.position = 0;
		}
		
		public function addTag(tag:FLVTag):void
		{
			if(!_tags) _tags = [];
			_tags.push(tag);
		}
		
		public function generateFLV():ByteArray
		{
			//FLVHeader
			var result:ByteArray = new ByteArray();
			result.writeBytes(_flvHeaderBytes);
			//FLVTags
			if(_tags)
			{
				var previousTagSize:uint;
				//第一个PreviousTagSize总是0
				result.writeUnsignedInt(previousTagSize);
				for each(var tag:FLVTag in _tags)
				{
					//获取下一个Tag的字节数组
					var tagBytes:ByteArray = tag.generate();
					//写入数据
					result.writeBytes(tagBytes);
					//更新PreviousTagSize
					previousTagSize = tagBytes.length;
					//写入PreviousTagSize
					result.writeUnsignedInt(previousTagSize);
				}
			}
			result.position = 0;
			return result;
		}
	}
}