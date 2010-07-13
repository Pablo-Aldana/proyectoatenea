package au.utils
{		
	import au.media.SongEvent;
	
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.*;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	
	public class DBManager extends UIComponent
	{
		
		private var _datosDB:ArrayCollection=new ArrayCollection();
		public function get datosDB():ArrayCollection{return _datosDB;}
		private var conexion:SQLConnection=new SQLConnection();
		
		public  function DBManager()
		{
			super();
		}
		
		public function conectar(archivo:String="atenea.adb"):void
		{
			conexion.addEventListener(SQLEvent.OPEN,
				function(event:SQLEvent):void
				{
					trace("conectado a la bbdd");
				});
			conexion.addEventListener(SQLErrorEvent.ERROR,
				function(event:SQLErrorEvent):void
				{
					trace("ERROR");
				});
			conexion.open(File.applicationStorageDirectory.resolvePath(archivo));
		}
		
		public function actualizar(tabla:String, orderField:String=null):ArrayCollection
		{
			var consulta:String = "SELECT * FROM "+tabla; 
			if(orderField)consulta+=" ORDER BY "+orderField;
          	hacerConsulta(consulta,
                            function (e:Object):void
                            {
                               _datosDB = new ArrayCollection(e.data);
                            }  
          	);
          	return _datosDB;
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
					if(consulta.indexOf("INSERT INTO Playlists")!=-1){
						var evo:SongEvent=new SongEvent(SongEvent.INSERT_PLAYLIST, e.target.sqlConnection.lastInsertRowID);
						dispatchEvent(evo);
					}
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
			try{	
				sql.execute();
			}catch(e:Error){};
		}		

	}
}