package ru.flashpress.callback
{
	import flash.events.EventDispatcher;

	/**
	 * Класс для обработки функций обратного вызова
	 * @author Serious Sam
	 */
	public class FPCaller extends EventDispatcher implements IFPTarget
	{
		use namespace fpCallbackNS;
        //
        public static const STOP_NONE:int = 0;
        public static const STOP_PROPOGATION:int = 1;
        public static const STOP_IMMEDIATE_PROPOGATION:int = 2;
		//
		//private static const DEFAULT:String = 'default';
		//
		private var name:String;
        private var redirectTarget:*;
		private var redirectFunc:Function;
		private var targetsCash:Object;
		private var callbacksCash:Object;
		/**
		 * Конструктор
		 * @param name Имя
		 * @param parent Родительский объект для обратного вызова
		 */
		public function FPCaller(name:String=null, redirectTarget:*=null, redirectFunc:Function=null)
		{
			this.name = name;
            this.redirectTarget = redirectTarget?redirectTarget:this;
			this.redirectFunc = redirectFunc;
			//
			this.targetsCash = {};
			this.callbacksCash = {};
			//this.callbacks[FPCaller.DEFAULT] = new FPCallbacksList(FPCaller.DEFAULT);
		}

        fpCallbackNS var _parentTarget:IFPTarget;
        public function set parentTarget(value:IFPTarget):void {this._parentTarget = value;}

        public function get caller():FPCaller {return this;}

		/**
		 * Вызвать метод обратного вызова.
		 * Метод callbackEvent вызывается у всех зарегистрированных(родительских) объектов.
		 * Метод также запускает функцию parentCallEvent, если она была задана в конструкторе.
		 * @param target Инициатор обратного вызова
		 * @param chanel Канал обратного вызова, значение по умолчанию FPCaller.DEFAULT="default"
		 * @param data Информация передаваемая при обратном вызове
		 */
		final public function dispatchCallback(chanel:String, data:Object=null, bubble:Boolean=false):void
		{
            dropParent(chanel, data, redirectTarget, bubble);
 		}

        private var _i:int;
        private var _tempParent:IFPTarget;
		private var _func:Function;
        private var _stopIndex:int;
        private var _stopPropogation:Boolean;
        private var _isDropParent:Boolean;
        private var _thisTarget:*;
        private function dropParent(chanel:String, data:Object, fcaller:*, bubble:Boolean):void
        {
            var targetList:FPTargetList = this.targetsCash[chanel];
            _isDropParent = false;
            if (targetList) {
                targetList._freeze = true;
                _stopPropogation = false;
                for (_i = 0; _i < targetList._count; _i++) {
                    _tempParent = targetList._list[_i];
                    _stopIndex = _tempParent.caller.callback(chanel, data, redirectTarget, fcaller);
                    if (_tempParent == _parentTarget) _isDropParent = true;
                    if (_stopIndex == STOP_PROPOGATION) _stopPropogation = true;
                    if (_stopIndex == STOP_IMMEDIATE_PROPOGATION) break;
                    //
                    if (bubble && !_stopPropogation) {
                        _tempParent.caller.dropParent(chanel, data, fcaller, bubble);
                    }
                }
                targetList._freeze = false;
                if(targetList._listDeleted.length) {
                    targetList.applyListDeleted();
                }
            }
			//
			//
			var cbList:FPCallbackList = this.callbacksCash[chanel];
			if (cbList) {
				cbList._freeze = true;
				_stopPropogation = false;
				for (_i = 0; _i < cbList._count; _i++) {
					_func = cbList._list[_i];
                    _thisTarget = cbList.getInfo(_func).thisTarget;
					switch (_func.length) {
						case 0:
							_func.call(_thisTarget);
							break;
						case 1:
							_func.call(_thisTarget, data);
							break;
						case 2:
							_func.call(_thisTarget, chanel, data);
							break;
						case 4:
							_func.call(_thisTarget, chanel, data, redirectTarget, fcaller);
							break;
					}
				}
				cbList._freeze = false;
				if(cbList._listDeleted.length) {
					cbList.applyListDeleted();
				}
			}
            //
            if (_parentTarget && bubble && !_isDropParent) {
                _parentTarget.caller.dropParent(chanel, data, redirectTarget, fcaller);
            }
        }

		protected function callback(chanel:String, data:Object, caller:*, fcaller:*):int
		{
			if (redirectFunc) {
				return redirectFunc.call(null, chanel, data, caller, fcaller);
			} else {
				return 0;
			}
		}

		/**
		 * Добавить объект для обратного вызова.
		 * @param parent Объект который должен получить обратный вызов.
		 * @param chanel Канал обратного вызова, значение по умолчанию FPCaller.DEFAULT="default"
		 * @param priority Приоритет вызова
		 */
		final public function registerTarget(chanel:String, parent:IFPTarget, priority:int=0):void
		{
			//if (!chanel) chanel = DEFAULT;
			//
			if (this.targetsCash[chanel]) {
				_cbList2 = this.targetsCash[chanel];
			} else {
				_cbList2 = new FPTargetList(chanel);
				this.targetsCash[chanel] = _cbList2;
			}
			_cbList2.add(parent, priority);
		}
		private var _cbList2:FPTargetList;
		
		/**
		 * Удалить объект обратного вызова
		 * @param parent Объект который должен получить обратный вызов.
		 * @param chanel Канал обратного вызова, значение по умолчанию FPCaller.DEFAULT="default"
		 */
		public function deleteTarget(chanel:String, parent:IFPTarget):void
		{
			//if (!chanel) chanel = DEFAULT;
			_cbList3 = this.targetsCash[chanel];
			if (_cbList3) {
				_cbList3.deleteCallback(parent);
			}
		}
		private var _cbList3:FPTargetList;
		
		/**
		 * Удалить все объекты обратного вызова для указанного родителя
		 */
		public function deleteForTarget(parent:IFPTarget):void
		{
			for (_key4 in this.targetsCash) {
				_cbList4 = this.targetsCash[_key4];
				_cbList4.deleteCallback(parent);
			}
		}
		private var _key4:String;
		private var _cbList4:FPTargetList;


		final public function hasCallback(chanel:String):Boolean
		{
			var targetList:FPTargetList = this.targetsCash[chanel];
			if (targetList && targetList._count > 0) return 0;
			var cbList:FPCallbackList = this.callbacksCash[chanel];
			return cbList && cbList._count > 0;
		}

		private var _cbList5:FPCallbackList;
		final public function registerCallback(chanel:String, func:Function, priority:int=0, thisTarget:* = null):void
		{
			if (this.callbacksCash[chanel]) {
				_cbList5 = this.callbacksCash[chanel];
			} else {
				_cbList5 = new FPCallbackList(chanel);
				this.callbacksCash[chanel] = _cbList5;
			}
			_cbList5.add(func, priority, thisTarget);
		}

		public function deleteCallback(chanel:String, parent:Function):void
		{
			_cbList6 = this.callbacksCash[chanel];
			if (_cbList6) {
				_cbList6.deleteCallback(parent);
			}
		}
		private var _cbList6:FPCallbackList;
	}
}