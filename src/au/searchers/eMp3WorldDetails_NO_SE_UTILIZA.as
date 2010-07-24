package au.searchers
{
	import au.media.Song;
	import au.media.SongEvent;
	import au.singleton.Actualicer;
	
	import flash.net.URLRequestDefaults;
	import flash.net.URLRequestHeader;
	
	import mx.core.UIComponent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class eMp3WorldDetails_NO_SE_UTILIZA extends UIComponent
	{
		private var song:Song;
		private var request:HTTPService;
		
		public function eMp3WorldDetails_NO_SE_UTILIZA(_song:Song)
		{
			super();
			song=_song
			request = new HTTPService;
			request.resultFormat = "text"; 
			URLRequestDefaults.userAgent="Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; InfoPath.2; Tablet PC 2.0)";
			request.headers["Referer"]=song.referer;
			request.headers["Host"]="emp3world.com";
			request.url ="http://emp3world.com/mp3/"+song.songID+"/"+song.artist+"/"+song.title;
			request.addEventListener(ResultEvent.RESULT,onResult);
		}
		

		//Obtenemos el path de la canción ya que esta en otra página
		private function onResult(e:ResultEvent):void
		{
					
			var resultados:String=event.result.toString();
			song.path=resultados.split('<b>URL:</b> <a href="')[1].split('"')[0];
			
			
			//Disaparamos el evanto, path obtenido
			var evo:SongEvent = new SongEvent(SongEvent.RESULT);
			this.dispatchEvent(evo);
			
		}
		
				
		
	}
}