package au.searchers
{
	import mx.core.UIComponent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class GoogleImages extends UIComponent
	{
		private var key:String;
		private var request:HTTPService;
		[Bindable] public var path:String;
				
		public function GoogleImages()
		{
			super();
			request= new HTTPService();
			request.resultFormat = "text";
			request.addEventListener(ResultEvent.RESULT,onResult);
			//request.addEventListener(FaultEvent.FAULT,onError);
		}
		
		public function search(_key:String):void
		{ 
			key=_key;
			request.url="http://images.google.es/images?hl=es&source=hp&q="+escape(key)+"&um=1&ie=UTF-8&sa=N&tab=wi#start=0&imgw=300&imgh=300&tbo=1";
			request.send();			
		}
			
		private function onResult(event:ResultEvent):void
		{
			var resultados:String=event.result.toString();
			try{
				path=resultados.split('<img')[2].split('src="')[1].split('" id=')[0];
			}catch(e:Error){};
		 		
		}
	}
}