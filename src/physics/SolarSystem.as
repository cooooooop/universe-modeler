package physics {

	import events.LogEvent;
	import events.SelectionEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import org.cove.ape.*;

	public class SolarSystem extends Sprite {
		
		private var _bodiesGroup:GravitationGroup;
		public var mouseEvent:MouseEvent;
		[Bindable] public var showPaths:Boolean = true;
		
		private static const DELTA_TIME:Number = 1;
		private var testFrameControl:Number = 1; //default value is 1, set to larger number to slow down
		
		private var viewParameters:ViewParameters = ViewParameters.getInstance();
		
		private var _axesGroup:Group;
		[Bindable] public var showAxes:Boolean = false;
				
		public function SolarSystem() {
			addEventListener(MouseEvent.CLICK, onClick);
		}
		
		public function get bodies():Array {
			if(_bodiesGroup)
				return _bodiesGroup.particles;
			return [];
		}
		
		private function onClick($event:MouseEvent):void {
			var clickPoint:Point = new Point($event.stageX, $event.stageY);
			var localPoint:Point = this.globalToLocal(clickPoint);
			var selectedParticle:StellarObject = _bodiesGroup.selectParticleAt(localPoint.x, localPoint.y) as StellarObject;
		
			dispatchEvent(new SelectionEvent(SelectionEvent.SELECTION, selectedParticle, true, true));
		}
		
		public function letsGo():void {
			this.graphics.clear();
			stage.frameRate = viewParameters.FRAME_RATE;
			addEventListener(Event.ENTER_FRAME, run);
			
			APEngine.init(DELTA_TIME);
			APEngine.container = this;
			
			//APEngine.addForce(new VectorForce(true, 0.01, 0.01));
			
		}
		
		public function clear():void {
			_prevLocations = null;
			if(_bodiesGroup) {
				APEngine.removeGroup(_bodiesGroup);
			}
		}
		
		public function drawGrid():void {
			//just axes
			_axesGroup = new Group();
			var xAxis:RectangleParticle = new RectangleParticle(0,0,2000,0.001,0,true);
			var yAxis:RectangleParticle = new RectangleParticle(0,0,0.001,2000,0,true);
			xAxis.setStyle(1,0xFFFFFF,1,0xFFFFFF,1);
			yAxis.setStyle(1,0xFFFFFF,1,0xFFFFFF,1);
			
			_axesGroup.addParticle(xAxis);
			_axesGroup.addParticle(yAxis);
			
		}
		
		public function addBodies($bodies:Array, $useCollisions:Boolean = false):void {
			clear();
				
			_bodiesGroup = new GravitationGroup($useCollisions);
			
			for each(var body:StellarObject in $bodies) {
				_bodiesGroup.addParticle(body);
			}
			
			APEngine.addGroup(_bodiesGroup);
			
		}
		
		public function clearPaths():void {
			_prevLocations = null;
			this.graphics.clear();
		}
		
		private var _prevLocations:Dictionary;
		
		private function drawPath():void {
			if(_bodiesGroup) {
				if(_prevLocations == null)
					_prevLocations = new Dictionary();
				for each(var particle:SelectableParticle in _bodiesGroup.particles) {
					if(_prevLocations[particle]) {
						this.graphics.lineStyle(1, particle.color, 1);
						this.graphics.moveTo(_prevLocations[particle].x, _prevLocations[particle].y);
						this.graphics.lineTo(particle.center.x, particle.center.y);
					}
					
					_prevLocations[particle] = new Vector(particle.center.x, particle.center.y);
				}
			}
		}
		
		private function onConsoleEvent($event:LogEvent):void {
			dispatchEvent($event);
		}
		
		private function calculateForcesPerStep():void {
			if(_bodiesGroup) {
				for each(var particle:AbstractParticle in _bodiesGroup.particles) {
					var force:VectorForce = _bodiesGroup.gravitationalForceForParticle(particle);
				
					particle.addForce(force);
				}
			}
		}

		private function run(evt:Event):void {
			
			if(!showAxes && APEngine.hasGroup(_axesGroup))
				APEngine.removeGroup(_axesGroup);
			else if(showAxes && !APEngine.hasGroup(_axesGroup))
				APEngine.addGroup(_axesGroup);
			
			//Each frame represents one 
			viewParameters.currentFrame++;
			
			if(viewParameters.currentFrame % (1 * testFrameControl) == 0) {
				switch(Main.timeControlValue) {
					case Main.FR:
						testFrameControl--;
						break;
					case Main.SR:
						break;
					case Main.PA:
						testFrameControl = 0;
						break;
					case Main.PL:
						testFrameControl = 5;
						break;
					case Main.SF:
						break;
					case Main.FF:
						testFrameControl++;
						break;
				}
				
				calculateForcesPerStep();
				
				APEngine.step();
				APEngine.paint();
				if(showPaths && viewParameters.currentFrame % (5 * testFrameControl) == 0)	
					drawPath();
				else if(!showPaths) {
					_prevLocations = null;
				}
			}
		}
	}

}
