//
// Inspired from flexlib.containers.ButtonScrollingCanvas by Doug McCune
// Changes: 8 buttons
//          mouse panning and auto scrolling with goal-based easing effect
//          Events
//
// Author: Didier Burton
// See:    http://blog.didierburton.net
// Copyright (c) 2008 Didier Burton, under same terms as stated hereafter.
//
// Original code is copyrighted:
//

/*
Copyright (c) 2007 FlexLib Contributors.  See:
    http://code.google.com/p/flexlib/wiki/ProjectContributors

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

package containers
{
    import events.PanScrollingEvent;
    
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    import mx.containers.Canvas;
    import mx.controls.Button;
    import mx.core.ScrollPolicy;
    import mx.effects.Effect;
    import mx.effects.Fade;
    import mx.effects.easing.Quadratic;
    import mx.styles.CSSStyleDeclaration;
    import mx.styles.StyleManager;

//--------------------------------------
//  Events
//--------------------------------------

    [Event(name="panScrollingClick", type="dda.events.PanScrollingEvent")]
    [Event(name="controlsVisibleChange", type="dda.events.PanScrollingEvent")]
    [Event(name="panScrollingButtonClick", type="dda.events.PanScrollingEvent")]
    [Event(name="panScrollingButtonRollOver", type="dda.events.PanScrollingEvent")]
    [Event(name="panScrollingButtonRollOut", type="dda.events.PanScrollingEvent")]

//--------------------------------------
//  Styles
//--------------------------------------

    [Style(name="buttonThickness", type="Number", inherit="no")]    
    [Style(name="mouseScrollPadding", type="Number", inherit="no")]    
    [Style(name="northButtonStyleName", type="String", inherit="no")]
    [Style(name="northEastButtonStyleName", type="String", inherit="no")]
    [Style(name="eastButtonStyleName", type="String", inherit="no")]
    [Style(name="southEastButtonStyleName", type="String", inherit="no")]
    [Style(name="southButtonStyleName", type="String", inherit="no")]
    [Style(name="southWestButtonStyleName", type="String", inherit="no")]
    [Style(name="westButtonStyleName", type="String", inherit="no")]
    [Style(name="northWestButtonStyleName", type="String", inherit="no")]
    
//--------------------------------------
//  Class
//--------------------------------------

    public class PanScrollingCanvas extends Canvas
    {

    //--------------------------------------------
    // Constants
    //--------------------------------------------
    
        private static const DEFAULT_BUTTON_THICKNESS:Number = 20;      // pixels
        private static const DEFAULT_PANNING_EASE_FACTOR:Number = .08;  // ratio
        private static const DEFAULT_PANNING_THRESHOLD:Number = 1.5;    // pixels
        private static const DEFAULT_PANNING_REFRESH_RATE:Number = 10;  // milliseconds
        private static const DEFAULT_BUTTON_SHOW_DURATION:Number = 200; // milliseconds
        private static const DEFAULT_BUTTON_HIDE_DURATION:Number = 400; // milliseconds
        
        public static const BUTTON_NONE:int = -1;
        public static const BUTTON_NORTH:int = 0;
        public static const BUTTON_NORTH_EAST:int = 1;
        public static const BUTTON_EAST:int = 2;
        public static const BUTTON_SOUTH_EAST:int = 3;
        public static const BUTTON_SOUTH:int = 4;
        public static const BUTTON_SOUTH_WEST:int = 5;
        public static const BUTTON_WEST:int = 6;
        public static const BUTTON_NORTH_WEST:int = 7;
        
        private static const BUTTON_COUNT:int = 8;
        
    //--------------------------------------------
    // Assets
    //--------------------------------------------
    
        [Embed (source="/assets/assets.swf", symbol="Arrow_N")]
        private static var DEFAULT_ICON_N:Class;
        [Embed (source="/assets/assets.swf", symbol="Arrow_NE")]
        private static var DEFAULT_ICON_NE:Class;
        [Embed (source="/assets/assets.swf", symbol="Arrow_E")]
        private static var DEFAULT_ICON_E:Class;
        [Embed (source="/assets/assets.swf", symbol="Arrow_SE")]
        private static var DEFAULT_ICON_SE:Class;
        [Embed (source="/assets/assets.swf", symbol="Arrow_S")]
        private static var DEFAULT_ICON_S:Class;
        [Embed (source="/assets/assets.swf", symbol="Arrow_SW")]
        private static var DEFAULT_ICON_SW:Class;
        [Embed (source="/assets/assets.swf", symbol="Arrow_W")]
        private static var DEFAULT_ICON_W:Class;
        [Embed (source="/assets/assets.swf", symbol="Arrow_NW")]
        private static var DEFAULT_ICON_NW:Class;
        
    //--------------------------------------------
    // Variables
    //--------------------------------------------
    
        public var panningEaseFactor:Number = DEFAULT_PANNING_EASE_FACTOR;
        public var panningThreshold:Number = DEFAULT_PANNING_THRESHOLD;
        public var panningRefreshRate:Number = DEFAULT_PANNING_REFRESH_RATE;
        
        private var innerCanvas:Canvas;
        private var buttons:Array;
        private var buttonShowEffect:Effect;
        private var buttonHideEffect:Effect;
        private var _childrenCreated:Boolean;
        private var _buttonThickness:Number;
        private var _buttonThicknessChanged:Boolean;
        private var _explicitButtonLength:Number;
        private var _buttonsVisible:Boolean;
        private var _buttonsVisibleChanged:Boolean;
        private var _buttonsEnabled:Boolean;
        private var _buttonsEnabledChanged:Boolean;
        private var _buttonsAlpha:Number;
        private var _buttonsAlphaChanged:Boolean;
        
        private var _enablePanning:Boolean = true;

        private var lastMouseX:Number;
        private var lastMouseY:Number;
        private var easeScrollingEnded:Boolean;
        private var mouseOver:Boolean;
        private var panTimer:Timer;
        
        private var buttonsPreparedForMouseScrolling:Boolean;        
        
    //--------------------------------------------
    // Constructor
    //--------------------------------------------

        public function PanScrollingCanvas()
        { 
            super();
            
            _buttonsEnabled = true;
            _buttonsVisible = false;
            buttonShowEffect = new Fade();
            Fade(buttonShowEffect).alphaFrom = 0.0;
            Fade(buttonShowEffect).alphaTo = 1.0;
            Fade(buttonShowEffect).duration = DEFAULT_BUTTON_SHOW_DURATION;
            Fade(buttonShowEffect).easingFunction = Quadratic.easeIn;
            buttonHideEffect = new Fade();
            Fade(buttonHideEffect).alphaFrom = 1.0;
            Fade(buttonHideEffect).alphaTo = 0.0;
            Fade(buttonHideEffect).duration = DEFAULT_BUTTON_HIDE_DURATION;
            Fade(buttonHideEffect).easingFunction = Quadratic.easeOut;
        }
        
    //--------------------------------------------
    // Framework Overrides
    //--------------------------------------------

        override protected function createChildren():void
        {
            super.createChildren();
            
            innerCanvas = new Canvas();
            innerCanvas.horizontalScrollPolicy = ScrollPolicy.OFF;
            innerCanvas.verticalScrollPolicy = ScrollPolicy.OFF;
            innerCanvas.clipContent = true;

            while (this.numChildren > 0)
            {
                innerCanvas.addChild(this.removeChildAt(0));
            }
                        
            buttons = new Array(BUTTON_COUNT);
            var i:int;
            for (i = 0; i < BUTTON_COUNT; i++)
            {
                var button:Button = new Button();
                buttons[i] = button;
                button.visible = false;
                setButtonStyleAt(i);
            }
            buttonShowEffect.targets = buttons;
            buttonHideEffect.targets = buttons;
            
            rawChildren.addChild(innerCanvas);
            for (i = 0; i < BUTTON_COUNT; i++)
            {
             //   rawChildren.addChild(getButtonAt(i));
            }
        
            _childrenCreated = true;

            addMouseListeners();
        }

        override public function addChild(child:DisplayObject):DisplayObject
        {
            if (innerCanvas)
            {
                return innerCanvas.addChild(child);
            }
            else
            {
                return super.addChild(child);
            }
        }
        
        override protected function commitProperties():void
        {
            super.commitProperties();
            
            var i:int;
            if (_buttonsVisibleChanged)
            {
                if (buttonsVisible)
                {
                    buttonHideEffect.stop();
                    buttonShowEffect.play();
                }
                else
                {
                    buttonShowEffect.stop();
                    buttonHideEffect.play();
                }
                for (i = 0; i < BUTTON_COUNT; i++)
                {
                    getButtonAt(i).visible = true; // always true to guarantee hide effect display
                }
                _buttonsVisibleChanged = false;
            }
            if (_buttonsEnabledChanged)
            {
                for (i = 0; i < BUTTON_COUNT; i++)
                {
                    getButtonAt(i).enabled = buttonsEnabled;
                }
                _buttonsEnabledChanged = false;
            }
            if (_buttonsAlphaChanged)
            {
                for (i = 0; i < BUTTON_COUNT; i++)
                {
                    getButtonAt(i).alpha = buttonsAlpha;
                }
                _buttonsAlphaChanged = false;
            }
        }
        
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            innerCanvas.setActualSize(unscaledWidth, unscaledHeight);
            if (_buttonsVisible)
            {
                layoutButtons(unscaledWidth, unscaledHeight);
            }
        }
        
    //--------------------------------------------
    // Style management
    //--------------------------------------------

        private static function initializeStyles():void
        {
            var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("PanScrollingCanvas");
            
            if (!selector)
            {
                selector = new CSSStyleDeclaration();
            }
            
            selector.defaultFactory = function():void
            {
                this.northButtonStyleName = "northButton";
                this.northEastButtonStyleName = "northEastButton";
                this.eastButtonStyleName = "eastButton";
                this.southEastButtonStyleName = "southEastButton";
                this.southButtonStyleName = "southButton";
                this.southWestButtonStyleName = "southWestButton";
                this.westButtonStyleName = "westButton";
                this.northWestButtonStyleName = "northWestButton";
            }
            
            StyleManager.setStyleDeclaration("PanScrollingCanvas", selector, false);

            // North
            var northStyleName:String = selector.getStyle("northButtonStyleName");
            var northSelector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("." + northStyleName);
            if (!northSelector)
            {
                northSelector = new CSSStyleDeclaration();
            }
            northSelector.defaultFactory = function():void
            {
                this.icon = DEFAULT_ICON_N;  
                this.fillAlphas = [0.6 , 0.6, 0.6, 0.6];
                this.cornerRadius = 0;  
            }
            StyleManager.setStyleDeclaration("." + northStyleName, northSelector, false);

            // North East
            var northEastStyleName:String = selector.getStyle("northEastButtonStyleName");
            var northEastSelector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("." + northEastStyleName);
            if (!northEastSelector)
            {
                northEastSelector = new CSSStyleDeclaration();
            }
            northEastSelector.defaultFactory = function():void
            {
                this.icon = DEFAULT_ICON_NE;  
                this.fillAlphas = [0.6 , 0.6, 0.6, 0.6];
                this.cornerRadius = 0;  
            }
            StyleManager.setStyleDeclaration("." + northEastStyleName, northEastSelector, false);

            // East
            var eastStyleName:String = selector.getStyle("eastButtonStyleName");
            var eastSelector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("." + eastStyleName);
            if (!eastSelector)
            {
                eastSelector = new CSSStyleDeclaration();
            }
            eastSelector.defaultFactory = function():void
            {
                this.icon = DEFAULT_ICON_E;  
                this.fillAlphas = [0.6 , 0.6, 0.6, 0.6];
                this.cornerRadius = 0;  
            }
            StyleManager.setStyleDeclaration("." + eastStyleName, eastSelector, false);

            // South East
            var southEastStyleName:String = selector.getStyle("southEastButtonStyleName");
            var southEastSelector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("." + southEastStyleName);
            if (!southEastSelector)
            {
                southEastSelector = new CSSStyleDeclaration();
            }
            southEastSelector.defaultFactory = function():void
            {
                this.icon = DEFAULT_ICON_SE;  
                this.fillAlphas = [0.6 , 0.6, 0.6, 0.6];
                this.cornerRadius = 0;  
            }
            StyleManager.setStyleDeclaration("." + southEastStyleName, southEastSelector, false);

            // South
            var southStyleName:String = selector.getStyle("southButtonStyleName");
            var southSelector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("." + southStyleName);
            if (!southSelector)
            {
                southSelector = new CSSStyleDeclaration();
            }
            southSelector.defaultFactory = function():void
            {
                this.icon = DEFAULT_ICON_S;  
                this.fillAlphas = [0.6 , 0.6, 0.6, 0.6];
                this.cornerRadius = 0;  
            }
            StyleManager.setStyleDeclaration("." + southStyleName, southSelector, false);

            // South West
            var southWestStyleName:String = selector.getStyle("southWestButtonStyleName");
            var southWestSelector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("." + southWestStyleName);
            if (!southWestSelector)
            {
                southWestSelector = new CSSStyleDeclaration();
            }
            southWestSelector.defaultFactory = function():void
            {
                this.icon = DEFAULT_ICON_SW;  
                this.fillAlphas = [0.6 , 0.6, 0.6, 0.6];
                this.cornerRadius = 0;  
            }
            StyleManager.setStyleDeclaration("." + southWestStyleName, southWestSelector, false);

            // West
            var westStyleName:String = selector.getStyle("westButtonStyleName");
            var westSelector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("." + westStyleName);
            if (!westSelector)
            {
                westSelector = new CSSStyleDeclaration();
            }
            westSelector.defaultFactory = function():void
            {
                this.icon = DEFAULT_ICON_W;  
                this.fillAlphas = [0.6 , 0.6, 0.6, 0.6];
                this.cornerRadius = 0;  
            }
            StyleManager.setStyleDeclaration("." + westStyleName, westSelector, false);

            // North West
            var northWestStyleName:String = selector.getStyle("northWestButtonStyleName");
            var northWestSelector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("." + northWestStyleName);
            if (!northWestSelector)
            {
                northWestSelector = new CSSStyleDeclaration();
            }
            northWestSelector.defaultFactory = function():void
            {
                this.icon = DEFAULT_ICON_NW;  
                this.fillAlphas = [0.6 , 0.6, 0.6, 0.6];
                this.cornerRadius = 0;  
            }
            StyleManager.setStyleDeclaration("." + northWestStyleName, northWestSelector, false);
        }

        initializeStyles();

    //--------------------------------------------
    // Event listener management
    //--------------------------------------------

        protected function addMouseListeners():void
        {
            this.addEventListener(MouseEvent.ROLL_OVER, handleRollOver, false, 0, true);
            this.addEventListener(MouseEvent.ROLL_OUT, handleRollOut, false, 0, true);
            this.addEventListener(MouseEvent.CLICK, handleMouseClick, false, 0, true);
            
            for (var i:int = 0; i < BUTTON_COUNT; i++)
            {
                var button:Button = getButtonAt(i);
                button.addEventListener(MouseEvent.ROLL_OVER, handleButtonRollOver, false, 0, true);
                button.addEventListener(MouseEvent.ROLL_OUT, handleButtonRollOut, false, 0, true);
                button.addEventListener(MouseEvent.CLICK, handleButtonClick, false, 0, true);
            }
        }

    //--------------------------------------------
    // Button management
    //--------------------------------------------
        
        protected function getButtonAt(index:int):Button
        {
            if (!buttons || index < 0 || index >= BUTTON_COUNT) return null;
            return buttons[index] as Button;
        }
        
        protected function getButtonIndex(button:Button):int
        {
            var index:int = BUTTON_NONE;
            for (var i:int = 0; i < BUTTON_COUNT; i++)
            {
                if (button == getButtonAt(i))
                {
                    index = i;
                    break;
                }
            }
            return index;
        }
        
        private function setButtonStyleAt(index:int):void
        {
            if (!buttons || index < 0 || index >= BUTTON_COUNT) return;
            
            switch (index)
            {
                case BUTTON_NORTH:
                    getButtonAt(index).styleName = getStyle("northButtonStyleName");
                    break;
                case BUTTON_NORTH_EAST:
                    getButtonAt(index).styleName = getStyle("northEastButtonStyleName");
                    break;
                case BUTTON_EAST:
                    getButtonAt(index).styleName = getStyle("eastButtonStyleName");
                    break;
                case BUTTON_SOUTH_EAST:
                    getButtonAt(index).styleName = getStyle("southEastButtonStyleName");
                    break;
                case BUTTON_SOUTH:
                    getButtonAt(index).styleName = getStyle("southButtonStyleName");
                    break;
                case BUTTON_SOUTH_WEST:
                    getButtonAt(index).styleName = getStyle("southWestButtonStyleName");
                    break;
                case BUTTON_WEST:
                    getButtonAt(index).styleName = getStyle("westButtonStyleName");
                    break;
                case BUTTON_NORTH_WEST:
                    getButtonAt(index).styleName = getStyle("northWestButtonStyleName");
                    break;
                default:
                    break;
            }
        }

        protected function layoutButtons(unscaledWidth:Number, unscaledHeight:Number):void
        {
            var buttonN:Button = getButtonAt(BUTTON_NORTH);
            var buttonNE:Button = getButtonAt(BUTTON_NORTH_EAST);
            var buttonE:Button = getButtonAt(BUTTON_EAST);
            var buttonSE:Button = getButtonAt(BUTTON_SOUTH_EAST);
            var buttonS:Button = getButtonAt(BUTTON_SOUTH);
            var buttonSW:Button = getButtonAt(BUTTON_SOUTH_WEST);
            var buttonW:Button = getButtonAt(BUTTON_WEST);
            var buttonNW:Button = getButtonAt(BUTTON_NORTH_WEST);
            
            var buttonLength:Number = _explicitButtonLength ? _explicitButtonLength : unscaledHeight; 
                        
            var yLevel:Number = (unscaledHeight - buttonLength)/2;
            if (yLevel < 2 * buttonThickness)
            {
                yLevel = 2 * buttonThickness;
                buttonLength = unscaledHeight - 4 * buttonThickness;
            }
            
            buttonW.move(0, yLevel);
            buttonE.move(unscaledWidth - buttonThickness, yLevel);
            buttonW.setActualSize(buttonThickness, buttonLength);            
            buttonE.setActualSize(buttonThickness, buttonLength);

            buttonLength = _explicitButtonLength ? _explicitButtonLength : unscaledWidth;
            var xLevel:Number = (unscaledWidth - buttonLength)/2;
            if (xLevel < 2 * buttonThickness)
            {
                xLevel = 2 * buttonThickness;
                buttonLength = unscaledWidth - 4 * buttonThickness;
            }
            
            buttonN.move(xLevel, 0);
            buttonS.move(xLevel, unscaledHeight - buttonThickness);
            buttonN.setActualSize(buttonLength, buttonThickness);
            buttonS.setActualSize(buttonLength, buttonThickness);
            
            buttonNW.move(0, 0);
            buttonNE.move(unscaledWidth - buttonThickness, 0);
            buttonSW.move(0, unscaledHeight - buttonThickness);
            buttonSE.move(unscaledWidth - buttonThickness, unscaledHeight - buttonThickness);
            buttonNW.setActualSize(buttonThickness, buttonThickness);
            buttonNE.setActualSize(buttonThickness, buttonThickness);
            buttonSW.setActualSize(buttonThickness, buttonThickness);
            buttonSE.setActualSize(buttonThickness, buttonThickness);
        }
        
        protected function updateButtonsDisplayState():void
        {
            var oldValue:Boolean = buttonsVisible;
            if (maxHorizontalScrollPosition == 0 && maxVerticalScrollPosition == 0)
            {
                buttonsVisible = false;
            }
            else
            {
                buttonsVisible = isMouseOverCanvas();
            }
            if (buttonsVisible != oldValue)
            {
                dispatchEvent(new PanScrollingEvent(PanScrollingEvent.CONTROLS_VISIBLE_CHANGE, buttonsVisible));
            }
        }
        
        protected function isMouseOverCanvas():Boolean
        {
            return (mouseX >= 0 && mouseX < this.width && mouseY >= 0 && mouseY < this.height);
        }

    //--------------------------------------------
    // Event Handlers
    //--------------------------------------------
            
        private function handleRollOver(event:MouseEvent):void
        {
	        if(_enablePanning) {
	            mouseOver = true;
	            updateButtonsDisplayState();
	            startPanScrolling();
        	}
        }

        private function handleRollOut(event:MouseEvent):void
        {
            mouseOver = false;
            updateButtonsDisplayState();
            // Do not call stopPanScrolling() here, which would stop the pan timer.
            // Instead, let the scroll ease out when the mouse leaves the canvas.
            // Function handlePanTimer() will call it after the animation ends.
        }

        private function handleMouseClick(event:MouseEvent):void
        {
            dispatchEvent(new PanScrollingEvent(PanScrollingEvent.PAN_SCROLLING_CLICK, null, false, false, mouseX, mouseY));
        }
        
        private function handleButtonClick(event:MouseEvent):void
        {
            var index:int = getButtonIndex(event.currentTarget as Button);
            if (index == BUTTON_NONE) return;
            dispatchEvent(new PanScrollingEvent(PanScrollingEvent.PAN_SCROLLING_BUTTON_CLICK, index));
        }

        private function handleButtonRollOver(event:MouseEvent):void
        {
            var index:int = getButtonIndex(event.currentTarget as Button);
            if (index == BUTTON_NONE) return;
            dispatchEvent(new PanScrollingEvent(PanScrollingEvent.PAN_SCROLLING_BUTTON_ROLL_OVER, index));
        }

        private function handleButtonRollOut(event:MouseEvent):void
        {
            var index:int = getButtonIndex(event.currentTarget as Button);
            if (index == BUTTON_NONE) return;
            dispatchEvent(new PanScrollingEvent(PanScrollingEvent.PAN_SCROLLING_BUTTON_ROLL_OUT, index));
        }
                        
    //--------------------------------------------
    // Property overrides
    //--------------------------------------------
        
        override public function get horizontalScrollPosition():Number
        {
            return innerCanvas.horizontalScrollPosition;
        }
        
        override public function set horizontalScrollPosition(value:Number):void
        {
            innerCanvas.horizontalScrollPosition = value;
        }
        
        override public function get verticalScrollPosition():Number
        {
            return innerCanvas.verticalScrollPosition;
        }
        
        override public function set verticalScrollPosition(value:Number):void
        {
            innerCanvas.verticalScrollPosition = value;
        }
        
        override public function get maxHorizontalScrollPosition():Number
        {
            return innerCanvas.maxHorizontalScrollPosition;
        }
        
        override public function get maxVerticalScrollPosition():Number
        {
            return innerCanvas.maxVerticalScrollPosition;
        }
        
    //--------------------------------------------
    // Properties & Styles
    //--------------------------------------------
        
        [Bindable]
        public function get enablePanning():Boolean {
        	return _enablePanning;
        }
        
        public function set enablePanning($data:Boolean):void {
       		_enablePanning = $data;
       		
        	if($data)
        		handleRollOver(null);
        	else
        		handleRollOut(null);
        }
        
        public function get mouseScrollPadding():Number
        {
            var n:Number = getStyle("mouseScrollPadding");
            if (n) return n;            
            return PanScrollingCanvas.DEFAULT_BUTTON_THICKNESS;
        }
        
        public function set mouseScrollPadding(value:Number):void
        {
            this.setStyle("mouseScrollPadding", value);
        }
        
        public function get buttonThickness():Number
        {
            var n:Number = getStyle("buttonThickness");
            if (n) return n;         
            return PanScrollingCanvas.DEFAULT_BUTTON_THICKNESS;
        }
        
        public function set buttonThickness(value:Number):void
        {
            this.setStyle("buttonThickness", value);
            invalidateDisplayList();
        }

        public function get explicitButtonLength():Number
        {
            return _explicitButtonLength;
        }

        public function set explicitButtonLength(value:Number):void
        {
            _explicitButtonLength = value;
            invalidateDisplayList();
        }

        public function get buttonsVisible():Boolean
        {
            return _buttonsVisible;
        }
        
        public function set buttonsVisible(value:Boolean):void
        {
            if (buttonsVisible == value) return;
            _buttonsVisible = value;
            _buttonsVisibleChanged = true;
            invalidateProperties();
            invalidateDisplayList();
        }

        public function get buttonsEnabled():Boolean
        {
            return _buttonsEnabled;
        }
        
        public function set buttonsEnabled(value:Boolean):void
        {
            if (buttonsEnabled == value) return;
            _buttonsEnabled = value;
            _buttonsEnabledChanged = true;
            invalidateProperties();
            invalidateDisplayList();
        }

        public function get buttonsAlpha():Number
        {
            return _buttonsAlpha;
        }
        
        public function set buttonsAlpha(value:Number):void
        {
            if (buttonsAlpha == value) return;
            _buttonsAlpha = value;
            _buttonsAlphaChanged = true;
            invalidateProperties();
            invalidateDisplayList();
        }
    
    //--------------------------------------------
    // Mouse Panning & Scrolling
    //--------------------------------------------
        
        public function startPanScrolling():void
        {
            easeScrollingEnded = false;
            killPanTimer();
            panTimer = new Timer(panningRefreshRate);
            panTimer.addEventListener(TimerEvent.TIMER, handlePanTimer, false, 0, true);
            panTimer.start();
        }
        
        public function stopPanScrolling():void
        {
            killPanTimer();
            easeScrollingEnded = true;
        }
        
        private function killPanTimer():void
        {
            if (panTimer)
            {
                panTimer.reset();
                panTimer.removeEventListener(TimerEvent.TIMER, handlePanTimer);
                panTimer = null;
            }            
        }
        
        /**
         * Implements a goal-based adjustment of the scrolling parameters.
         * Each timer tick will get closer to the current goal by a fraction (panningEaseFactor.)
         * Goals can change before being reached, giving the smooth organic feel to the panning.
         */
        private function handlePanTimer(event:TimerEvent):void
        {
            if (!mouseEnabled)
            {
                return;
            }
            
            if (!mouseOver && easeScrollingEnded)
            {
                stopPanScrolling();
                return;
            }

            var easeScrollingXEnded:Boolean;
            var easeScrollingYEnded:Boolean;
                        
            if (mouseOver)
            {
                lastMouseX = mouseX;
                lastMouseY = mouseY;
            }

            var hspTarget:Number;
            var vspTarget:Number;

            if (lastMouseX < mouseScrollPadding)
            {
                hspTarget = 0;
            }
            else if (lastMouseX > this.width - mouseScrollPadding)
            {
                hspTarget = maxHorizontalScrollPosition;
            }
            else
            {
                var rx:Number = (lastMouseX - mouseScrollPadding)/(this.width - 2*mouseScrollPadding);
                rx = Math.max(0, Math.min(1, rx));
                hspTarget = maxHorizontalScrollPosition*rx;
            }

            if (lastMouseY < mouseScrollPadding)
            {
                vspTarget = 0;
            }
            else if (lastMouseY > this.height - mouseScrollPadding)
            {
                vspTarget = maxVerticalScrollPosition;
            }
            else
            {
                var ry:Number = (lastMouseY - mouseScrollPadding)/(this.height - 2*mouseScrollPadding);
                ry = Math.max(0, Math.min(1, ry));
                vspTarget = maxVerticalScrollPosition*ry;
            }

            var dhsp:Number = hspTarget - horizontalScrollPosition;
            var dvsp:Number = vspTarget - verticalScrollPosition;

            if (Math.abs(dhsp) >= panningThreshold)
            {
                horizontalScrollPosition += dhsp*panningEaseFactor;
                easeScrollingXEnded = false;
            }
            else
            {
                horizontalScrollPosition = hspTarget;
                easeScrollingXEnded = true;
            }
            if (Math.abs(dvsp) >= panningThreshold)
            {
                verticalScrollPosition += dvsp*panningEaseFactor;
                easeScrollingYEnded = false;
            }
            else
            {
                verticalScrollPosition = vspTarget;
                easeScrollingYEnded = true;
            }
            easeScrollingEnded = easeScrollingXEnded && easeScrollingYEnded;
        }        
    }
}