package  inobr.eft.constructor.core
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import inobr.eft.constructor.events.ConstructorEvents;
	import inobr.eft.common.lang.*;
	import inobr.eft.common.ui.NotificationWindow;
	import inobr.eft.common.lang.Lang;
	
	/**
	 * ...
	 * @author Peter Gerasimenko, gpstmp@gmail.com
	 */
	public class ConstructorWorkspace extends Sprite 
	{
		private var _myAreas:Array = [];
		private var _contactArea:Area = null;
		private var _topLevel:int;
		private static const MARGIN:int = 10;
		
		// help options
		private static var _rightHelpColor:uint = 0x00FF00;
		private static var _wrongHelpColor:uint = 0xFF0000;
		private static var _partlyRightHelpColor:uint = 0xFFCC00;
		public static const RIGHT:String = "right";
		public static const WRONG:String = "wrong";
		public static const PARTLYRIGHT:String = "partlyRight";
		private var _numberOfTries:uint = 2;
		private var _tryCount:uint = 0;
		private var _helpMode:Boolean = false;
		
		/**
		 * Creates workspace for the Constructor with fields and drag objects.
		 */
		public function ConstructorWorkspace(lang:Object) 
		{
			// add behaviour
			addEventListener(ConstructorEvents.OBJECT_IS_MOVING, objectMovingHandler);
			addEventListener(ConstructorEvents.OBJECT_PRESSED, objectPressedHandler);
			addEventListener(ConstructorEvents.DROP_OBJECT, dropObjectHandler);
			addEventListener(ConstructorEvents.CHECK, checkHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			Lang.Init(lang);
		}
		
		private function objectPressedHandler(event:Event):void 
		{
			var droppedObject:DragObject = event.target as DragObject;
			// show help
			if (_helpMode)
				droppedObject.showHelp(droppedObject.myArea.checkDragObject(droppedObject));
		}
		
		private function checkHandler(event:Event):void 
		{
			_tryCount++;
			
			for each (var item:Area in _myAreas) 
			{
				if(!item.checkCorrectness()) 
				{
					if (_tryCount <= _numberOfTries)
					{
						NotificationWindow.show(stage, T('ErrorWindowTitle'), T('WrongAnswer'), false);
						return;
					}
					else
					{
						NotificationWindow.show(stage, T('HelpWindowTitle'), T('HelpIsWorking'), false);
						_helpMode = true;
						return;
					}
				}
			}
			
			NotificationWindow.show(stage, T('SuccessWindowTitle'), T('RightAnswer'), true);
			for each (var area:Object in _myAreas) 
			{
				area.destroy();
			}
		}
		
		private function dropObjectHandler(event:Event):void 
		{
			var droppedObject:DragObject = event.target as DragObject;
			
			if (_contactArea)
			{
				if (!_contactArea.insertDragObject(droppedObject))
					droppedObject.returnToPreviousArea();
			}
			else
				droppedObject.returnToPreviousArea();
				
			// show help
			if (_helpMode)
				droppedObject.showHelp(droppedObject.myArea.checkDragObject(droppedObject));
		}
		
		private function objectMovingHandler(event:Event):void 
		{
			var dragObject:DragObject = event.target as DragObject;
			// find contact field
			
			for (var i:int = 0; i < _myAreas.length; i++) 
			{
				if (dragObject.hitTestObject(_myAreas[i]))
				{
					if (_contactArea && _contactArea != _myAreas[i])
						_contactArea.stopReacting();
					_contactArea = _myAreas[i];
					if (_contactArea != dragObject.previousArea)
						dragObject.previousArea.stopReacting();
					_contactArea.reactToDragObject(dragObject);
					break;
				}
				else
				{
					if (_contactArea)
					{
						_contactArea.stopReacting();
						dragObject.previousArea.reactToDragObject(dragObject);
					}
					_contactArea = null;
				}
			}
		}
		
		private function addedToStageHandler(event:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			placeAreas();
			
			// find the top object of workspace
			_topLevel = this.numChildren - 1;
			
			// add CheckButton in the right-bottom corner
			var checkButton:CheckButton = new CheckButton();
			checkButton.build();
			checkButton.x = stage.stageWidth - checkButton.width - MARGIN;
			checkButton.y = stage.stageHeight - checkButton.height - MARGIN;
			// add checkButton to vwctro workspace
			addChild(checkButton);
		}
		
		private function placeAreas():void 
		{
			for each (var item:Area in _myAreas) 
			{
				item.build();
				// in order to place all fields as deep as possible
				addChildAt(item, 0);
			}
		}
		
		/**
		 * Adds any field to the workspace. Use this method after 
		 * the field is configured.
		 * @param	area or array of areas
		 */
		public function addArea(...args):void
		{
			for (var i:int = 0; i < args.length; i++) 
			{
				_myAreas.push(args[i]);
			}
		}
		
		/**
		 * Specifies the color of help blinking for <b>partly right</b> answers
		 */
		static public function get partlyRightHelpColor():uint 
		{
			return _partlyRightHelpColor;
		}
		
		/**
		 * Specifies the color of help blinking for <b>partly right</b> answers
		 */
		static public function set partlyRightHelpColor(value:uint):void 
		{
			_partlyRightHelpColor = value;
		}
		
		/**
		 * Specifies the color of help blinking for <b>wrong</b> answers
		 */
		static public function get wrongHelpColor():uint 
		{
			return _wrongHelpColor;
		}
		
		/**
		 * Specifies the color of help blinking for <b>wrong</b> answers
		 */
		static public function set wrongHelpColor(value:uint):void 
		{
			_wrongHelpColor = value;
		}
		
		/**
		 * Specifies the color of help blinking for <b>right</b> answers
		 */
		static public function get rightHelpColor():uint 
		{
			return _rightHelpColor;
		}
		
		/**
		 * Specifies the color of help blinking for <b>right</b> answers
		 */
		static public function set rightHelpColor(value:uint):void 
		{
			_rightHelpColor = value;
		}
		
		/**
		 * Specifies the number of User's tries that would be made without help.
		 */
		public function set numberOfTries(value:uint):void 
		{
			_numberOfTries = value;
		}
	}

}