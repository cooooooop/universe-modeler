/**
 * @author curtis
 */
package physics {
	
	import org.cove.ape.VectorForce;
	import org.cove.ape.AbstractParticle;
	
	public class PhysicsUtil {
		public static function calculateVectorForce($frameRate:Number, $dt:Number, $particle:AbstractParticle):VectorForce {
			return new VectorForce(true, 0.5, 0.5);
		}
	}

}