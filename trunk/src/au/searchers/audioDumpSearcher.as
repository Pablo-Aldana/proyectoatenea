package au.searchers
{
	import au.media.Song;
	import au.media.SongEvent;
	
	import flash.net.URLRequestDefaults;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Text;
	import mx.core.UIComponent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class audioDumpSearcher extends UIComponent
	{
		private var key:String;
		private var query:String;
		private var page:Number;
		private var request:HTTPService;
		private var processing:ArrayCollection;
		private var processeds:ArrayCollection;
		private var again:Boolean;
		
		public function audioDumpSearcher(_processeds:ArrayCollection,user:String,host:String,referer:String,_query:String)
		{
			super();	
			request= new HTTPService();
			request.resultFormat = "text";
			request.addEventListener(ResultEvent.RESULT,onResult);
			request.addEventListener(FaultEvent.FAULT,onError);
			URLRequestDefaults.userAgent=user;
			query=_query;
			
			request.headers["Referer"]=referer;
			request.headers["Host"]=host;
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
		  	request.url=query+key;
			request.url=request.url.replace(pat, "+");
			request.send();
		}
		
		private function onResult(event:ResultEvent):void
		{
			var s:Object;
			var song:Song;
			var ide:String;
			var link:String;
			var resultados:String=event.result.toString();
						
			if(again){
				var db:Array=resultados.split('<a href="download.php?').slice(1);
			 		
				for(var i:Number=0;i<db.length;i++){
					if(db[i].indexOf('">') != 0){
						
												
						s=new Object();
						
						try{
							s.path="http://www.audiodump.com/download.php?"+db[i].split('">')[0];
							s.songID=db[i].split('&q=')[0];
							s.title=db[i].split('">')[1].split('-')[1].split('</a>')[0];
							s.artist=db[i].split('">')[1].split('-')[0];
						}catch(e:Error){}
						
						song= new Song(null,s);

						processeds.addItem(song);
					}
				}
				
				/*if(db.length>5){
					page++;
					searching();
				}else{
					stop();
				}*/
				stop();
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
			request.send();
		}
		
	}
}