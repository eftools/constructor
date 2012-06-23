package inobr.eft.constructor.core 
{	
	import flash.display.Shape;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Peter Gerasimenko, gpstmp@gmail.com
	 */
	public class StubObject extends Sprite
	{
		public function StubObject(width:int, height:int)
		{
			var fill:Shape = new Shape();
			fill.graphics.beginFill(0x33CC33, 0.6);
			fill.graphics.drawRect(0, 0, width, height);
			fill.graphics.endFill();
			addChild(fill);
		}
	}

}