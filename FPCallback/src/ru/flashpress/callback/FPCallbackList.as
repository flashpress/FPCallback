package ru.flashpress.callback
{
	import flash.utils.Dictionary;
	
	/**
	 * @private
	 */
	internal class FPCallbackList
	{
		use namespace fpCallbackNS;
		//
		private var chanel:String;
		private var _priorities:Dictionary = new Dictionary();
		//
		fpCallbackNS var _list:Vector.<Function>;
		fpCallbackNS var _listDeleted:Vector.<Function>;
		fpCallbackNS var _count:int;
		fpCallbackNS var _freeze:Boolean;
		//
		public function FPCallbackList(chanel:String)
		{
			this.chanel = chanel;
			//
			this._list = new Vector.<Function>();
			this._listDeleted = new Vector.<Function>();
			this._count = 0;
		}

        fpCallbackNS function getInfo(func:Function):CallbackInfo
        {
            return _priorities[func];
        }

		fpCallbackNS function deleteCallback(func:Function):void
		{
			if (_freeze) {
				_listDeleted.push(func);
				return;
			}
			var index:int = this._list.indexOf(func);
			if (index != -1) {
				_list.splice(index, 1);
			}
            if (_priorities[func]) {
                _priorities[func].release();
                delete _priorities[func];
            }
			//
			this._count = this._list.length;
		}
		fpCallbackNS function applyListDeleted():void
		{
			var i:int;
			for (i=0; i<_listDeleted.length; i++) {
				deleteCallback(_listDeleted[i]);
			}
			_listDeleted.length = 0;
		}
		
		fpCallbackNS function add(func:Function, priority:int=0, thisTarget:*=null):void
		{
			if (this._list.indexOf(func) == -1) {
				this._list.push(func);
			}
			this._priorities[func] = CallbackInfo.create(func, priority, thisTarget);
			this._list.sort(this.sortPriority);
			//
			this._count = this._list.length;
		}
		
		private function sortPriority(func1:Function, func2:Function):int
		{
			var p1:CallbackInfo = this._priorities[func1];
			var p2:CallbackInfo = this._priorities[func2];
			if (p1.priority > p2.priority) return -1;
			if (p1.priority < p2.priority) return 1;
			return 0;
		}
	}
}

class CallbackInfo
{
    private static var pool:Vector.<CallbackInfo> = new <CallbackInfo>[];
    public static function create(func:Function, priority:int, thisTarget:*):CallbackInfo
    {
        var info:CallbackInfo;
        if (pool.length) {
            info = pool.shift();
        } else {
            info = new CallbackInfo();
        }
        info.func = func;
        info.priority = priority;
        info.thisTarget = thisTarget;
        return info;
    }

    public var func:Function;
    public var priority:int;
    public var thisTarget:*;
    public function CallbackInfo()
    {
    }

    public function release():void
    {
        this.func = null;
        this.priority = 0;
        this.thisTarget = null;
        //
        pool.push(this);
    }
}