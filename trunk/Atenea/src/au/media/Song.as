package au.media
{
	import au.searchers.GoearDetails;
	import au.searchers.GoogleImages;
	import au.searchers.ListenGoSearch;
	import au.searchers.mp3000Details;
	import au.utils.DBManager;
	
	import flash.utils.*;
	
	import mx.core.UIComponent;

	public class Song extends UIComponent
	{
		public var songID:String;
		private var intervalId:uint;
		
		[Bindable] public var artist:String;
		[Bindable] public var title:String;
		[Bindable] public var _path:String;
		[Bindable] public var localPath:String;
		[Bindable] public var host:String;
		[Bindable] public var referer:String;
		[Bindable] public var server:String;
		[Bindable] public var detailslink:String;
		
		[Bindable] public var position:Number;
		[Bindable] public var length:Number;
		[Bindable] public var progress:Number;
		[Bindable] public var bytesLoaded:Number;
		[Bindable] public var bytesTotal:Number;
		[Bindable] public var time:String;
		[Bindable] public var totalTime:String;
		[Bindable] public var image:GoogleImages;
		
		private var dbmanager:DBManager;
		
		
		public function Song(_id:String=null, item:Object=null)
		{
			super();
			image= new GoogleImages;
			//dbmanager=new DBManager();
			//dbmanager.conectar(); //temporalmente descativamos la base de datos
			
			
			if(_id) songID=_id;
						
				//onResult(null);
			
			if(item){
				songID=item.songID;
				_path=item.path;
				localPath=item.localPath;
				title=item.title;
				artist=item.artist;
				host=item.host;
				referer=item.referer;
				//image.search(title+" "+artist);
								
				onResult(null);
			}
			position=0;
			length=0;
		}
		
		public function get path():String
		{
			if (!_path)
			{
				details();
			}
			
				return _path;
		}
		
		public function set path(p:String):void
		{
			_path=p;
		}
				
		private function onResult(e:SongEvent):void
		{
			var evo:SongEvent= new SongEvent(SongEvent.DETAILS);
			
			if(server=="goear")
			{
				_path=String(e.result.song[0].@path);
				if (_path=="http://www.goear.com/files/sst5/mp3files/27042010/70cbb9136abe52c4cd6e4449a24a65bd.mp3")
				{
					trace("mala"+songID);
					intervalId = setInterval(details, 2000);
				}else
				{
					artist=String(e.result.song[0].@artist);
					title=String(e.result.song[0].@title);
					this.dispatchEvent(evo);
				}
			}else if(server=="mp3000"){
				_path=e.result.link;
				referer=e.result.referer;
			
			}
			
		}
		
		public function addToDB():void
		{
			var consulta:String  = "INSERT INTO Songs (songID, artist,title,path,localPath) VALUES('"+songID+"','"+artist+"','"+title+"','"+path+"','"+localPath+"')";
		
			dbmanager.hacerConsulta(consulta);
			
			var evo:SongEvent=new SongEvent(SongEvent.INSERT_SONG, songID);
			this.dispatchEvent(evo);
		}
		
		public function details():void
		{
			if (server=="goear")
			{
				trace("detalleando"+songID);
				var details:GoearDetails;
				details = new GoearDetails(songID,referer);
				details.addEventListener(SongEvent.RESULT,onResult);
				details.send();
				clearInterval(intervalId);
			}else if (server=="mp3000")
			{
				
				var detailsmp3000:mp3000Details;
				detailsmp3000 = new mp3000Details(songID,detailslink,referer);
				detailsmp3000.addEventListener(SongEvent.RESULT,onResult);
				detailsmp3000.send();
				
			}
		}
		
	}
}