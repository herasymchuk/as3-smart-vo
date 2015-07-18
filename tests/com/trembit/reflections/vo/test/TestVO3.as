/**
 * Created with IntelliJ IDEA.
 * User: Andrey Assaul
 * Date: 14.07.2015
 * Time: 13:30
 */
package com.trembit.reflections.vo.test {
public class TestVO3 extends TestVO1{

	public var testVO3Property:String = "NOT_SET";

	[RemoteProperty(defaultValue="SET")]
	public var testDefault1:String = "NOT_SET";

	[RemoteProperty(defaultValue="2")]
	public var testDefault2:Number = 1;

	[RemoteProperty(defaultValue="")]
	public var testDefault3:String = "NOT_SET";
}
}
