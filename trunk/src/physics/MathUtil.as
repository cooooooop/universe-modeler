/**
 * @author curtis
 */
package physics {
	public class MathUtil {
		
		//Courtesy of Robert Penner 2001
		public static function toScientific(num:Number, sigDigs:Number):String {
			if(isNaN(num))
				return num.toString();
				
			var exponent:Number = Math.floor(Math.log(Math.abs(num)) / Math.LN10);
			if(num == 0)
				exponent = 0;
				
			var tenToPower:Number = Math.pow(10, exponent);
			var mantissa:Number = num / tenToPower;
			
			var output:String = formatDecimals(mantissa, sigDigs-1);
			
			if(exponent != 0)
				output += "e" + exponent;
				
			return output;
		}
	
		//Courtesy of Robert Penner 2001
		public static function formatDecimals(num:Number, digits:Number):String {
			if(digits <= 0) {
				return Math.round(num).toString();
			}
			
			var tenToPower:Number = Math.pow(10, digits);
			var cropped:String = String(Math.round(num * tenToPower)/tenToPower);
			
			if(cropped.indexOf(".") == -1)
				cropped += ".0";
				
			var halves:Array = cropped.split(".");
			
			var zerosNeeded:Number = digits - halves[1].length;
			for(var i:int=1; i <= zerosNeeded; i++) {
				cropped += "0";
			}
			
			return cropped;
		}
	}

}