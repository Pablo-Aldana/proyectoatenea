package object
{
	import flash.events.Event;

	public class myEvent extends Event
	{
		public var datos:Object=new Object();
		public function myEvent(type:String, _datos:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			datos=_datos;
			super(type, bubbles, cancelable);
		}
		
	}
}