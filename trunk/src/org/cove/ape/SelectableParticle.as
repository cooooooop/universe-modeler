/**
 * @author curtis
 */
package org.cove.ape {
			
	public class SelectableParticle extends CircleParticle {
		
		[Bindable]
		private var _selected:Boolean = false;	
		
		[Bindable]
		private var _force:Vector;
		
		[Bindable] public var color:uint = 0xFFFFFF;
						
		public function SelectableParticle(
				x:Number, 
				y:Number, 
				radius:Number, 
				fixed:Boolean = false,
				mass:Number = 1, 
				elasticity:Number = 0.3,
				friction:Number = 0) {
					
			super(x, y, radius, fixed, mass, elasticity, friction);
		}
		
		override public function init():void {
			cleanup();
			if (displayObject != null) {
				initDisplay();
			} else {
				sprite.graphics.clear();
				
				if(_selected) {
					sprite.graphics.lineStyle(1,0xFFFFFF,1);
					sprite.graphics.beginFill(0, 0);
					sprite.graphics.drawCircle(0, 0, radius + 2);
				}
				
				sprite.graphics.lineStyle(lineThickness, lineColor, lineAlpha);
				sprite.graphics.beginFill(color, fillAlpha);
				sprite.graphics.drawCircle(0, 0, radius);
				sprite.graphics.endFill();
			}
			paint();
		}
		
		override public function addForce(f:IForce):void {
			super.addForce(f);
			
			var vf:VectorForce = f as VectorForce;
			if(vf)
				_force = new Vector(vf.vx, vf.vy);
		}
		
		[Bindable]
		public function get force():Vector {
			return _force;
			
		}
		
		public function set force($vector:Vector):void {
			//do nothing
		}
		
		[Bindable]
		public function set selected($data:Boolean):void {
			_selected = $data;
			init();
		}
		
		public function get selected():Boolean {
			return _selected;
		}
		
	}

}