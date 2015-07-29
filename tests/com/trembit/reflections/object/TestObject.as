/**
 * Created with IntelliJ IDEA.
 * User: Andrey Assaul
 * Date: 30.07.2015
 * Time: 2:00
 */
package com.trembit.reflections.object {
import com.trembit.reflections.util.TransformerUtil;
import com.trembit.reflections.vo.test.TestVO1;
import com.trembit.reflections.vo.test.TestVO2;
import com.trembit.reflections.vo.test.TestVO3;

import mx.collections.ArrayCollection;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertFalse;

import org.flexunit.asserts.assertTrue;

public class TestObject {

    private static function getSource(prop1:int, prop2:uint, prop3:Number, prop4:String, prop5:Date, prop6:*, prop7:*, prop8:*, prop9:Class, prop10:Function, prop11:*, voType:int):Object {
        return {
            prop1: prop1,
            prop2: prop2,
            prop3: prop3,
            prop4: prop4,
            prop5: prop5,
            prop6: prop6,
            prop7: prop7,
            prop8: prop8,
            prop9: prop9,
            prop10: prop10,
            prop11: prop11,
            voType: voType,
            remote: "SET",
            testTrans: "SET",
            testInit: "SET",
            testIgnored: "SET",
            testSerialized1: '{"prop1": "1", "prop2": "String"}',
            testSerialized2: "{}"
        };
    }

    [Bindable]
    public var prop1:int;
    public var prop2:uint;
    public var prop3:Number = 0;
    public var prop4:String;

    public var prop5:Date;

    [Bindable]
    public var prop6:Vector.<TestVO1>;

    public var prop7:Array;

    [RemoteProperty(collectionElementType="com.trembit.reflections.vo.test.TestVO1")]
    [Bindable]
    public var prop8:ArrayCollection;

    [RemoteProperty("remote")]
    public var testRemote:String;

    [RemoteProperty(initializer="testInitializer")]
    public var testInit:String;

    [Ignored]
    public var testIgnored:String = "NOT_SET";

    [Transient]
    public function testInitializer(object:Object):String {
        return "SET_FROM_INIT";
    }

    [Test]
    public function testPopulateObject():void{
        var source:Object = getSource(1, 0xFFFF00, 36.5, "Hello World", new Date(), [
            getSource(2, 0xFF0000, NaN, "T2", null, null, null, null, null, null, null, 0),
            getSource(2, 0xFF0000, NaN, "T3", null, null, null, null, null, null, null, 1)
        ], [1, 2, 3], [
            getSource(2, 0xFF0000, NaN, "T4", null, null, null, null, null, null, null, 1),
            getSource(2, 0xFF0000, NaN, "T5", null, null, null, null, null, null, null, 0)], null, null, null, -1);
        TransformerUtil.populateObject(this, TestObject, source);
        assertTrue(this.prop6[0] is TestVO2);
        assertTrue(this.prop6[1] is TestVO3);
        assertTrue(this.prop8[0] is TestVO3);
        assertTrue(this.prop8[1] is TestVO2);
        assertEquals(this.testRemote, source.remote);
        assertEquals(this.testInit, this.testInitializer(source));
        assertFalse(this.testIgnored == source.testIgnored);
        source.prop3 = source.prop3.toString();
        assertEquals(this.prop3.toString(), source.prop3);
        assertEquals(TestVO3(this.prop6[1]).testVO3Property, "NOT_SET");
        assertEquals(TestVO3(this.prop6[1]).testDefault1, "SET");
        assertEquals(TestVO3(this.prop6[1]).testDefault2, 2);
        assertEquals(TestVO3(this.prop6[1]).testDefault3, "");
    }
}
}