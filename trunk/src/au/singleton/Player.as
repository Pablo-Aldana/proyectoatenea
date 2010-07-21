package au.singleton
{
	import au.media.Playlist;
	import au.media.Song;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	
	import mx.core.UIComponent;
	

	[Bindable]
	public class Player extends UIComponent
	{
		
		private static var _instance:Player;
		
		public var playlist:Playlist;
		public var playing:Boolean=false;
		public var song:Song;
        private var soundTR:SoundTransform;
        private var channel:SoundChannel;
        private var request:URLRequest
        private var loading:Boolean=false;
        private var soundFactory:Sound;
        private var volume:Number=1;
		
		public static function get instance():Player //devuelve la instancia de la clase estatica 
		{
			if (_instance == null)
			{
				_instance = new Player();
			}
			return _instance;
		}		
		
		public function selectPlaylist(_playlist:Playlist):void
		{
			playlist=_playlist;
		}
		
		public function play(_song:Song,continuos:Boolean=false):void
		{

		    if (playing) channel.stop();
		    
		    loading=true;
		    playing=true;
		    song=_song;
		    playlist.current=song;

			if(!continuos)
		    	song.position = 0;
		    
			    request = new URLRequest(song.path); //para listas
			    trace(song.path);
			    var header:URLRequestHeader = new URLRequestHeader("Referer",song.referer);
			    request.requestHeaders.push(header);
			    request.userAgent="Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; InfoPath.2; Tablet PC 2.0)";
		    
		    if(soundFactory)

		    	if(loading)
		    		try{
		       			soundFactory.close();
		      		}catch(e:Error){};
		    
		    	
			    	soundFactory= new Sound();

			    try{
			  	   	soundFactory.load(request);
			    	channel = soundFactory.play();
			    	soundTR = new SoundTransform();
					soundTR.volume = volume;
			    	channel.soundTransform=soundTR;
		    	    
			    }catch(e:Error){
			    	trace("no carga sonido");
		    };
		    channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
	        
	        soundFactory.addEventListener(Event.COMPLETE, function f(e:Event):void{loading=false;});
	     	soundFactory.addEventListener(ProgressEvent.PROGRESS, function f(e:ProgressEvent):void{
				loading=true;
				song.bytesLoaded=e.bytesLoaded;
				song.bytesTotal=e.bytesTotal;
	        });
	        
	        addEventListener(Event.ENTER_FRAME,onProgress);
			
		}
		
		private function onProgress(e:Event):void{
	   			
	   			var pMinutes:Number;
	   			var pSeconds:Number;
	   
	        	song.length = Math.round(soundFactory.length / (soundFactory.bytesLoaded / soundFactory.bytesTotal));
	   		 	//song.position = Math.round(1000 * (channel.position / song.length))/10;
	    		song.position = Math.round(channel.position);
	   
				//bprogreso.setProgress(playbackPercent, 100); 
				if(channel!=null){
			  		pMinutes = Math.floor(song.position / 1000 / 60);
	          		pSeconds = Math.floor(song.position / 1000) % 60;
	          		song.time = pMinutes+":"+(pSeconds < 10?"0"+pSeconds:pSeconds);
	          		var tempMinutes:Number = Math.floor(song.length  / 1000 / 60);
	                var tempSeconds:Number = Math.floor(song.length  / 1000) % 60;
					//slider.value=song.position;
					//slider.maximum=estimatedLength;
					if(song.length)
	          			song.totalTime= tempMinutes+":"+(tempSeconds < 10?"0"+tempSeconds:tempSeconds);
	   				 else
	   				 	song.totalTime="0:00"
	   				 	
	   				if(song.time==song.totalTime && !loading ) //chapuza mientras solucionamos el evenListener de sound complete
	   					next();
	   			}
	   	}
	        
		private function soundCompleteHandler(event:Event):void
		{
		    next();
        }
		
		public function next():void 
		{
			this.play(playlist.next());
		}
		
		// Switch to Previous Song
		public function prev():void 
		{
			this.play(playlist.prev());
		}
		
		public function pause():void 
		{
		   if (!playing) {
			    channel = soundFactory.play(song.position);
			    channel.addEventListener(Event.SOUND_COMPLETE,soundCompleteHandler);
			    playing=true;
		    } else {
			    channel.stop();
			    playing=false;
		    }
		}
		
		public function goTo(v:Number):void
		{
			channel.stop();
			channel = soundFactory.play(v);
			channel.soundTransform = soundTR; 
		}
		
		
		public function setVolume(vol:Number):void
		{
			try{
				volume=vol;
				soundTR.volume = vol;
				channel.soundTransform = soundTR; 
			}catch(e:Error){};
		}
		
	}
}