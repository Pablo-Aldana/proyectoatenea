package object
{
	import au.media.Song;
	import au.media.SongEvent;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.*;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.controls.Button;
	import mx.core.UIComponent;
	import mx.events.*;
		
	public class Descargar extends UIComponent
	{
		
		public var item:Song;
		public var nombre:String;
		[Bindable] public var porcentaje:String;
		[Bindable] public var restante:String;
		[Bindable] public var completado:String;
		[Bindable] public var velocidad:String;
		public var urlStream:URLStream;
		[Bindable] public var pe:ProgressEvent;
		private var tiempoi:Date; //tiempo inicio de de la descarga activa
		private var tiempoc:Date; // tiempo de creacion de la descarga activa
		private var bytesTotal:Number;
		private var bytesLoaded:Number;
		private var bytesSaves:Number;
		private var link:URLRequest;
		private var directorio:File;
		private var minuteTimer:Timer;
		
		public function Descargar(_item:Song,_directorio:File):void
		{
			item=_item;
			directorio=_directorio;
			tiempoi=new Date();
			tiempoc=new Date();
			item.progress=0;
			bytesLoaded=0;
			bytesTotal=0;
			bytesSaves=0;
			porcentaje="0 %";
			urlStream = new URLStream(); 
			urlStream.addEventListener(ProgressEvent.PROGRESS, progresar);
			urlStream.addEventListener(Event.COMPLETE, finalizar);
			
			minuteTimer = new Timer(1000, 0);
            
            // designates listeners for the interval and completion events
            minuteTimer.addEventListener(TimerEvent.TIMER, compara);
	        minuteTimer.start();
			
			restante="Iniciando..."
			
			//pedimos detalles
			_item.addEventListener(SongEvent.DETAILS,onPath);
			if(item.path){
				item.path=item.path.replace('"', '');
				link= new URLRequest(item.path);
				descarga();
			}
				
            
		}
		
		private function onPath(e:SongEvent):void
		{
				item.path=item.path.replace('"', '');
				link= new URLRequest(item.path);
				descarga();
		}
				
		public function descarga():void
		{
			
			if (!link)
				return;
			
			nombre=item.artist+" - "+item.title;
				
			var header:URLRequestHeader = new URLRequestHeader("Referer",item.referer);
			link.requestHeaders.push(header);
			link.userAgent="Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; InfoPath.2; Tablet PC 2.0)";
		   
				try{
					urlStream.load(link);
				}catch(e:Error){};
				
		}
		
		public function pausa(but:Button):void
		{
			if(restante!="completado"){
			
				if(urlStream.connected){
					but.label="Play";
					urlStream.close();
					minuteTimer.stop();
					restante="Pausado";
					
				}
				else {
					restante="Iniciando...";
					try{
						but.label="Pause";
						bytesSaves=bytesLoaded;
						tiempoi=new Date;
						minuteTimer.start();
						urlStream.load(link);
					}catch(e:Error){};
				}
				
			}
		}
		
		private function progresar(e:ProgressEvent):void
		{
			pe=e;
			item.progress=Math.round((e.bytesLoaded/e.bytesTotal)*1000)/10;
			porcentaje=item.progress+" %";
			bytesTotal=e.bytesTotal;
			bytesLoaded=e.bytesLoaded;
			
			if(Number(e.bytesLoaded) >1048000){
				completado=(Math.round(Number(e.bytesLoaded/104800))/10).toString()+" Mb /  ";
			}else{
				completado=(Math.round(Number(e.bytesLoaded/102))/10).toString()+" Kb /  ";
			}
			completado +=(Math.round(Number(e.bytesTotal/104800))/10).toString()+" Mb ";
		
		}
		
		private function compara(e:TimerEvent):void
		{
			var tiempom:Date=new Date();
			var tiempor:Date;
			
			if(bytesLoaded>0){
				velocidad=String( Math.round( ( (bytesLoaded-bytesSaves)/102.4) / (tiempom.time/1000 - tiempoi.time/1000 ) ) / 10 );
				tiempor=new Date(null,null,null,null,null, Math.round( ( (bytesTotal-bytesLoaded) / 1024 ) / Number(velocidad) ) );
				restante= tiempor.getMinutes().toString()+"m "+tiempor.getSeconds().toString()+"s";
			}
		}
		
		private function finalizar(e:Event):void
		{
			//Guardamos el instalable en binario en el escritorio 
			var instalableBinario:ByteArray = new ByteArray();  
			urlStream.readBytes(instalableBinario, 0, urlStream.bytesAvailable);
			//bprogreso.label=nombrearc;
		
			directorio = directorio.resolvePath(nombre+".mp3");
			
			// Escritura del archivo 
			var fileStream:FileStream = new FileStream();
			fileStream.addEventListener(Event.COMPLETE, escrito);
			try{
				fileStream.open(directorio, FileMode.WRITE);
				fileStream.writeBytes(instalableBinario); 
			}catch(e:Error){
				//error de escritura aki
			}
			
			var tiempom:Date=new Date();
			var tiempot:Date=new Date(null,null,null,null,null, Math.round( (tiempom.time/1000 - tiempoc.time/1000 ) ) );
			minuteTimer.stop();
			restante="Completado en "+tiempot.getMinutes().toString()+"m "+tiempot.getSeconds().toString()+"s";; 
		}
		
		private function escrito(e:Event):void{
			//cerramos la conexion
			e.target.close();
		}

	}
	
}