/**
 * @author curtis
 */
package events {
	
	import flash.events.DataEvent;	
			
	public class LogEvent extends DataEvent {
		
		public static const CONSOLE_EVENT:String = "consoleEvent";	
			
		public function LogEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, data:String = "") {
			super(type, bubbles, cancelable, data);
		}
	}

}