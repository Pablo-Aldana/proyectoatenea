// ActionScript file
import au.media.Playlist;
import au.media.Song;
import au.media.SongEvent;
import au.searchers.SearchEvent;
import au.singleton.*;
import au.utils.LocalDB;

import custom.*;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.*;

import mx.collections.ArrayCollection;
import mx.controls.tabBarClasses.*;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;

import object.*;

import spark.components.WindowedApplication;

private var pagina:Number;
private var link1:URLRequest;
private var continuar:Boolean;
private var pos:Number=0;
public var db:LocalDB;
[Bindable] private var directory:File = File.desktopDirectory;
[Bindable] public var misDescargas:String;


//cosas buenas

public function init():void
{
	try{
		//HACER LOS DELETE CASCADE CON CROSS JOIN CHAPUCILLAS PARA LISTAS Y CANCIONES
		//CANCIONES -> SELECT DISTINCT canciones.* FROM listas_canciones CROSS JOIN canciones ON(c.id=lc.id) INTO canciones;
		//LISTAS -> SELECT DISTINCT listas.* FROM listas CROSS JOIN listas_canciones ON(l.id=lc.id) INTO listas;
		db=new LocalDB("atenea.adb");
	}
	catch (error:Error)	{
		trace("fallo:", error.message);
	}
	
	//inicializando variables
		
	var o:Object=new Object;	
	db.actualizar("vars");
	if(db.datosDB.length<1){
		trace("nada");
		o.nombre="misDescargas";
		o.valor=directory.nativePath;
		db.insertar("vars",o);
	}else{
		try{
			directory.nativePath = db.datosDB[0].valor;
		}catch(e:Error){};
	}
	misDescargas=directory.nativePath;
	
	//cosas buenas
	//añadimos un eventListener y chekeamos versión
	Actualicer.instance.addEventListener("NEW_VERSION",onNewVersion);
	Actualicer.instance.check();
	playlist.init();
	downloads.init();
	
	//esto se necesita pero probablemten habrá q modificarlo
	address.search.addEventListener(FlexEvent.ENTER, onSearch);
	address.search.addEventListener(Event.CHANGE,function f2(e:Event):void{
		search.searcher.stop();
	});
	
	//eventos asociados al searcher
	search.addEventListener(SearchEvent.START,onStart);
	search.addEventListener(SearchEvent.STOP,onStop);
	search.addEventListener(SongEvent.DOWNLOAD,onDownload);
	search.addEventListener(SongEvent.PLAY,onPlay);
	search.addEventListener(SongEvent.TOLIST,onToList);
	
	//eventos asociados a playlist
	playlist.addEventListener(SongEvent.DOWNLOAD,onDownload);
	
	
}

public function onSearch(e:Event):void
{
	search.searcher.search(address.search.text);
	sections.selectedChild=search;
}

public function onNewVersion(e:Event):void //CLASE actualizar
{
	var ventana:actualizarScreen;
	ventana=actualizarScreen(PopUpManager.createPopUp( this, actualizarScreen , true));
}

public function onStart(e:SearchEvent):void
{
	loading.visible=true;
}

public function onStop(e:SearchEvent):void
{
	loading.visible=false;
}

public function onDownload(e:SongEvent):void
{
	downloads.addDownload(Song(e.result));
	sections.selectedChild=downloads;
}

public function onPlay(e:SongEvent):void
{
	if (playlist.listas) playlist.listas.selectedIndex=0;
	onToList(e);
	Player.instance.selectPlaylist(playlist.lists[0]);
	var s:Song=Song(e.result);
	Player.instance.play(s);
}

public function onToList(e:SongEvent, p:Playlist=null):void
{
	var s:Song=Song(e.result);
	if(!p){
		if(playlist.lists[0].getItemIndex(s) ==-1)
			playlist.lists[0].addItem(s);
	}else{
		p.addSong(s);
	}
}

public function mouseD(e:MouseEvent):void //evita que al seleccionar la 
{
	e.stopPropagation();
}

private function onError(event:FaultEvent):void
{
	//Alert.show(event.fault.faultString,"Problema de conexion");
	loading.visible=false;
}

private function errorVacio(event:FaultEvent):void
{
	
}

private function verSplash():void
{
	var ventana:acercaDeScreen;
	ventana=acercaDeScreen(PopUpManager.createPopUp( this, acercaDeScreen , true));
}

public function setMisDescargas():void //CLASE gestor
{
	try{
		directory.browseForDirectory("Selecciona directorio de descarga");
		directory.addEventListener(Event.SELECT, function f(e:Event):void{
			directory = e.target as File;
			misDescargas = directory.nativePath;
			db.hacerConsulta("UPDATE vars SET valor='"+directory.nativePath+"' WHERE nombre='misDescargas'");
			db.actualizar("vars");
		});
	}
	catch (error:Error)	{
		trace("fallo:", error.message);
	}
} 

public function getURL(url:String,metodo:String="_blank"):void //CLASE gestor
{
	var request:URLRequest = new URLRequest(url);
	try {            
		navigateToURL(request,metodo);
	}
	catch (e:Error) {
		// handle error here
	}
}

public function initTab():void
{
	var tab:Tab;
	var idx:uint;
	var len:uint = sections.numChildren;
	for (idx=0; idx<len; idx++) {
		tab = sections.getTabAt(idx) as Tab;
		tab.labelPlacement = "bottom";
	}
	
}