package au.searchers
{
	import flash.net.URLRequestDefaults;
	
	import mx.core.UIComponent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class DowintLink extends UIComponent
	{
		
		private var linkIn:String;
		public var linkOut:String;
		private var request:HTTPService;
		
		public function DowintLink(_in:String)
		{
			super();
			
			linkIn="http://www.goear.com/listen/"+_in;
			trace(linkIn);
			getLink(linkIn);
		}
		
		private function getLink(_in:String):void
		{
			request= new HTTPService();
			///
			URLRequestDefaults.userAgent="Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; InfoPath.2; Tablet PC 2.0)";
   			request.headers["Referer"]="http://dowint.net/";
     		request.headers["Host"]="dowint.net";
			///
			request.url="http://dowint.net/?site=1&url="+_in+"&download=Descargar";
			request.resultFormat = "text";
			request.addEventListener(ResultEvent.RESULT,onResult);
			request.addEventListener(FaultEvent.FAULT,onError);
 			request.send();
		}
		
		private function onError(e:FaultEvent):void
		{
			trace("FAULT ERROR: "+e.message);
		}
		
		private function onResult(e:ResultEvent):void
		{
			var resultado:String=e.result.toString();
			linkOut=resultado.split('<a class="num" id="descargar" href="')[1].split('">')[0];
			if(linkOut.indexOf(".mp3", -4) != -1){
				trace(linkOut);
			}else{
				trace("Link incorrecto");
			}
		}
		
	}
}