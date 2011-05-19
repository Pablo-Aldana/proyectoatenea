package au.utils
{
	import au.media.Playlist;
	
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.*;
	
	import mx.collections.ArrayCollection;
		
	public class PlaylistDB
	{
		private var _datosDB:ArrayCollection=new ArrayCollection();
		public function get datosDB():ArrayCollection{return _datosDB;}
		private var conexion:SQLConnection=new SQLConnection();
		private var lastInsert:Playlist;
		
		public function PlaylistDB(archivo:String="atenea.adb")
		{
			conexion.addEventListener(SQLEvent.OPEN,
				function(event:SQLEvent):void
				{
					trace("conectado");
					crearTabla("Playlists");
				});
			conexion.addEventListener(SQLErrorEvent.ERROR,
				function(event:SQLErrorEvent):void
				{
					trace("ERROR");
				});
			conexion.open(File.applicationStorageDirectory.resolvePath(archivo));
		}
		
		public function actualizar():void
		{
			var tabla:String="Playlists";
		    var consulta:String = "SELECT * FROM "+tabla; 
          	hacerConsulta(consulta,
                            function (e:Object):void
                            {
                               _datosDB = new ArrayCollection(e.data);
                               for(var i:Number=0;i<_datosDB.length;i++)
                               	 _datosDB[i] = new Playlist(_datosDB.getItemAt(i));
                               	 if(lastInsert)
                               	 {
                               	 	lastInsert.id=_datosDB.getItemAt(_datosDB.length-1).id;
                               	 	lastInsert=null;
                               	 }
                            }  
          	);
		}
		
		public function insertar(o:Object):void
		{
			var consulta:String   =   "INSERT INTO Playlists (name) VALUES ('"+o.name+"')" ;
			lastInsert=Playlist(o);
			
			//ejecutamos la consulta
			hacerConsulta(consulta,
				function (e:Object):void
				{
					actualizar();
				}  
			);
		}
		
		public function modificar(o:Object):void
		{
           	var consulta:String   =   "UPDATE Playlists SET name='"+o.name+"' WHERE id="+o.id;
					
			//ejecutamos la consulta   
			hacerConsulta(consulta,
				function (e:Object):void
				{
					actualizar();
				}  
			);   
		}
		
		public function eliminar(o:Playlist):void
		{
			var   consulta:String   =   "DELETE FROM Playlists WHERE id = "+o.id;
			hacerConsulta(consulta,
				function (e:Object):void
				{
					actualizar();
				}  
			);   
		}
		
		public function hacerConsulta(consulta:String,f:Function = null):void
		{
			var sql:SQLStatement= new SQLStatement();
			sql.sqlConnection= conexion;         
			sql.text= consulta;
			         
			sql.addEventListener(SQLEvent.RESULT,
				function (e:SQLEvent):void
				{
					trace("conseguido");
					if(f != null)
					{
						f(e.target.getResult());                     
					}
				});
			sql.addEventListener(SQLErrorEvent.ERROR,
				function (e:SQLErrorEvent):void
				{
					trace("va a ser q no");
				});
			sql.execute();
		}
		
		
		//este metodo crea las tablas estaticamente
		public function crearTabla(nombre:String):void
		{
			trace("creando tablas");
			
			var consulta:String  = "CREATE TABLE IF NOT EXISTS "+nombre+"(";
			consulta+="id INTEGER PRIMARY KEY AUTOINCREMENT,";
			consulta+="name TEXT"; 
			consulta+=")";
			                         
			//ejecutamos la consulta   
			hacerConsulta(consulta);
			
		}
		

	}
}