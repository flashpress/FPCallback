package ru.flashpress.callback
{
	import flash.utils.Dictionary;
	
	/**
	 * @private
	 */
	internal class FPTargetList
	{
		use namespace fpCallbackNS;
		//
		private var chanel:String;
		private var _priorities:Dictionary = new Dictionary();
		//
		fpCallbackNS var _list:Vector.<IFPTarget>;
		fpCallbackNS var _listDeleted:Vector.<IFPTarget>;
		fpCallbackNS var _count:int;
		fpCallbackNS var _freeze:Boolean;
		//
		public function FPTargetList(chanel:String)
		{
			this.chanel = chanel;
			//
			this._list = new Vector.<IFPTarget>();
			this._listDeleted = new Vector.<IFPTarget>();
			this._count = 0;
		}

		fpCallbackNS function deleteCallback(parent:IFPTarget):void
		{
			if (_freeze) {
				_listDeleted.push(parent);
				return;
			}
			var index:int = this._list.indexOf(parent);
			if (index != -1) {
				_list.splice(index, 1);
			}
			delete _priorities[parent];
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
		
		fpCallbackNS function add(parent:IFPTarget, priority:int=0):void
		{
			if (this._list.indexOf(parent) == -1) {
				this._list.push(parent);
			}
			this._priorities[parent] = priority;
			this._list.sort(this.sortPriority);
			//
			this._count = this._list.length;
		}
		
		private function sortPriority(parent1:IFPTarget, parent2:IFPTarget):int
		{
			var p1:int = this._priorities[parent1];
			var p2:int = this._priorities[parent2];
			if (p1 > p2) return -1;
			if (p1 < p2) return 1;
			return 0;
		}
	}
}