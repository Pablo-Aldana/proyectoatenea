package au.searchers
{
	import au.media.SongEvent;
	
	import flash.net.URLRequestDefaults;
	import flash.net.URLRequestHeader;
	
	import mx.core.UIComponent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import au.singleton.Actualicer;

	public class GoearDetails extends UIComponent
	{
		private var goearID:String;
		private var request:HTTPService;
		
		public function GoearDetails(_id:String,link:String)
		{
			super();
			goearID=_id; 
			request = new HTTPService;
			request.resultFormat = "e4x"; 
			URLRequestDefaults.userAgent="Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; InfoPath.2; Tablet PC 2.0)";
			request.headers["Referer"]="http://www.goear.com/listen/"+link;
			request.headers["Host"]="www.goear.com";
			request.url = Actualicer.instance.xmlFile+goearID;
			request.url = "http://www.goear.com/tracker758.php?f="+goearID;
			request.addEventListener(ResultEvent.RESULT,onResult);
		}
		
		public function loadXML():void
		{
			request.send();
		}
		
		private function onResult(e:ResultEvent):void
		{

			var evo:SongEvent = new SongEvent(SongEvent.RESULT,XML(e.result));
			this.dispatchEvent(evo);
			
		}
		
				
		
	}
}