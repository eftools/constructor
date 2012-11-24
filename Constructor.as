package  
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import inobr.eft.constructor.core.DragObject;
	import inobr.eft.constructor.core.Area;
	import inobr.eft.constructor.core.Initializer;
	import inobr.eft.constructor.core.ConstructorWorkspace;
	import inobr.eft.constructor.core.StackableArea;
	import inobr.eft.constructor.lang.ru;
	import inobr.eft.constructor.lang.en;
	
	/**
	 * @author Peter Gerasimenko, gpstmp@gmail.com
	 */
	[SWF(width = "600", height = "460", frameRate = "40", backgroundColor = "#FFFFFF")]
	public class Constructor extends Initializer
	{
		override protected function initialize():void
		{
			var workspace:ConstructorWorkspace = new ConstructorWorkspace(en);
			
			var dragObject_1:DragObject = new DragObject("Lable 1", 100, 50);
			var dragObject_2:DragObject = new DragObject("Lable 2", 120);
			var dragObject_3:DragObject = new DragObject("Lable 3", 200, 60);
			var dragObject_4:DragObject = new DragObject("Lable 4");
			var dragObject_5:DragObject = new DragObject("Lable 5", 100, 60);
			var dragObject_6:DragObject = new DragObject("Lable 6", 150, 80);
			
			var homeArea:Area = new StackableArea(10, 10, 580, 160);
			homeArea.setInitialDragObjects(dragObject_1, dragObject_3, dragObject_2, dragObject_4, dragObject_5, dragObject_6);
			homeArea.rightOrder = [dragObject_1, dragObject_3, dragObject_2];
			
			var dropArea_1:Area = new StackableArea(10, 180, 430, 90);
			dropArea_1.marginHorizontal = 20;
			dropArea_1.marginVertical = 10;
			dropArea_1.rightOrder = [dragObject_4, dragObject_5];
			dropArea_1.isSequenceImportant = true;
			
			var dropArea_2:Area = new StackableArea(10, 310, 430, 110);
			dropArea_2.rightOrder = [dragObject_6];
			
			workspace.addArea(homeArea, dropArea_1, dropArea_2);
			
			addChild(workspace);
		}
	}

}