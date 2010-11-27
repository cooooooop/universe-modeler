/**
 * @author curtis
 */
package  {
	import mx.core.Application;
	
	import physics.SolarSystemProperties;
	
	[Bindable]
	public class ViewParameters {
		
    
	    public static function getInstance():ViewParameters
	    {
	      return _instance;
	    }
	    
	    public function ViewParameters(enforcer:Class)
	    {
	      if(enforcer != ModelEnforcer) {
	        throw new Error("Use ViewParameters.getInstance to access model");
	      }
	    }
		private static var _instance:ViewParameters = new ViewParameters(ModelEnforcer);
		public const FRAME_RATE:Number = 60; //number of frames on screen in one second
		public const TIME_RATIO:Number = 6400000; //number of seconds represented by one frame 
		public const ORIGINAL_DATE:Date = new Date("2009", "6", "22");
			
		public const canvasWidth:Number = 1000;
		public const canvasHeight:Number = 1000;
		
		public var distanceNumerator:Number = 200;	//This means that distanceNumerator pixels is 1 AU;
		public var timeFrame:Number = 1;
		
		public var currentFrame:Number = 0;
		
		public function get distanceRatio():Number {
			return distanceNumerator/SolarSystemProperties.DIST_EARTH_SUN;
		}
		
		public function set distanceRatio($ratio:Number):void {
			//do nothing
		}
		
		public function get velocityRatio():Number {
			return ((canvasWidth * canvasHeight * distanceRatio) / FRAME_RATE + 20119*distanceRatio);
		}
		
		public function getCurrentDate(frame:Number):Date {
			if((Application.application as Main).SHOW_START)
				frame = timeFrame = 1;
			return new Date(ORIGINAL_DATE.time + TIME_RATIO * frame);
		}
	}

}

class ModelEnforcer {}