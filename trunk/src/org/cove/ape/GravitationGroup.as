/**
 * @author curtis
 * This class will allow several particles to be included into a group
 * such that the gravitational force between them is calculated. As it
 * extends Group, it will also allow collisions.
 */
package org.cove.ape {

	import events.LogEvent;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	public class GravitationGroup extends Group {
		
		//standard
		private static const G:Number = 6.67300 * Math.pow(10, -11);
		
		//debug
		//private static const G:Number = 6.67300 * 1/ (1000);	
		
		private var viewParameters:ViewParameters = ViewParameters.getInstance();
		
		public function GravitationGroup(collideInternal:Boolean = false) {
			super(collideInternal);
		}
		
		public function gravitationalForceForParticle($particle:AbstractParticle):VectorForce {
			//calculates the force of gravity on particle based on the masses of all other
			//particles. Because this is essentially the same as the force exerted by 
			//a point mass at the center of mass for all other particles, first a calculation
			//is done to find the center of mass for all other particles.
			var particle:AbstractParticle;
			
			var totalMass:Number = 0;
			var totalXMass:Number = 0;
			var totalYMass:Number = 0;
			
			for each(particle in particles) {
				if(particle != $particle) {
					totalMass += particle.mass;
					totalXMass += particle.center.x * particle.mass;
					totalYMass += particle.center.y * particle.mass;
				}
			}
			
			var centralMass:Vector = new Vector(totalXMass/totalMass, totalYMass/totalMass);
			var distance:Number = $particle.center.distance(centralMass) / viewParameters.distanceRatio;
			
			var forceX:Number = G * ((totalMass * $particle.mass)* $particle.center.unitVector(centralMass).x)/(distance*distance) ;
			var forceY:Number = G * ((totalMass * $particle.mass) * $particle.center.unitVector(centralMass).y)/(distance*distance);
			
			//var forceX:Number = - G * (totalMass * $particle.mass)/(distance*distance);
			//var forceY:Number = G * (totalMass * $particle.mass)/(distance*distance);
			
			var consoleTrace:String = ("distanceRatio: " + viewParameters.distanceRatio + " distanceNumerator: " + viewParameters.distanceNumerator);
			//consoleTrace += (" forceX: " + forceX + " forceY: " + forceY);
			
			//dispatchEvent(new LogEvent(LogEvent.CONSOLE_EVENT, true, true, consoleTrace));
			
			return new VectorForce(true,forceX,forceY);
		}
		
		public function selectParticleAt($x:Number, $y:Number):SelectableParticle {
			//selects as if particle was square
			//only deals with SelectableParticles
			var returnParticle:SelectableParticle;
			
			for each(var particle:SelectableParticle in particles) {
				if(Math.abs(particle.center.x - $x) <= particle.radius
					&& Math.abs(particle.center.y - $y) <= particle.radius) {
						returnParticle = particle;
						particle.selected = true;
				}
				else
					particle.selected = false;
				
			}
			
			return returnParticle;
		}
	}

}