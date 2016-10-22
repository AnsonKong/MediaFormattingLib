package com.ansonkong.media.flv.tag
{
	import com.ansonkong.media.flv.rule.FLVTagScriptDataType;
	import com.ansonkong.media.flv.rule.FLVTagType;
	import com.ansonkong.media.flv.scriptData.FLVTagScriptData;
	
	import flash.utils.ByteArray;

	public class FLVScriptDataTag extends FLVTag
	{
		protected var _datas:Array;
		override protected function get tagType():uint
		{
			return FLVTagType.SCRIPT_DATA;
		}
		
		override protected function get message():ByteArray
		{
			var result:ByteArray = new ByteArray();
			if(_datas)
			{
				for each(var data:FLVTagScriptData in _datas)				
				{
					result.writeBytes(data.generate());
				}
			}
			result.position = 0;
			return result;
		}
		
		public function addData(data:FLVTagScriptData):void
		{
			if(!_datas) _datas = [];
			_datas.push(data);
		}
	}
}