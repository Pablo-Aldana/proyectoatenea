package object {
    import flash.events.*;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;
    import flash.net.URLRequest;
    
    import mx.collections.ArrayCollection;
    import mx.containers.Panel;
    import mx.controls.Button;
    import mx.controls.HSlider;
    import mx.controls.Label;
    import mx.controls.ProgressBar;
    import mx.formatters.DateFormatter;
        
    public class SuperSimpleMP3Player extends Panel {
    	[Bindable] public var canciones:ArrayCollection = new ArrayCollection;
        [Bindable] public var currentIndex:Number = 0;
        private var soundTR:SoundTransform;
        private var song:SoundChannel;
        private var request:URLRequest
		private var paused:Boolean = false;
		private var stopped:Boolean = true;
		private var position:Number;
        private var soundFactory:Sound;

	// The magic var that allows us to set the actual
	// implementation of the play button from the Flex
	// MXML.  This allows a custom component, see
	// SimpleMP3.mxml, to set the actual button that
	// playButton referres to, letting us change the 
	// label, or any other property of the button in
	// our ActionScript.
	public var playButton:Button;
	public var pauseButton:Button;
	public var bprogreso:ProgressBar;
	public var bcarga:ProgressBar;
	public var titulo:Label;
	public var ttotal:Label;
	public var tactual:Label;
    public var slider:HSlider;
    [Bindable] public var sLength:String = "0.00";
     [Bindable] public var sPosition:String = "0.00";
        public var pMinutes:Number                 = 0;
        public var pSeconds:Number                 = 0;


	// Play MP3 at specified index in songURLs array.
	public function playMP3(mp3Index:Number):void
	{
		if (!stopped) stop();
	    stopped = false;
	    paused = false;
	    currentIndex=mp3Index;
        //playButton.label = "||";
        pauseButton.visible=true;
	    position = 0;
	   	var request:URLRequest = new URLRequest(canciones[mp3Index].path); //para listas 
	    //var request:URLRequest = new URLRequest("http://194.169.201.177:8085/live3.mp3"); //para radio 
	    soundFactory = new Sound();
	    soundFactory.addEventListener(Event.ID3, id3Handler);
	    try{
	    	soundFactory.load(request);
	    	song = soundFactory.play();
	    	soundTR = new SoundTransform();
	    	song.soundTransform=soundTR;
	    }catch(e:Error){
	    	trace("no carga sonido");
	    };
        song.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
        
     	soundFactory.addEventListener(ProgressEvent.PROGRESS, function f(e:ProgressEvent):void{
        	var perc:Number=Math.round((e.bytesLoaded/e.bytesTotal)*1000)/10;
        	trace(perc);
			bcarga.setProgress(perc, 100);       			      	
        });
        
        addEventListener(Event.ENTER_FRAME,function f(e:Event):void{
        	var estimatedLength:Number = Math.round(soundFactory.length / (soundFactory.bytesLoaded / soundFactory.bytesTotal));
   		 	var playbackPercent:Number = Math.round(1000 * (song.position / estimatedLength))/10;
    		trace("Sound playback is " + playbackPercent + "% complete.");
    
			bprogreso.setProgress(playbackPercent, 100); 
			if(song!=null){
		  		pMinutes = Math.floor(song.position / 1000 / 60);
          		pSeconds = Math.floor(song.position / 1000) % 60;
          		sPosition = pMinutes+":"+(pSeconds < 10?"0"+pSeconds:pSeconds);
          		var tempMinutes:Number = Math.floor(estimatedLength  / 1000 / 60);
                var tempSeconds:Number = Math.floor(estimatedLength  / 1000) % 60;
				slider.value=song.position;
				slider.maximum=estimatedLength;
				if(estimatedLength){
          			sLength= tempMinutes+":"+(tempSeconds < 10?"0"+tempSeconds:tempSeconds);
   				 }
   			}
        });
  		
	}
 
        // Since the id3 information is not available until it 
        // is read off the string we need to make sure we have 
        // a way of updating the UI once it has been loaded.
        // Having songName as a bindable allows us to do that,
        // and the id3Handler will notify us when the information
        // is ready to be displayed.
        [Bindable("songNameChanged")]
	public function get songName():String {
		return soundFactory.id3.artist + 
			" - " + soundFactory.id3.songName;
        }

	// Alert songNameChanged bind when id3 information
	// has been loaded.
        private function id3Handler(event:Event):void {
            dispatchEvent(new Event("songNameChanged"));
        }
	
	// Start the next song, once the current one has
	// finished playing.
	private function soundCompleteHandler(event:Event):void {
	    position = 0;
	    currentIndex++;
	    if (currentIndex >= canciones.length) { 
	        currentIndex = 0; 
	    }
	    playMP3(currentIndex);
        }

	// Pause current song, or play song if already paused.
	// Setting playButton label such that any GUI button
	// that is attached will change with play or pause.
	public function pause():void 
	{
		if(canciones.length>0){
		    if (!stopped) {
		        if (!paused) {
		    	    paused = true;
			    position = song.position;
			    song.stop();
			   // playButton.label = ">";
			   pauseButton.visible=false;
		        } else {
			    paused = false;
			    song = soundFactory.play(position);
			    song.addEventListener(Event.SOUND_COMPLETE, 
			    	soundCompleteHandler);
			    //playButton.label = "||";
			    pauseButton.visible=true;
		        }
		    } else {
		        playMP3(currentIndex);
		        //playButton.label = "||";
		        pauseButton.visible=true;
		    }
		}		  
	}

	// Stop current song        
	public function stop():void {		
		stopped = true;
		if(canciones.length>0)	song.stop();
		position = 0;
		//playButton.label = ">";
		pauseButton.visible=false;
	}
	

	
	public function goToTime():void
	{
		paused = false;
		stopped = false;
		//playButton.label = "||";
		pauseButton.visible=true;
	    song.stop();
	    song = soundFactory.play(slider.value);
	}
	
	public function volume(vol:Number):void
	{
		try{
			soundTR.volume = vol;
			song.soundTransform = soundTR; 
		}catch(e:Error){};
	}
	
	public function formatearSlider(val:Number):String 
	{
		var df:DateFormatter = new DateFormatter();
		df.formatString = "NN:SS";
		var t:Date=new Date(val);
		//meter aqui un dateformater para que salga mm:ss   ///HECHO
		return df.format(t);
	}
	
	public function formatearVolumen(val:Number):String 
	{
		return Math.round(val)+ " %";
	}

	
    }
}