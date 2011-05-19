package au.media
{
	import au.searchers.DowintLink;
	import au.searchers.GoearDetails;
	import au.searchers.GoogleImages;
	import au.utils.DBManager;
	
	import mx.core.UIComponent;

	public class SongOLD extends UIComponent
	{
		public var songID:String;
		private var details:GoearDetails;
		public var link:String;
		
		[Bindable] public var artist:String;
		[Bindable] public var title:String;
		[Bindable] public var path:String;
		[Bindable] public var localPath:String;
		
		[Bindable] public var position:Number;
		[Bindable] public var length:Number;
		[Bindable] public var progress:Number;
		[Bindable] public var bytesLoaded:Number;
		[Bindable] public var bytesTotal:Number;
		[Bindable] public var time:String;
		[Bindable] public var totalTime:String;
		[Bindable] public var image:GoogleImages;
		
		private var dbmanager:DBManager;
		
		public function SongOLD(_id:String=null, item:Object=null)
		{
			super();
			if(_id) songID=_id;

			if(item){
				songID=item.songID;
				path=(item.path.indexOf(".") == 0)?"http://www.listengo.com/"+item.path : item.path;
				localPath=item.localPath;
				title=item.title;
				artist=item.artist;
				
				if(path.indexOf("goear") == -1){
					onResult(null);
				}
			}
			details = new GoearDetails(songID,link);
			details.addEventListener(SongEvent.RESULT,onResult);
			details.loadXML();
			position=0;
			length=0;
			image= new GoogleImages;
			
			dbmanager=new DBManager();
		}
				
		private function onResult(e:SongEvent):void
		{
			var evo:SongEvent= new SongEvent(SongEvent.COMPLETE);
			
			if(e.result.song[0].@path != "http://www.goear.com/files/sst5/mp3files/27042010/70cbb9136abe52c4cd6e4449a24a65bd.mp3")
				path=String(e.result.song[0].@path );
			artist=String(e.result.song[0].@artist);
			title=String(e.result.song[0].@title);
			trace(path);
			image.search(title+" "+artist);
			
			this.dispatchEvent(evo);
		}
		
		public function addToDB():void
		{
			var consulta:String  = "INSERT INTO Songs (songID, artist,title,path,localPath) VALUES('"+songID+"','"+artist+"','"+title+"','"+path+"','"+localPath+"')";
			
			dbmanager.conectar();
			dbmanager.hacerConsulta(consulta);
			
			var evo:SongEvent=new SongEvent(SongEvent.INSERT_SONG, songID);
			this.dispatchEvent(evo);
		}
		
		public function refreshLink():void
		{
			var dt:DowintLink= new DowintLink(link);
		}
		
	}
}