package au.media
{
	import flash.events.Event;
	
	public class SongEvent extends Event
	{
		public static const RESULT:String = "result";
		public static const COMPLETE:String = "complete";
		public static const DOWNLOAD:String = "download";
		public static const PLAY:String = "play";
		public static const TOLIST:String = "addToList";
		public static const INSERT_PLAYLIST:String = "insertPlaylist";
		public static const INSERT_SONG:String = "insertSong";
		
		private var _result:Object;
				
		public function get result():Object
		{
			return _result;
		}
		
		public function SongEvent($type:String, r:Object=null, $bubbles:Boolean=false, $cancelable:Boolean=false)
		{
			_result = r;
			super($type, $bubbles, $cancelable);
		}

	}
}