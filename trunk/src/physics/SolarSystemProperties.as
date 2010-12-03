/**
 * @author curtis
 */
package physics {
	public class SolarSystemProperties {
		//values pilfered from http://nssdc.gsfc.nasa.gov/planetary/factsheet/earthfact.html
			
				
		//kilograms
		public static const SUN_MASS:Number = 1.9891 * Math.pow(10, 30);
		//kilograms
		public static const EARTH_MASS:Number = 5.9736 * Math.pow(10, 24);
		//kilograms
		public static const JUPITER_MASS:Number = 1.8986 * Math.pow(10, 27);
		
		//meters
		public static const ASTRONOMICAL_UNIT:Number = 1.4960 * Math.pow(10, 11);
		
		//meters
		public static const EARTH_APHELION:Number = 1.5210 * Math.pow(10,11);
		
		//meters
		public static const EARTH_PERIHELION:Number = 1.4709 * Math.pow(10,11);
		
		//kilograms
		public static const MOON_MASS:Number = 7.35 * Math.pow(10, 22);
		//meters per second
		public static const EARTH_VELOCITY_MEAN:Number = 29780;
		//meters per second
		public static const EARTH_VELOCITY_APHELION:Number = 29290;
		//meters per second
		public static const EARTH_VELOCITY_PERIHELION:Number = 30290;
		//meters per second
		public static const MOON_VELOCITY:Number = 1018;
		
		//meters per second
		public static const SPEED_TO_GO_ONE_AU_IN_ONE_YEAR:Number = 4740.639186;
		
	}

}