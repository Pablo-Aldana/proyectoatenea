package au.utils
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.*;
	
	import mx.collections.ArrayCollection;;

	public class LocalDB
	{
		private var _datosDB:ArrayCollection=new ArrayCollection();
		public function get datosDB():ArrayCollection{return _datosDB;}
		private var conexion:SQLConnection=new SQLConnection();
		
		public function LocalDB(archivo:String="BaseDeDatos.db")
		{
			conexion.addEventListener(SQLEvent.OPEN,
				function(event:SQLEvent):void
				{
					crearTabla("vars");
				});
			conexion.addEventListener(SQLErrorEvent.ERROR,
				function(event:SQLErrorEvent):void
				{
					trace("ERROR");
				});
			conexion.open(File.applicationStorageDirectory.resolvePath(archivo));
		}
		
		public function actualizar(tabla:String):void
		{
		    var consulta:String = "SELECT * FROM "+tabla; 
          	hacerConsulta(consulta,
                            function (e:Object):void
                            {
                               _datosDB = new ArrayCollection(e.data);
                            }  
          	);
		}
		
		public function insertar(tabla:String,o:Object):void
		{
			var consulta:String   =   "INSERT INTO "+ tabla ;
			var valores:Array=new Array();
			var campos:Array=new Array();
			var i:Number;

			//almacenamos los campos y valores
			for (var val:String in o)
			{
			    campos.push(val);
			    valores.push(o[val]);
			}
			
			//insertamos campos
			consulta += " (";
			for(i=0;i<campos.length-1;i++){
				consulta+=campos[i]+",";
			}
				consulta+=campos[i]+")";
				
			//insertamos valores
			consulta += " VALUES (";
			for(i=0;i<valores.length-1;i++){
				consulta+="'"+valores[i]+"',";
			}
				consulta+="'"+valores[i]+"')";
			
			//ejecutamos la consulta
			hacerConsulta(consulta,
				function (e:Object):void
				{
					actualizar(tabla);
				}  
			);
		}
		
		public function modificar(tabla:String,o:Object,criterio:Object):void
		{
           	var consulta:String   =   "UPDATE "+tabla+" SET ";
			var valores:Array=new Array();
			var campos:Array=new Array();
			var i:Number;

			//almacenamos los campos y valores
			for (var val:String in o)
			{
			    campos.push(val);
			    valores.push(o[val]);
			 }
			
			//insertamos campos y valores
			for(i=0;i<campos.length-1;i++){
            	consulta+=campos[i]+" = '"+valores[i]+ "', " ;
			}
            	consulta+=campos[i]+" = '"+valores[i]+ "' " ;
            	i++;
            for (val in criterio)
				consulta+=" WHERE "+val+" = "+criterio[val];
					
			//ejecutamos la consulta   
			hacerConsulta(consulta,
				function (e:Object):void
				{
					actualizar(tabla);
				}  
			);   
		}
		
		public function eliminar(tabla:String,campo:String,valor:String):void
		{
			var   consulta:String   =   "DELETE FROM "+tabla+" WHERE "+campo+" = "+valor;
			hacerConsulta(consulta,
				function (e:Object):void
				{
					actualizar(tabla);
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
			
			var consulta:String  = "CREATE TABLE IF NOT EXISTS "+nombre+"(";
			consulta+="id INTEGER PRIMARY KEY AUTOINCREMENT,";
			consulta+="nombre TEXT,"; 
			consulta+="valor TEXT"; //atencion que no tenga coma!!
			consulta+=")";
			                         
			//ejecutamos la consulta   
			hacerConsulta(consulta);
			
		}
		
	}
}