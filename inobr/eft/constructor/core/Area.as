package inobr.eft.constructor.core 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	import inobr.eft.common.ui.BlockFormat;
	
	/**
	 * ...
	 * @author Peter Gerasimenko, gpstmp@gmail.com
	 */
	public class Area extends Sprite 
	{
		protected var _rightOrder:Array = [];
		protected var _currentOrder:Array = [];
		protected var initialOrder:Array = [];
		protected var _margin:uint = 5;
		protected var _isSequenceImportant:Boolean = false;
		
		public function Area()
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		private function addedToStageHandler(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			for (var i:int = 0; i < _currentOrder.length; i++) 
			{
				//_currentOrder[i].build();
				parent.addChild(_currentOrder[i]);
			}
		}
		
		public function build():void 
		{
			for (var i:int = 0; i < initialOrder.length; i++) 
			{
				initialOrder[i].build();
				initialOrder[i].myArea = this;
				if (!insertDragObject(initialOrder[i]))
					throw new Error('Assert!!! Not enough space to place all DragObjects to the Area');
			}
		}
		
		public function destroy():void
		{
			for each (var dObject:Object in _currentOrder) 
			{
				dObject.destroy();
			}
		}
		
		public function reactToDragObject(dObject:Object):Boolean
		{
			throw new Error("You must override reactToDragObject() method!!!");
			return false;
		}
		
		public function stopReacting():void
		{
			
		}
		
		public function insertDragObject(dObject:Object):Boolean
		{
			throw new Error("You must override insertDragObject() method!!!");
			return false;
		}
		
		public function removeDragObject(dObject:Object):void
		{
			throw new Error("You must override removeDragObject() method!!!");
		}
		
		public function setInitialDragObjects(...rest):void
		{
			initialOrder = rest;
		}
		
		public function checkDragObject(dObject:Object):String
		{
			if (_rightOrder.indexOf(dObject) == -1)
				return ConstructorWorkspace.WRONG;
			else
				if (_isSequenceImportant)
					if (_rightOrder.indexOf(dObject) == _currentOrder.indexOf(dObject))
						return ConstructorWorkspace.RIGHT;
					else
						return ConstructorWorkspace.PARTLYRIGHT;
				else
					return ConstructorWorkspace.RIGHT;
		}
		
		public function checkCorrectness():Boolean
		{
			for (var i:int = 0; i < _currentOrder.length; i++) 
			{
				if (checkDragObject(_currentOrder[i]) != ConstructorWorkspace.RIGHT)
					return false;
			}
			
			return true;
		}
		
		public function set rightOrder(value:Array):void 
		{
			_rightOrder = value;
		}
		
		public function get margin():uint 
		{
			return _margin;
		}
		
		public function set margin(value:uint):void 
		{
			_margin = value;
		}
		
		public function set isSequenceImportant(value:Boolean):void 
		{
			_isSequenceImportant = value;
		}
	}

}