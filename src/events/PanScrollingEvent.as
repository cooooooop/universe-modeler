package events
{
    import flash.events.Event;

    public class PanScrollingEvent extends Event
    {
        public static const PAN_SCROLLING_CLICK:String = "panScrollingClick";
        public static const PAN_SCROLLING_BUTTON_CLICK:String = "panScrollingButtonClick";
        public static const PAN_SCROLLING_BUTTON_ROLL_OVER:String = "panScrollingButtonRollOver";
        public static const PAN_SCROLLING_BUTTON_ROLL_OUT:String = "panScrollingButtonRollOut";
        public static const CONTROLS_VISIBLE_CHANGE:String = "controlsVisibleChange";
        
        private var _data:*;
        private var _localX:Number;
        private var _localY:Number;
        
        public function PanScrollingEvent(type:String, data:* = null, bubbles:Boolean = false, cancelable:Boolean = false, localX:Number = -1, localY:Number = -1)
        {
            super(type, bubbles, cancelable);
            this._data = data;
            this._localX = localX;
            this._localY = localY;
        }
        
        public function get data():*
        {
            return _data;
        }
        
        public function get localX():Number
        {
            return _localX;
        }

        public function get localY():Number
        {
            return _localY;
        }

        override public function clone():Event
        {
            return new PanScrollingEvent(type, data, bubbles, cancelable, localX, localY);
        }        
    }
}