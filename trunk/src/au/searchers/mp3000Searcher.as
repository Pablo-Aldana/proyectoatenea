package au.searchers
{
	import au.media.Song;
	import au.media.SongEvent;
	
	import flash.net.URLRequest;
	import flash.net.URLRequestDefaults;
	import flash.net.URLRequestHeader;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Text;
	import mx.core.UIComponent;
	import mx.messaging.messages.HTTPRequestMessage;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class mp3000Searcher extends UIComponent
	{
		private var key:String;
		private var query:String;
		private var page:Number;
		private var request:HTTPService;
		private var processing:ArrayCollection;
		private var processeds:ArrayCollection;
		private var again:Boolean;
		
		public function mp3000Searcher(_processeds:ArrayCollection,user:String)
		{
			super();	
			request= new HTTPService();
			request.resultFormat = "text";
			request.addEventListener(ResultEvent.RESULT,onResult);
			request.addEventListener(FaultEvent.FAULT,onError);
			URLRequestDefaults.userAgent=user;
			query="http://www.mp3000.net/s.php?&val=srch&searched=1&q=";
			request.headers["Referer"]="http://www.mp3000.net/";
			request.headers["Host"]="www.mp3000.net";
			
			processing= new ArrayCollection();
			processeds=_processeds;
		}
		
		//Cuidado el query esta cambiado el parametro phrase, si nos chapan, cambiar el orden ;)
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
		  	request.url=query+key;
			request.url=request.url.replace(pat, "+");
			request.send();
			
			
		}
		
		private function onResult(event:ResultEvent):void
		{
			var s:Song;
			var ide:String;
			var link:String;
			var resultados:String=event.result.toString();
					
			var db:Array=resultados.split('<a href="/download/mp3/').slice(1);
		 		
			for(var i:Number=0;i<db.length;i++){
				if(db[i].indexOf('">') != 0){
					
											
					s=new Song();
					
					try{
						
						
						s.songID=db[i].split('/')[0];
						s.path=null;
						s.title=db[i].split('">')[1].split('-')[1].split("</a>")[0];
						s.artist=db[i].split('">')[1].split('-')[0];
						s.server="mp3000";
						s.referer="http://www.mp3000.net/mp3_0/"+key;
						s.host="www.mp3000.net";
						s.detailslink=db[i].split('"')[0];
						
						
					}catch(e:Error){}
					

					processeds.addItem(s);
				}
			}
			
			stop();
		
			
		}
		
		public function stop():void
		{
			this.dispatchEvent(new SearchEvent(SearchEvent.STOP));
		}
				
		private function onError(e:FaultEvent):void
		{
			trace(e.toString());
			request.send();
		}
		
	}
}