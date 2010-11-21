/**
 * @author curtis
 */
package containers {
	
	import mx.collections.ArrayCollection;
	import org.cove.ape.StellarObject;
	import containers.AddBodyRenderer;
	import mx.containers.VBox;
	import mx.events.CollectionEvent;	
		
	public class TabList extends VBox {
		private var _dataProvider:ArrayCollection;
			
		[Bindable]
		public function set dataProvider($data:ArrayCollection):void {
			_dataProvider = $data;
			if(!_dataProvider.hasEventListener(CollectionEvent.COLLECTION_CHANGE))
				_dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
			addChildren();
		}
		
		public function get dataProvider():ArrayCollection {
			return _dataProvider;
		}
		
		public function updateObjects():void {
			for each(var renderer:AddBodyRenderer in getChildren()) {
				renderer.updateAll();
			}
		}
		
		private function onCollectionChange($event:CollectionEvent):void {
			addChildren();
		}
		
		private function addChildren():void {
			var bodyRenderer:AddBodyRenderer;
			for each(var child:StellarObject in _dataProvider) {
				if(!hasChild(child)) {
					bodyRenderer = new AddBodyRenderer();
					bodyRenderer.data = child;
					this.addChild(bodyRenderer);
				}
			}
		}
		
		private function hasChild($child:StellarObject):Boolean {
			for each(var renderer:AddBodyRenderer in getChildren()) {
				if(renderer.data == $child) {
					return true;
				}
			}
			return false;
		}
		
		public function removeAll():void {
			for each(var renderer:AddBodyRenderer in getChildren()) {
				this.removeChild(renderer);
			}
		}
			
	}

}