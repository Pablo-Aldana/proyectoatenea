package au.singleton
{
	//necesita un php que devuelva 'version','path' del nuevo archivo y 'build' de la nueva version
	/*ejemplo:
	<?php
		
		$output= "version=0.2 Beta";
		$output.= "&build=101010";
		$output.= "&path=http://www.agrotecextremadura.com/aureum/apps/atenea/Atenea.air;
		$output.= "&features=multiples mejoras";
		echo $output;
		
	?>
	*/	
	
	import flash.desktop.NativeApplication;
	import flash.desktop.Updater;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	import mx.core.UIComponent;
	
	[Bindable]
	public class Actualicer extends UIComponent
	{
		private static var _instance:Actualicer;
		
		//posibilidad de recibir esta ruta dinamicamente (mayor reusabilidad de la clase)
		public var versionURL:String = "http://www.cebrianrico.es/atenea/versions.php"; 

		public var newVersion:String;
		public var features:String;
		public var xmlFile:String;
		
		private var newBuild:String;
		private var actualVersion:String;
		private var actualBuild:String;
		private var airURL:String;
		
		private var airRequest:URLRequest;
		private var stream:URLStream;
		private var fileData:ByteArray;
		
		public static function get instance():Actualicer //devuelve la instancia de la clase estatica 
		{
			if (_instance == null)
			{
				_instance = new Actualicer();
			}
			return _instance;
		}
				
		public function check():void	//descarga el archivo de información sobre nuevas versiones 
		{
			var scriptRequest:URLRequest = new URLRequest(versionURL);
			var scriptLoader:URLLoader = new URLLoader();
			var scriptVars:URLVariables = new URLVariables();
					
			scriptLoader.addEventListener(Event.COMPLETE, onComplete);
			scriptLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
				
			scriptRequest.method = "POST";
			scriptRequest.data = scriptVars;
			scriptLoader.load(scriptRequest);
		}
		
		private function onComplete(e:Event):void	//compara la version actual con la ultima del servidor 
		{
			var appDescriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appDescriptor.namespace();
			var vars:URLVariables = new URLVariables(e.target.data);
			
			this.newVersion=unescape(vars.version);		//nombre de la nueva version
			this.newBuild=unescape(vars.build);			//nº de build nueva
			this.airURL=unescape(vars.path);			//ruta del .air a instalar
			this.features=unescape(vars.features);		//nuevas funcionalidades
			this.xmlFile=unescape(vars.xmlfile);		//archivo de detalles
			this.actualVersion=appDescriptor.ns::version;
			
			
			if(Number(actualVersion.split(':')[1]) < Number(newBuild))
				showNotice();
		}
		
		private function showNotice():void	//muestra un aviso si existe nueva version 
		{
			var evo:Event=new Event("NEW_VERSION");
			this.dispatchEvent(evo);
		}
		
		public function update():void	//comienza la descargar del .air 
		{	
			airRequest = new URLRequest(airURL); 
			stream = new URLStream(); 
			fileData = new ByteArray();
			stream.addEventListener(Event.COMPLETE, onLoad); 
			stream.load(airRequest);
		}
			 
		private function onLoad(e:Event):void	//copia el archivo descargado a disco 
		{		
		    stream.readBytes(fileData, 0, stream.bytesAvailable);
		    var file:File = File.applicationStorageDirectory.resolvePath("newVersion.air"); 
			var fileStream:FileStream = new FileStream(); 
			fileStream.open(file, FileMode.WRITE); 
			fileStream.writeBytes(fileData, 0, fileData.length); 
			fileStream.close();

		    install(); //una vez copiado procedemos a instalar
		}
					 
		private	function install():void		//instalamos la nueva versión 
		{	
			var updater:Updater = new Updater();
			var airFile:File = File.applicationStorageDirectory.resolvePath("newVersion.air");
			updater.update(airFile, this.newVersion);
		}
		
		private function onError(e:IOErrorEvent):void //manejador del errores en chek() 
		{
			trace(e.toString());
		}
	}
}