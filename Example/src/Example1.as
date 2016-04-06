package {

    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.utils.getTimer;

    public class Example1 extends Sprite
    {
        private var childObject:ChildObject;
        private var parentObject:ParentObject;
        public function Example1()
        {
            childObject = new ChildObject();
            //
            parentObject = new ParentObject(childObject);
            parentObject.registerCallback(ChildObject.MY_EVENT, myEventCallback);
            //
            this.stage.addEventListener(MouseEvent.CLICK, clickHandler);
        }

        private function myEventCallback(chanel:String, data:Object, caller:*, fcaller:*):void
        {
            trace('--- my event in Main ---');
            trace(' chanel:', chanel);
            trace(' data:', data);
            trace(' caller:', caller);
            trace(' first caller:', fcaller);
        }


        private function clickHandler(event:MouseEvent):void
        {
            trace('--- mouse click ---');
            childObject.doAction(getTimer(), true);
        }
    }
}

import ru.flashpress.callback.FPCaller;

class ChildObject extends FPCaller
{
    public static const MY_EVENT:String = 'myEvent';

    public function ChildObject()
    {

    }

    public function doAction(data:Object, bubble:Boolean):void
    {
        this.dispatchCallback(MY_EVENT, data, bubble);
    }
}

class ParentObject extends FPCaller
{
    private var child:ChildObject;
    public function ParentObject(child:ChildObject)
    {
        this.child = child;
        child.registerTarget(ChildObject.MY_EVENT, this);
        // or
        // child.parentTarget = this;
    }

    protected override function callback(chanel:String, data:Object, caller:*, fcaller:*):int
    {
        switch (chanel) {
            case ChildObject.MY_EVENT:
                trace('--- my event in ParentObject ---');
                trace(' data:', data);
                trace(' caller:', caller);
                trace(' first caller:', fcaller);
                break;
        }
        return super.callback(chanel, data, caller, fcaller);
    }

}
