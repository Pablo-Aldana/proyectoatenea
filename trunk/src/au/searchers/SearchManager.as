package au.searchers
{
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	
	public class SearchManager extends UIComponent
	{
		private var searchers:Array;
		private var length:Number;
		private var results:ArrayCollection;
		private var userAgent:String;
		private var key:String;
		private var searching:Number;
		
		public function SearchManager(_results:ArrayCollection)
		{
			super();
			
			userAgent="Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; InfoPath.2; Tablet PC 2.0)";
			results=_results;
			
			searchers=new Array();
			
			searchers.push( new eMp3WorldSearcher(results,userAgent) );
			searchers.push( new GoearSearch(results,userAgent) );
			searchers.push( new audioDumpSearcher(results,userAgent) );
			
			length=searchers.length;
			
			for(var i:Number=0;i<length;i++)
			{
				searchers[i].addEventListener(SearchEvent.START,onStart);
				searchers[i].addEventListener(SearchEvent.STOP,onStop);
			}
			
				/**
				 
				 dilandau =  new DilandauSearch(results);
				/**/
			
		}
		
		public function search(_key:String):void
		{
		/*	page=0;
			again=true; 
		*/	
			key=_key;
			searching=0;
			results.removeAll();
			
			if(key.length>0){
				for(var i:Number=0;i<length;i++)
				{
					searchers[i].search(key);
					
				}	
				this.dispatchEvent(new SearchEvent(SearchEvent.START));
			}
			
		}
		
		public function stop():void
		{
			this.dispatchEvent(new SearchEvent(SearchEvent.STOP));
		}
		
		private function onStart(e:SearchEvent):void
		{
			searching++;
		}
		
		private function onStop(e:SearchEvent):void
		{
			searching--;
			if (searching<1)
				stop();
		}
	}
}