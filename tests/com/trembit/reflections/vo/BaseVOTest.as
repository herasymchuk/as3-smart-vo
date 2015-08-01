/**
 * Created with IntelliJ IDEA.
 * User: Andrey Assaul
 * Date: 13.07.2015
 * Time: 19:25
 */
package com.trembit.reflections.vo {
import com.trembit.reflections.util.MatchUtil;
import com.trembit.reflections.util.TransformerUtil;
import com.trembit.reflections.vo.test.TestVO1;
import com.trembit.reflections.vo.test.TestVO2;
import com.trembit.reflections.vo.test.TestVO3;

import mx.collections.ArrayCollection;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertNotNull;
import org.flexunit.asserts.assertTrue;

import spark.formatters.DateTimeFormatter;

public final class BaseVOTest {

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
            testDefault1: null,
            testDefault2: NaN,
            testIgnored: "SET",
            testSerialized1: '{"prop1": "1", "prop2": "String"}',
            testSerialized2: null
        };
    }

    [Test]
    public function testGetClass():void {
        var vo:BaseVO = new BaseVO();
        assertNotNull(vo.getClass());
        assertEquals(vo.getClass(), BaseVO);
    }

    [Test]
    public function testCreate():void {
        var source:Object = getSource(1, 0xFFFF00, 36.5, "Hello World", new Date(), [
            getSource(2, 0xFF0000, NaN, "T2", null, null, null, null, null, null, {prop: 1, prop2: "String"}, 0),
            getSource(2, 0xFF0000, NaN, "T3", null, null, null, null, null, null, {prop: 1, prop2: "String"}, 1)
        ], [1, 2, 3], [
            getSource(2, 0xFF0000, NaN, "T4", null, null, null, null, null, null, {prop: 1, prop2: "String"}, 1),
            getSource(2, 0xFF0000, NaN, "T5", null, null, null, null, null, null, null, 0)], BaseVOTest, getSource, {
            prop: 1,
            prop2: "String"
        }, -1);
        var vo:TestVO1 = BaseVO.create(source, TestVO1);
        assertNotNull(vo);
        assertEquals(vo.getClass(), TestVO1);
        assertTrue(vo.equals(source));
        assertEquals(vo.voType, source.voType.toString());
        assertTrue(vo.prop6[0] is TestVO2);
        assertTrue(vo.prop6[1] is TestVO3);
        assertTrue(vo.prop8[0] is TestVO3);
        assertTrue(vo.prop8[1] is TestVO2);
        assertEquals(vo.testRemote, source.remote);
        assertEquals(vo.testInit, vo.testInitializer(source));
        assertFalse(vo.testIgnored == source.testIgnored);
        assertFalse(vo.testTrans == source.testTrans);
        assertEquals(vo.prop6[0].testTrans, source.prop6[0].testTrans);
        source.prop3 = source.prop3.toString();
        vo = BaseVO.create(source, TestVO1, false);
        assertEquals(vo.prop3.toString(), source.prop3);
        assertEquals(vo.testTrans, source.testTrans);
        assertEquals(TestVO3(vo.prop6[1]).testVO3Property, "NOT_SET");
        assertEquals(TestVO3(vo.prop6[1]).testDefault1, "SET");
        assertEquals(TestVO3(vo.prop6[1]).testDefault2, 2);
        assertEquals(TestVO3(vo.prop6[1]).testDefault3, "");
    }

    [Test]
    public function testCreateArray():void {
        var source:Array = [
            getSource(1, 0xFFFF00, 36.5, "Hello World", new Date(),
                    [
                        getSource(2, 0xFF0000, NaN, "T2", null, null, null, null, null, null, null, 0),
                        getSource(2, 0xFF0000, NaN, "T3", null, null, null, null, null, null, null, 1)
                    ],
                    [1, 2, 3], [
                        getSource(2, 0xFF0000, NaN, "T4", null, null, null, null, null, null, null, 1),
                        getSource(2, 0xFF0000, NaN, "T5", null, null, null, null, null, null, null, 0)],
                    BaseVOTest, getSource, null, -1),
            getSource(2, 0xFF0000, NaN, "T6", null, null, null, null, null, null, null, 1)
        ];
        var a:Array = BaseVO.createArray(source, TestVO1);
        assertNotNull(a);
        assertEquals(a.length, source.length);
        assertEquals(a[0].getClass(), TestVO1);
        assertTrue(a[1] is TestVO3);
        assertTrue(a[0].equals(source[0]));
        assertTrue(a[1].equals(source[1]));

        source = [1, 2, "String", {prop1: 1, prop2: "String"}];
        a = BaseVO.createArray(source);
        assertNotNull(a);
        assertEquals(a.length, source.length);
        assertTrue(a[1] == source[1]);
        assertTrue(a[2] is String);
        assertTrue(MatchUtil.equals(a[3], source[3]));
    }

    [Test]
    public function testCreateVOCollection():void {
        var source:Array = [
            getSource(1, 0xFFFF00, 36.5, "Hello World", new Date(), [
                getSource(2, 0xFF0000, NaN, "T2", null, null, null, null, null, null, null, 0),
                getSource(2, 0xFF0000, NaN, "T3", null, null, null, null, null, null, null, 1)
            ], [1, 2, 3], [
                getSource(2, 0xFF0000, NaN, "T4", null, null, null, null, null, null, null, 1),
                getSource(2, 0xFF0000, NaN, "T5", null, null, null, null, null, null, null, 0)], BaseVOTest, getSource, null, -1),
            getSource(2, 0xFF0000, NaN, "T6", null, null, null, null, null, null, null, 1)
        ];
        var ac:ArrayCollection = BaseVO.createVOCollection(source, TestVO1);
        assertNotNull(ac);
        assertEquals(ac.length, source.length);
        assertEquals(ac[0].getClass(), TestVO1);
        assertTrue(ac[1] is TestVO3);
        assertTrue(ac[0].equals(source[0]));
        assertTrue(ac[1].equals(source[1]));
    }

    [Test]
    public function testCopyProperties():void {
        var vo:TestVO1 = new TestVO1();
        var source:Object = getSource(1, 0xFFFF00, 36.5, "Hello World", new Date(), [
            getSource(2, 0xFF0000, NaN, "T2", null, null, null, null, null, null, null, 0),
            getSource(2, 0xFF0000, NaN, "T3", null, null, null, null, null, null, null, 1)
        ], [1, 2, 3], [
            getSource(2, 0xFF0000, NaN, "T4", null, null, null, null, null, null, null, 1),
            getSource(2, 0xFF0000, NaN, "T5", null, null, null, null, null, null, null, 0)], BaseVOTest, getSource, null, -1);
        vo.copyProperties(source);
        assertTrue(vo.equals(source));
        assertFalse(vo.testTrans == source.testTrans);
        var newVo:TestVO1 = new TestVO1();
        var obj:Object = {prop1: 10, prop2:"String"};
        vo.testTrans = "Hello world";
        vo.testSerialized1 = JSON.stringify(obj);
        vo.testSerialized2 = obj;
        newVo.copyProperties(vo);
        assertTrue(newVo.equals(vo));
        assertEquals(newVo.testTrans, vo.testTrans);

        assertTrue(MatchUtil.equals(newVo.testSerialized1, obj));
        assertEquals(vo.testSerialized2, newVo.testSerialized2);
    }

    [Test]
    public function testClone():void {
        var vo:TestVO1 = new TestVO1();
        var source:Object = getSource(1, 0xFFFF00, 36.5, "Hello World", new Date(), [
            getSource(2, 0xFF0000, NaN, "T2", null, null, null, null, null, null, null, 0),
            getSource(2, 0xFF0000, NaN, "T3", null, null, null, null, null, null, null, 1)
        ], [1, 2, 3], [
            getSource(2, 0xFF0000, NaN, "T4", null, null, null, null, null, null, null, 1),
            getSource(2, 0xFF0000, NaN, "T5", null, null, null, null, null, null, null, 0)], BaseVOTest, getSource, null, -1);
        vo.copyProperties(source);
        var newVO:TestVO1 = vo.clone();
        assertNotNull(newVO);
        assertTrue(vo.equals(newVO));
    }

    [Test]
    public function testSynchronize():void {
        var source:Object = getSource(1, 0xFFFF00, 36.5, "Hello World", new Date(), [
            getSource(2, 0xFF0000, NaN, "T2", null, null, null, null, null, null, null, 0),
            getSource(2, 0xFF0000, NaN, "T3", null, null, null, null, null, null, null, 1)
        ], [1, 2, 3], [
            getSource(2, 0xFF0000, NaN, "T4", null, null, null, null, null, null, null, 1),
            getSource(2, 0xFF0000, NaN, "T5", null, null, null, null, null, null, null, 0)], BaseVOTest, getSource, null, -1);
        var syncData:TestVO1 = BaseVO.create(source, TestVO1);
        syncData.testTrans = "HELLO";
        var data:TestVO3 = new TestVO3();
        data.synchronizeWith(syncData);
        assertEquals(data.prop1, syncData.prop1);
        assertEquals(data.prop2, syncData.prop2);
        assertEquals(data.prop3, syncData.prop3);
        assertEquals(data.prop4, syncData.prop4);
        assertEquals(data.prop5, syncData.prop5);
        assertEquals(data.prop6, syncData.prop6);
        assertEquals(data.prop7, syncData.prop7);
        assertEquals(data.prop8, syncData.prop8);
        assertEquals(data.prop9, syncData.prop9);
        assertEquals(data.prop10, syncData.prop10);
        assertEquals(data.prop11, syncData.prop11);
        assertEquals(data.voType, syncData.voType);
        assertEquals(data.testRemote, syncData.testRemote);
        assertEquals(data.testInit, syncData.testInit);
        assertNotNull(data.testVO3Property);
    }

    [Test]
    public function testUpperCasedSource():void{
        var source:Object = {"Prop1":100};
        var vo:TestVO1 = BaseVO.create(source, TestVO1);
        assertEquals(vo.prop1, 100);
    }

    [Test]
    public function testDateParser():void{
        var source:Object = {prop5:"Sat Nov 30 1974"};
        TransformerUtil.dateParseFunction = function(value:String):Date{return new Date(Date.parse(value));};
        var vo:TestVO1 = BaseVO.create(source, TestVO1);
        assertNotNull(vo.prop5);
        assertEquals(vo.prop5.time, 155030400000);
        vo = vo.clone();
        assertNotNull(vo.prop5);
        assertEquals(vo.prop5.time, 155030400000);
    }
}
}
