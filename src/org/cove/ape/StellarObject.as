/**
 * @author curtis
 */
package org.cove.ape {
	
	public class StellarObject extends SelectableParticle {
		
		[Bindable]
		private var _name:String;
				
		public function StellarObject(
				x:Number, 
				y:Number, 
				radius:Number, 
				fixed:Boolean = false,
				mass:Number = 1, 
				elasticity:Number = 0.3,
				friction:Number = 0) {
					
			super(x, y, radius, fixed, mass, elasticity, friction);
		}
		
		[Bindable]
		public function get name():String {
			return _name;
		}
		
		public function set name($data:String):void {
			_name = $data;
		}
		
	}

}