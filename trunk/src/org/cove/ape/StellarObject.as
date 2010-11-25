/**
 * @author curtis
 */
package org.cove.ape {
	public class StellarObject extends SelectableParticle {
		
		[Bindable]
		private var _name:String;
				
		public function StellarObject(
				x:Number=NaN, 
				y:Number=NaN, 
				radius:Number=NaN, 
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
		
		public function clone():StellarObject {
			var clone:StellarObject = new StellarObject(this.center.x, this.center.y, this.radius, this.fixed, this.mass, this.elasticity, this.friction);
			clone.name = this.name;
			clone.velocity = new Vector(this.velocity.x, this.velocity.y);
			
			return clone;
		}
		
	}

}