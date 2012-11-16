// Copyright (c) 2012, Unwrong Ltd. http://www.unwrong.com
// All rights reserved. 

package cadetEditor3D.tools.gizmos
{
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	
	public class GizmoBase extends Mesh
	{
		public function GizmoBase()
		{
			
		}
		
		public function getClosestActiveEntity( entities:Vector.<Entity> ):Entity
		{
			return null;
		}
		
		public function updateRollOvers( entities:Vector.<Entity> ):Boolean
		{
			return false;
		}
	}
}