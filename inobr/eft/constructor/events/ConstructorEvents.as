package inobr.eft.constructor.events 
{
	/**
	 * Events of Constructor workspace.
	 * @author Peter Gerasimenko, gpstmp@gmail.com
	 */
	public class ConstructorEvents 
	{
		/**
		 * This event dispathes while the User is starting to drag a DragObject.
		 */
		public static const OBJECT_PRESSED:String = "objectPressed";
		
		/**
		 * This event dispathes while the User is dragging a DragObject.
		 */
		public static const OBJECT_IS_MOVING:String = "objectIsMoving";
		
		/**
		 * This event dispathes while the User dropes DragObject into a Field.
		 */
		public static const DROP_OBJECT:String = "dropObject";
		
		/**
		 * This event dispathes while the User clicks the CheckButton.
		 */
		public static const CHECK:String = "check";
	}

}