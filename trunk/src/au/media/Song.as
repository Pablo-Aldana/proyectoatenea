package au.media
{
	import au.searchers.GoearDetails;
	import au.searchers.GoogleImages;
	import au.searchers.ListenGoSearch;
	import au.utils.DBManager;
	
	import mx.core.UIComponent;

	public class Song extends UIComponent
	{
		public var songID:String;
		private var details:GoearDetails;
		
		[Bindable] public var artist:String;
		[Bindable] public var title:String;
		[Bindable] public var path:String;
		[Bindable] public var localPath:String;
		[Bindable] public var host:String;
		[Bindable] public var referer:String;
		
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
			dbmanager=new DBManager();
			dbmanager.conectar();
			
			
			if(_id) songID=_id;
						
				onResult(null);
			
			if(item){
				songID=item.songID;
				path=item.path;
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
				
		private function onResult(e:SongEvent):void
		{
			var evo:SongEvent= new SongEvent(SongEvent.COMPLETE);
			
			//path=String(e.result.song[0].@path);
			//artist=String(e.result.song[0].@artist);
			//title=String(e.result.song[0].@title);
			if(title){
				//image.search(title+" "+artist);
				this.dispatchEvent(evo);
			}
		}
		
		public function addToDB():void
		{
			var consulta:String  = "INSERT INTO Songs (songID, artist,title,path,localPath) VALUES('"+songID+"','"+artist+"','"+title+"','"+path+"','"+localPath+"')";
		
			dbmanager.hacerConsulta(consulta);
			
			var evo:SongEvent=new SongEvent(SongEvent.INSERT_SONG, songID);
			this.dispatchEvent(evo);
		}
		
	}
}