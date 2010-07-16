package au.searchers
{
	import au.media.Song;
	import au.media.SongEvent;
	
	import flash.net.URLRequestDefaults;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class vkSearch extends UIComponent
	{
		private var key:String;
		private var request:HTTPService;
		private var processing:ArrayCollection;
		private var processeds:ArrayCollection;
		private var again:Boolean;
		private var page:Number;
		
		public function vkSearch(_processeds:ArrayCollection)
		{
			super();	
			request= new HTTPService();
			request.resultFormat = "text";
			request.addEventListener(ResultEvent.RESULT,onResult);
			request.addEventListener(FaultEvent.FAULT,onError);
			processing= new ArrayCollection();
			processeds=_processeds;
		}
		
		public function search(_key:String):void
		{
			page=0;
			again=true; 
			key=_key;
			processeds.removeAll();
			processing.removeAll();
			
			if(key.length>0){
				searching();	
				this.dispatchEvent(new SearchEvent(SearchEvent.START));
			}
			
		}
		
		private function searching():void
		{

			var pat:RegExp = / /; 
		    URLRequestDefaults.userAgent="Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; InfoPath.2; Tablet PC 2.0)";
			request.url='http://www.goear.com/search.php?q='+key+'&p='+page;
			request.headers["Referer"]='http://www.goear.com/search.php?q='+key+'&p='+page;
		    request.headers["Host"]="www.goear.com";
			request.url=request.url.replace(pat, "+");
			request.send();
		}
		
		private function onResult(event:ResultEvent):void
		{
			var s:Song;
			var ide:String;
			var link:String;
			var resultados:String=event.result.toString();
						
			if(again){
				var db:Array=resultados.split('<a title="').slice(1);
			 		
				for(var i:Number=0;i<db.length;i++){
					if(db[i].indexOf('" href="listen/') != 0){
						
						ide=db[i].split('" href="listen/')[1].split('"')[0];
												
						s=new Song(ide);
						s.addEventListener(SongEvent.COMPLETE,addResult);
						processing.addItem(s);
					}
				}
				
				if(db.length>5){
					page++;
					searching();
				}else{
					stop();
				}
			}
			
		}
		
		private function addResult(e:SongEvent):void
		{
			processeds.addItem(e.target);
			try{
				processing.removeItemAt(processing.getItemIndex(e.target));
			}catch(e:Error){};
		}
		
		public function stop():void
		{
			again=false;
			this.dispatchEvent(new SearchEvent(SearchEvent.STOP));
		}
				
		private function onError(e:FaultEvent):void
		{
			trace(e.toString());
		}
		
	}
}