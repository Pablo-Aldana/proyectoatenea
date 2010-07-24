package au.searchers
{
	import au.media.SongEvent;
	import au.singleton.Actualicer;
	
	import flash.net.URLRequestDefaults;
	import flash.net.URLRequestHeader;
	
	import mx.core.UIComponent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class mp3000Details extends UIComponent
	{
		private var mp3000ID:String;
		private var request:HTTPService;
		
		public function mp3000Details(_id:String,_link:String,referer:String)
		{
			super();
			mp3000ID=_id; 
			request = new HTTPService;
			request.resultFormat = "text"; 
			URLRequestDefaults.userAgent="Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; InfoPath.2; Tablet PC 2.0)";
			request.headers["Referer"]=referer;
			request.headers["Host"]="www.mp3000.net";
			request.url = "http://www.mp3000.net/download/mp3/"+_link;
			request.addEventListener(ResultEvent.RESULT,onResult);
		}
		
		public function send():void
		{
			request.send();
		}
		
		private function onResult(e:ResultEvent):void
		{
			var resultados:String=e.result.toString();
			
			var link:String=resultados.split('<a href="http://www.mp3000.net/redirect/')[1].split('"')[0];
			var obj:Object=new Object();
			obj.link="http://www.mp3000.net/redirect/"+link;
			obj.referer=request.url;
			var evo:SongEvent = new SongEvent(SongEvent.RESULT,obj);
			this.dispatchEvent(evo);
			
		}
		
				
		
	}
}