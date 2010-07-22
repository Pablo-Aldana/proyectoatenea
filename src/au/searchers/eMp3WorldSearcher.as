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

	public class eMp3WorldSearcher extends UIComponent
	{
		private var key:String;
		private var query:String;
		private var page:Number;
		private var request:HTTPService;
		private var processing:ArrayCollection;
		private var processeds:ArrayCollection;
		private var again:Boolean;
		
		public function eMp3WorldSearcher(_processeds:ArrayCollection,user:String)
		{
			super();	
			request= new HTTPService();
			request.resultFormat = "text";
			request.addEventListener(ResultEvent.RESULT,onResult);
			request.addEventListener(FaultEvent.FAULT,onError);
			URLRequestDefaults.userAgent=user;
			query="http://emp3world.com/search.php?&type=mp3s&submit=Search&phrase=";
			request.headers["Referer"]="http://emp3world.com/";
			request.headers["Host"]="emp3world.com";
			processing= new ArrayCollection();
			processeds=_processeds;
		}
		
		//Cuidado el query esta cambiado el parametro phrase, si nos chapan, cambiar el orden ;)
		public function search(_key:String):void
		{
			page=0;
			again=true; 
			key=_key;
			
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
						
			var db:Array=resultados.split('<td width="95%"><a href="/mp3/').slice(1);
		 		
			for(var i:Number=0;i<db.length;i++){
				if(db[i].indexOf('">') != 0){
					
											
					s=new Song();
					
					try{
						
						
						s.songID=db[i].split('/')[0];
						s.path="http://emp3world.com/to_download.php?id="+s.songID;
						s.title=db[i].split('/')[2].split('">')[0];
						s.artist=db[i].split('/')[1];
						s.server="emp3world";
						s.referer="http://emp3world.com/mp3/"+s.songID+"/"+s.artist+"/"+s.title;
						s.host="emp3world.com";
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