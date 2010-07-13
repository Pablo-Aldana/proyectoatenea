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

	public class DilandauSearch extends UIComponent
	{
		private var key:String;
		private var request:HTTPService;
		private var again:Boolean;
		private var processeds:ArrayCollection;
		private var page:Number;
		
		public function DilandauSearch(_processeds:ArrayCollection)
		{
			super();
			request= new HTTPService();
			request.resultFormat = "text";
			request.addEventListener(ResultEvent.RESULT,onResult);
			request.addEventListener(FaultEvent.FAULT,onError);
			processeds=_processeds;
		}
		
		public function search(_key:String):void
		{
			page=1;
			again=true; 
			key=_key;
			processeds.removeAll();
			
			if(key.length>0){
				searching();	
				this.dispatchEvent(new SearchEvent(SearchEvent.START));
			}
			
		}
		
		private function searching():void
		{
			var pat:RegExp = / /; 
		    URLRequestDefaults.userAgent="Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; es-ES; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3";
			request.headers["Referer"]="http://www.dilandau.com/descargar_musica/";
		    request.headers["Host"]="www.dilandau.com";
		    request.url="http://www.dilandau.com/descargar_musica/"+key+"-"+page+".html";
			request.url=request.url.replace(pat, "+");
			request.send();
		}
		
		private function onResult(event:ResultEvent):void
		{
			var s:Song;
			var ide:String;
			var resultados:String=event.result.toString();
						
			if(again){
				var db:Array=resultados.split('<h2 class="title_song"').slice(1);
				
				var song:Object;
			 		
				for(var i:Number=0;i<db.length;i++){
					if(db[i].indexOf('.mp3') != 0){
						
						song=new Object();
						song.path1=db[i].split('Escuchar</span><a class="button" rel="nofollow" target="self" href="')[1];
						song.path=db[i].split('Escuchar</span><a class="button" rel="nofollow" target="self" href="')[1].split('" title=')[0];
						song.songID=db[i].split("player('")[1].split("')")[0];
						
						var artist_name:String=db[i].split('title="')[1].split('">')[0];
						song.artist=artist_name.split('-')[1];
						song.title=artist_name.split('-')[0];
												
						s=new Song(null, song);
						if(s.path.indexOf("socbay")==-1){
							processeds.addItem(s);
						}
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
			//processeds.addItem(e.target);
			try{
				//processing.removeItemAt(processing.getItemIndex(e.target));
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