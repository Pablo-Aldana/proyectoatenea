package au.searchers
{
	import au.media.Song;
	import au.media.SongEvent;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class GoogleSearch extends UIComponent
	{
		private var key:String;
		private var request:HTTPService;
		private var processing:ArrayCollection;
		private var processeds:ArrayCollection;
		private var again:Boolean;
		private var page:Number;
		
		public function GoogleSearch(_processeds:ArrayCollection)
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
			request.url="http://www.google.com/custom?hl=es&client=google-coop&cof=FORID:13%3BAH:left%3BCX:Ateneo%3BL" + 
					":http://www.google.com/intl/es/images/logos/custom_search_logo_sm.gif%3BLH:30%3BLP:1%3BVLC:%2355" + 
					"1a8b%3BDIV:%23cccccc%3B&adkw=AELymgXIifkD6HTGqUPT8egPditREciCrdylRpec9AgaVfobxc-LiNYRkF7cZosE5Kh" + 
					"c99ydilE_NqDeV_H7kemym5qUPusmf2p_4Kl6aqUHM_m3cAlpRdk&boostcse=0&cx=015669567992791861701:sw3ib_v" + 
					"mycu&q="+key+"&start="+String(page*10)+"&sa=N";
			//request.url="http://www.google.es/#hl=es&safe=off&q="+key+"+site%3Awww.goear.com&start="+String(page*10);
			request.url=request.url.replace(pat, "+");
			request.send();
		}
		
		private function onResult(event:ResultEvent):void
		{
			var s:Song;
			var ide:String;
			var resultados:String=event.result.toString();
						
			if(again){
				var db:Array=resultados.split('http://www.listengo.com/song/').slice(1);
			 		
				for(var i:Number=0;i<db.length;i++){
						
						trace(db[i]);	
						ide=db[i].split('"')[0];
						trace("------------"+ide);				
						s=new Song(ide);
						s.addEventListener(SongEvent.COMPLETE,addResult);
						processeds.addItem(s);
				}
				
				if(db.length>5){
					page++;
					searching();
				}else{
					stop();
				}
				trace("------------");			
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