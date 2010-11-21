/**
 * @author curtis
 */
package events {
	
	import flash.events.Event;	
			
	public class SelectionEvent extends Event {
		
		public static const SELECTION:String = "selection";	
			
		public var selectedItem:Object;
			
		public function SelectionEvent(type:String, object:Object, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			selectedItem = object;
		}
	}

}