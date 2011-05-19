package au.media
{
	import au.singleton.Player;
	import au.utils.DBManager;
	
	import mx.collections.ArrayCollection;

	public class Playlist extends ArrayCollection
	{
		[Bindable] public var current:Song;
		public var _name:String;
		public var id:Number;
		private var dbmanager:DBManager;
		
		public function Playlist(item:Object=null, $name:String=null)
		{
			super(null);
			
			dbmanager=new DBManager();
			dbmanager.conectar();
			dbmanager.addEventListener(SongEvent.INSERT_PLAYLIST, getId);
			
			if(item){
				_name=item.name;
				id=item.id;
			}
			
			if($name){
				_name=$name;
				//INSERTAR HAY QUE HACERLO AQUí, SINO CONFUNDE LOS EVENT LISTENERS
				this.createList();
			}
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function set name($name:String):void
		{
			_name=$name;
			if(id){
				var consulta:String  = "UPDATE Playlists SET name='"+_name+"' WHERE id="+id;
				dbmanager.hacerConsulta(consulta);
			}
		}
		
		public function createList():void
		{
			var consulta:String  = "INSERT INTO Playlists (name) VALUES ('"+_name+"')";
			dbmanager.hacerConsulta(consulta);
		}
		
		private function getId(e:SongEvent):void
		{
			id=Number(e.result);
		}
		
		public function delList():void
		{
			var consulta:String  = "DELETE FROM Playlists WHERE id="+id;
			dbmanager.hacerConsulta(consulta);
			delete this;
		}
		
		public function addSong(song:Song):void
		{
			if(this.getItemIndex(song) ==-1){ //Si esto no es suficiente para cuando las cancioens vuelvan de la bbdd controlamos por el songID
				///AÑADIR RELACION
				song.addEventListener(SongEvent.INSERT_SONG, relateSong);
				//AÑADIR CANCION
				song.addToDB();
				///
				this.addItem(song);
			}
		}
		
		private function relateSong(e:SongEvent):void
		{
			var consulta:String  = "INSERT INTO playlists_songs (idPlaylist,idSong) VALUES ('"+id+"','"+e.result+"')";
			dbmanager.hacerConsulta(consulta);
		}
		
		public function delSong(song:Song):void
		{
			
			var consulta:String  = "DELETE FROM playlists_songs WHERE idPlaylist='"+id+"' AND idSong='"+song.songID+"';";
			dbmanager.hacerConsulta(consulta);
			this.removeItemAt(this.getItemIndex(song));
		}
		
		
		public function next():Song
		{
			var index:Number=this.getItemIndex(current);
			
			index++;
			    if (index >= this.length) { 
			        index = 0; 
			    }
			return Song(this.getItemAt(index));
			
		}
		
		public function prev():Song
		{
			var index:Number=this.getItemIndex(current);
			
			index--;
			    if (index < 0) { 
			        index = this.length - 1; 
			    }
			    
			return Song(this.getItemAt(index));
			
		}
			
		public function selectSong(song:Song):void
		{
			Player.instance.selectPlaylist(this);
			Player.instance.play(song);			
		}
		
	}
}