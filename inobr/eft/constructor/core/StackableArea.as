package inobr.eft.constructor.core 
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import inobr.eft.common.ui.BlockFormat;
	/**
	 * ...
	 * @author Peter Gerasimenko, gpstmp@gmail.com
	 */
	public class StackableArea extends Area 
	{
		private var areaWidth:int;
		private var areaHeight:int;
		private var centralPoints:Array = [];
		private var _format:BlockFormat = new BlockFormat();
		private var conflictPoints:Dictionary = new Dictionary();
		private var stubObject:StubObject = null;
		
		public function StackableArea(x:int, y:int, width:int, height:int)
		{
			areaWidth = width;
			areaHeight = height;
			
			this.x = x;
			this.y = y;
			
			super();
		}
		
		/*---- API methods ----*/
		
		override public function build():void
		{
			addChild(drawBack());
			super.build();
		}
		
		override public function reactToDragObject(dObject:Object):Boolean
		{
			if (!stubObject)
				insertStubObject(dObject, _currentOrder.length);
			// if there is no space for object we send it back to previousArea	
			try {
				calculatePositions(_currentOrder);
			}
			catch (error:Error) {
				stopReacting();
				return (dObject as DragObject).previousArea.reactToDragObject(dObject);
			}
				
			var mousePosition:Point = localToGlobal(new Point(mouseX, mouseY));
				
			for each (var conflictObject:Object in _currentOrder) 
			{
				if (conflictObject is DragObject && (conflictObject as DisplayObject).hitTestPoint(mousePosition.x, mousePosition.y))
				{
					var direction:String = _currentOrder.indexOf(stubObject) > _currentOrder.indexOf(conflictObject) ?
						"right" : "left";
						
					// check for two special cases:
					// 1) size of dObject and conflict object
					if (!isConflictResolvable(dObject, conflictObject, mousePosition, direction))
						return false;
					// 2) if conflic doesnt couse another conflict
					if (willBeAnotherConflict(conflictObject, mousePosition))
						return false;
						
					var stubIndex:int = _currentOrder.indexOf(conflictObject);
					
					if (_currentOrder.indexOf(stubObject) != -1)
						_currentOrder.splice(_currentOrder.indexOf(stubObject), 1);
					_currentOrder.splice(stubIndex, 0, stubObject);
					
					return placeObjects(_currentOrder);
				}
			}
			
			// if dObject doesnt hit anything we put stubObject to the end od stack
			if (!(dObject as DisplayObject).hitTestObject(stubObject))
			{
				_currentOrder.splice(_currentOrder.indexOf(stubObject), 1);
				_currentOrder.push(stubObject);
				return placeObjects(_currentOrder);
			}
			
			return false;
		}
		
		override public function stopReacting():void
		{
			if (stubObject)
			{
				if (_currentOrder.indexOf(stubObject) != -1)
					_currentOrder.splice(_currentOrder.indexOf(stubObject), 1);
				parent.removeChild(stubObject);
				stubObject = null;
				
				placeObjects(_currentOrder);
			}
		}
		
		override public function insertDragObject(dObject:Object):Boolean
		{
			var index:int = _currentOrder.indexOf(stubObject);
			
			if (index == -1)
				_currentOrder.push(dObject);
			else
			{
				_currentOrder.splice(index, 1, dObject);
				parent.removeChild(stubObject);
				stubObject = null;
			}
				
			if (!placeObjects(_currentOrder))
			{
				_currentOrder.splice(_currentOrder.indexOf(dObject), 1);
				placeObjects(_currentOrder);
				return false;
			}
			
			dObject.myArea = this;
			return true;
		}
		
		override public function removeDragObject(dObject:Object):void
		{
			var index:int = _currentOrder.indexOf(dObject);
			_currentOrder.splice(index, 1);
			if (!stubObject)
				insertStubObject(dObject, index);
			dObject.myArea = null;
			placeObjects(_currentOrder);
		}
		
		/*---- private methods ----*/
		
		private function drawBack():Shape
		{
			var back:Shape = new Shape();
			back.graphics.beginFill(_format.blockFill);
			back.graphics.lineStyle(_format.borderWidth, _format.borderColor);
			back.graphics.drawRect(0, 0, areaWidth, areaHeight);
			back.graphics.endFill();
			return back;
		}
		
		private function isConflictResolvable(dObject:Object, conflictObject:Object, mousePosition:Point, direction:String):Boolean 
		{
			if (direction == "left")
			{
				if (mousePosition.x > (conflictObject.x + conflictObject.width) -(dObject.width + _marginHorizontal))
					return true;
			}
			else
			{
				if (mousePosition.x < conflictObject.x + dObject.width + _marginHorizontal)
					return true;
			}
			
			return false;
		}
		
		private function willBeAnotherConflict(conflictObject:Object, mousePosition:Point):Boolean 
		{
			var currentOrderCopy:Array = _currentOrder.slice(0, _currentOrder.length);
			var stubIndex:int = currentOrderCopy.indexOf(conflictObject);
				
			if (currentOrderCopy.indexOf(stubObject) != -1)
				currentOrderCopy.splice(currentOrderCopy.indexOf(stubObject), 1);
			currentOrderCopy.splice(stubIndex, 0, stubObject);
			
			try {
				var positions:Array = calculatePositions(currentOrderCopy);
				var conObjPosition:Point = localToGlobal(positions[currentOrderCopy.indexOf(conflictObject)]);
			}
			catch (error:Error)
			{
				return false;
			}
			if (mouseOnConflictObject())
				return true;
				
			return false;
			
			function mouseOnConflictObject():Boolean
			{
				if (mousePosition.x > conObjPosition.x && mousePosition.x < conObjPosition.x + conflictObject.width &&
					mousePosition.y > conObjPosition.y && mousePosition.y < conObjPosition.y + conflictObject.height)
					return true;
				else 
					return false;
			}
		}
		
		private function insertStubObject(dObject:Object, index:int):void 
		{
			stubObject = new StubObject(dObject.width, dObject.height);
			parent.addChild(stubObject);
			parent.swapChildren(stubObject, dObject as DisplayObject);
			_currentOrder.splice(index, 0, stubObject);
			placeObjects(_currentOrder);
		}
		
		private function placeObjects(order:Array):Boolean
		{
			try 
			{
				var positions:Array = calculatePositions(order);
			}
			catch (error:Error)
			{
				return false;
			}
			
			for (var i:int = 0; i < order.length; i++) 
			{
				var position:Point = localToGlobal(positions[i]);
				order[i].x = position.x;
				order[i].y = position.y;
			}
			
			return true;
		}
		
		private function calculatePositions(order:Array):Array
		{
			var positions:Array = [new Point(_marginHorizontal, _marginVertical)];
			var nextRowY:int = positions[0].y + order[0].height + _marginVertical;
			
			for (var i:int = 1; i < order.length; i++) 
			{
				var current:Object = order[i];
				var prev:Object = order[i - 1];
				var newX:int = positions[i - 1].x + prev.width + _marginHorizontal;
				if (newX + current.width + _marginHorizontal <= areaWidth)
				{
					var newY:int = positions[i - 1].y;
					if (newY + current.height + _marginVertical > areaHeight)
						throw new Error('Not enough space in Area for all drag objects!');
						
					positions.push(new Point(newX, newY));
					
					if (nextRowY < positions[i].y + current.height + _marginVertical)
						nextRowY = positions[i].y + current.height + _marginVertical;
				}
				else
				{
					if (nextRowY + current.height + _marginVertical <= areaHeight)
					{
						newX = _marginHorizontal;
						newY = nextRowY;
						positions.push(new Point(newX, newY));
						nextRowY = nextRowY + current.height + _marginVertical;
					}
					else
						throw new Error('Not enough space in Area for all drag objects!');
				}
			}
			
			return positions;
		}
		
		/*---- getters and setters ----*/
		public function set format(value:BlockFormat):void 
		{
			_format = value;
		}
		
	}
}