/**
 * Created with IntelliJ IDEA.
 * User: Andrey Assaul
 * Date: 14.07.2015
 * Time: 13:30
 */
package com.trembit.reflections.vo.test {
public class TestVO2 extends TestVO1{

	override public function get testTrans():String{
		return super.testTrans;
	}

	[Bindable]
	override public function set testTrans(value:String):void{
		super.testTrans = value;
	}
}
}
