package cadetEditor.util
{
	public class UserDataUtil
	{
		static public function copyUserData( userData:Object ):Object
		{
			var obj:Object = new Object();
			
			for ( var prop:String in userData ) {
				obj[prop] = userData[prop];
			}
			
			return obj;
		}
	}
}