package au.searchers
{
	import flash.events.Event;
	
	public class SearchEvent extends Event
	{
		public static const START:String = "start";
		public static const STOP:String = "stop";
		
		public function SearchEvent($type:String, $bubbles:Boolean=false, $cancelable:Boolean=false)
		{
			super($type, $bubbles, $cancelable);
		}

	}
}