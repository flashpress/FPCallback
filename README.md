## Dispatch callback
```ActionScript
var chanel:String = 'myEvent';
var someSata = {};
var bubble:Boolean = true;
caller.dispatchCallback(chanel, someSata, bubble);
```

## Register callback
```ActionScript
var chanel:String = 'myEvent';
var priority:int = 0;
var thisTarget:* = this;
caller.registerCallback(chanel, myCallback, priority, thisTarget);
```

### Callback functions
Empty callback function:
```ActionScript
function myCallback():void {
   trace();
}
```
or with some data:
```ActionScript
function myCallback(someSata:Object):void {
}
```
or with chanel name & some data:
```ActionScript
function myCallback(chanel:String, someSata:Object):void {
}
```
or with all parameters:
```ActionScript
function myCallback(chanel:String, someSata:Object, caller:*, firstCaller:*):void {
}
```
