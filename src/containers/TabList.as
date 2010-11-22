/**
 * @author curtis
 */
package containers {
	
	import mx.collections.ArrayCollection;
	import mx.containers.VBox;
	import mx.events.CollectionEvent;
	
	import org.cove.ape.StellarObject;	
		
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
				var body:StellarObject = renderer.updateAll();
				var index:int = _dataProvider.getItemIndex(body);
				if(index >= 0)
					_dataProvider.setItemAt(body,index);
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
					this.addChild(bodyRenderer);
					bodyRenderer.data = child;
				}
			}
		}
		
		public function useSetValues($array:Array):void {
    		this.removeAllChildren();
    		_dataProvider = new ArrayCollection();
    		
    		var renderer:AddBodyRenderer;
    		for each(var body:StellarObject in $array) {
    			_dataProvider.addItem(body);
    			renderer = new AddBodyRenderer();
    			this.addChild(renderer);
    			renderer.addSetValues(body);
    		}
    		
    		if(!_dataProvider.hasEventListener(CollectionEvent.COLLECTION_CHANGE))
				_dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
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