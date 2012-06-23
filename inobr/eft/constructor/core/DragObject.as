package  inobr.eft.constructor.core
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import inobr.eft.common.ui.BlockFormat;
	import inobr.eft.constructor.events.ConstructorEvents;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author Peter Gerasimenko, gpstmp@gmail.com
	 */
	public class DragObject extends Sprite 
	{
		private static const DEFAULT_WIDTH:uint = 150;
		private static const DEFAULT_HEIGHT:uint = 40;
		
		private var _setWidth:uint;
		private var _setHeight:uint;
		
		private var _label:Object;
		private var _back:DisplayObject;
		private var _format:BlockFormat = new BlockFormat();
		private var _textFormat:TextFormat = new TextFormat("Calibri", 20, 0x000000, true);
		
		private var _myArea:Area = null;
		private var _previousArea:Area = null;
		private var _previousPosition:Point;
		
		/**
		 * Creates a drag object with specified lable and width/height.
		 * 
		 * @param	lable	string or any DisplayObject (Image, Sprite etc.)
		 */
		public function DragObject(lable:*, width:uint = DEFAULT_WIDTH, height:uint = DEFAULT_HEIGHT) 
		{
			_setWidth = width;
			_setHeight = height;
			_label = lable is String ? createTextLable(lable as String) : (lable as DisplayObject);
			
			// add behaviour
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function mouseMoveHandler(event:MouseEvent):void 
		{
			if (_myArea != null)
				_myArea.removeDragObject(this);
			dispatchEvent(new Event(ConstructorEvents.OBJECT_IS_MOVING, true));
		}
		
		private function mouseUpHandler(event:MouseEvent):void 
		{
			stopDrag();
			removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			if (_previousPosition.x != this.x || _previousPosition.y != this.y)
			{
				dispatchEvent(new Event(ConstructorEvents.DROP_OBJECT, true));
			}
		}
		
		private function mouseDownHandler(event:MouseEvent):void 
		{
			_previousPosition = new Point(this.x, this.y);
			
			startDrag();
			addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			dispatchEvent(new Event(ConstructorEvents.OBJECT_PRESSED, true));
		}
		
		private function createTextLable(text:String):TextField 
		{
			var lable:TextField = new TextField();
			lable.defaultTextFormat = _textFormat;
			lable.autoSize = TextFieldAutoSize.LEFT;
			lable.selectable = false;
			lable.multiline = true;
			lable.text = text;
			
			// center the lable
			lable.x = (_setWidth - lable.width) / 2;
			lable.y = (_setHeight - lable.height) / 2;
			
			return lable;
		}
		
		public function build():void
		{
			addChild(_back = drawBack());
			addChild(_label as DisplayObject);
		}
		
		public function destroy():void
		{
			removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		protected function drawBack():DisplayObject
		{
			var back:Shape = new Shape();
			back.graphics.beginFill(_format.blockFill);
			back.graphics.lineStyle(_format.borderWidth, _format.borderColor);
			back.graphics.drawRect(0, 0, _setWidth, _setHeight);
			back.graphics.endFill();
			
			return back;
		}
		
		/**
		 * Will insert the drag object in the previous field.
		 */
		public function returnToPreviousArea():void
		{
			_previousArea.insertDragObject(this);
		}
		
		/**
		 * Shows the correctness of DragObject movement.
		 * User can see colored blinking around the DragObject after dragging.
		 * The color of blinking is specified by String.
		 * 
		 * @param	correctness	specified the color of the blinking help (use ConstructorWorkspace static constants!)
		 */
		public function showHelp(correctness:String):void
		{
			// blinking is made by applying Glowing filter to objects 
			var myFilters:Array = new Array();
			var repaintTimeout:uint; 
			var alphaValue:Number = 0;
			var i:Number = 0;
			
			switch (correctness) 
			{
				case ConstructorWorkspace.RIGHT:
					repaintTimeout = setInterval(clearer, 30, ConstructorWorkspace.rightHelpColor);
					break;
				case ConstructorWorkspace.WRONG:
					repaintTimeout = setInterval(clearer, 30, ConstructorWorkspace.wrongHelpColor);
					break;
				case ConstructorWorkspace.PARTLYRIGHT:
					repaintTimeout = setInterval(clearer, 30, ConstructorWorkspace.partlyRightHelpColor);
					break;
			}
			
			/**
			 * blinking realized by changing the filter parameter within the specified period of time
			 * 3.5 * Math.PI means two periods of Sinus, so there will be only two blinks
			 * 
			 * @param	color
			 */
			function clearer(color:Number):void
			{
				myFilters.pop();
				alphaValue = (Math.sin(i) + 1) / 2;
				myFilters.push(new GlowFilter(color, alphaValue, 6, 6, 4));
				filters = myFilters;
				i += Math.PI / 10;
				/* deleting all the filters and clearing interval after two periods of Sinus */
				if (i > 3.5 * Math.PI)
				{
					myFilters.pop();
					filters = myFilters;
					clearInterval(repaintTimeout);
				}
			}
		}
		
		/**
		 * The field where this drag object is.
		 */
		public function get myArea():Area
		{
			return _myArea;
		}
		
		/**
		 * The field where this drag object is.
		 */
		public function set myArea(value:Area):void 
		{
			_myArea = value;
			_previousArea = _myArea ? _myArea : _previousArea;
		}
		
		public function get previousArea():Area 
		{
			return _previousArea;
		}
		
		// remove borderWidth from width and height od dragObject
		override public function get height():Number
		{
			return super.height - _format.borderWidth;
		}
		
		override public function get width ():Number
		{
			return super.width - _format.borderWidth;
		}
		
		// for debug 
		override public function toString():String
		{
			return _label.text;
		}
	}

}