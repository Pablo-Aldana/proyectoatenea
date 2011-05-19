package au.searchers
{
	import au.media.Song;
	import au.media.SongEvent;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestDefaults;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class vkSearch extends UIComponent
	{
		private var key:String;
		private var request:URLRequest;
		private var processing:ArrayCollection;
		private var processeds:ArrayCollection;
		private var again:Boolean;
		private var page:Number;
		private var loader:URLLoader = new URLLoader();  
		
		public function vkSearch(_processeds:ArrayCollection)
		{
			super();	
			request= new URLRequest();
			loader.addEventListener(Event.COMPLETE,onResult);
			//request.addEventListener(FaultEvent.FAULT,onError);
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
			request.url='http://login.vk.com/?act=login&email=&pass=';
			var variables:URLVariables = new URLVariables();//create a variable container  
			variables.pass = "380413";  
			variables.email = "javiercebrianrico%40gmail.com"; 
			request.data = variables;//add the data to our containers  
			request.method = URLRequestMethod.POST;//select the method as post  
			
			//request.headers["Referer"]='http://www.vk.com';
		    //request.headers["Host"]="vk.com";
			//request.url=request.url.replace(pat, "+");
			loader.load(request);//send the request with URLLoader() 
		}
		
		private function onResult(event:Event):void
		{
			var s:Song;
			var ide:String;
			var link:String;
			var resultados:String=event.currentTarget.data;
						
			
			request.url='http://vkontakte.ru/gsearch.php?section=audio&q=gaga';
			request.data=null;
			loader.load(request);
			
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