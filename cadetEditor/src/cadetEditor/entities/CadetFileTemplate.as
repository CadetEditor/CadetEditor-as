// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor.entities
{
	import cadetEditor.assets.CadetEditorIcons;
	
	import core.app.entities.URI;

	public class CadetFileTemplate
	{
		public var label		:String;
		public var description	:String;
		public var url			:String;
		public var icon		:Class = CadetEditorIcons.CadetEditor;
		
		public function CadetFileTemplate()
		{
			
		}
		
		public function deserialise(xml:XML):void
		{
			label = String(xml.label[0].text());
			description = String(xml.description[0].text());
			url = String(xml.url[0].text());
		}
	}
}