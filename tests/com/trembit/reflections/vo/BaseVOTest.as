/**
 * Created with IntelliJ IDEA.
 * User: Andrey Assaul
 * Date: 13.07.2015
 * Time: 19:25
 */
package com.trembit.reflections.vo {
import com.trembit.reflections.vo.test.TestVO1;
import com.trembit.reflections.vo.test.TestVO2;
import com.trembit.reflections.vo.test.TestVO3;

import flexunit.framework.Assert;

import mx.collections.ArrayCollection;

public final class BaseVOTest {

	private static function getSource(prop1:int, prop2:uint, prop3:Number, prop4:String, prop5:Date, prop6:*, prop7:*, prop8:*, voType:int):Object{
		return {
			prop1:prop1,
			prop2:prop2,
			prop3:prop3,
			prop4:prop4,
			prop5:prop5,
			prop6:prop6,
			prop7:prop7,
			prop8:prop8,
			voType:voType,
			remote:"SET",
			testTrans:"SET",
			testInit:"SET",
			testIgnored:"SET"
		};
	}

	[Test]
	public function testGetClass():void {
		var vo:BaseVO = new BaseVO();
		Assert.assertNotNull(vo.getClass());
		Assert.assertEquals(vo.getClass(), BaseVO);
	}

	[Test]
	public function testCreate():void {
		var source:Object = getSource(1, 0xFFFF00, 36.5, "Hello World", new Date(), [
			getSource(2, 0xFF0000, NaN, "T2", null, null, null, null, 0),
			getSource(2, 0xFF0000, NaN, "T3", null, null, null, null, 1)
		], [1, 2, 3], [
			getSource(2, 0xFF0000, NaN, "T4", null, null, null, null, 1),
			getSource(2, 0xFF0000, NaN, "T5", null, null, null, null, 0)], -1);
		var vo:TestVO1 = BaseVO.create(source, TestVO1);
		Assert.assertNotNull(vo);
		Assert.assertEquals(vo.getClass(), TestVO1);
		Assert.assertTrue(vo.equals(source));
		Assert.assertEquals(vo.voType, source.voType.toString());
		Assert.assertTrue(vo.prop6[0] is TestVO2);
		Assert.assertTrue(vo.prop6[1] is TestVO3);
		Assert.assertTrue(vo.prop8[0] is TestVO3);
		Assert.assertTrue(vo.prop8[1] is TestVO2);
		Assert.assertEquals(vo.testRemote, source.remote);
		Assert.assertEquals(vo.testInit, vo.testInitializer(source));
		Assert.assertFalse(vo.testIgnored == source.testIgnored);
		Assert.assertFalse(vo.testTrans == source.testTrans);
		Assert.assertEquals(vo.prop6[0].testTrans, source.prop6[0].testTrans);
		source.prop3 = source.prop3.toString();
		vo = BaseVO.create(source, TestVO1, false);
		Assert.assertEquals(vo.prop3.toString(), source.prop3);
		Assert.assertEquals(vo.testTrans, source.testTrans);
	}

	[Test]
	public function testCreateVOCollection():void {
		var source:Array = [
			getSource(1, 0xFFFF00, 36.5, "Hello World", new Date(), [
				getSource(2, 0xFF0000, NaN, "T2", null, null, null, null, 0),
				getSource(2, 0xFF0000, NaN, "T3", null, null, null, null, 1)
			], [1, 2, 3], [
				getSource(2, 0xFF0000, NaN, "T4", null, null, null, null, 1),
				getSource(2, 0xFF0000, NaN, "T5", null, null, null, null, 0)], -1),
			getSource(2, 0xFF0000, NaN, "T6", null, null, null, null, 1)
		];
		var ac:ArrayCollection = BaseVO.createVOCollection(source, TestVO1);
		Assert.assertNotNull(ac);
		Assert.assertEquals(ac.length, source.length);
		Assert.assertEquals(ac[0].getClass(), TestVO1);
		Assert.assertTrue(ac[1] is TestVO3);
		Assert.assertTrue(ac[0].equals(source[0]));
		Assert.assertTrue(ac[1].equals(source[1]));
	}

	[Test]
	public function testSetData():void {
		var vo:TestVO1 = new TestVO1();
		var source:Object = getSource(1, 0xFFFF00, 36.5, "Hello World", new Date(), [
			getSource(2, 0xFF0000, NaN, "T2", null, null, null, null, 0),
			getSource(2, 0xFF0000, NaN, "T3", null, null, null, null, 1)
		], [1, 2, 3], [
			getSource(2, 0xFF0000, NaN, "T4", null, null, null, null, 1),
			getSource(2, 0xFF0000, NaN, "T5", null, null, null, null, 0)], -1);
		vo.setData(source);
		Assert.assertTrue(vo.equals(source));
		Assert.assertFalse(vo.testTrans == source.testTrans);
		var newVo:TestVO1 = new TestVO1();
		vo.testTrans = "Hello world";
		newVo.setData(vo);
		Assert.assertTrue(newVo.equals(vo));
		Assert.assertEquals(newVo.testTrans, vo.testTrans)
	}

	[Test]
	public function testClone():void {
		var vo:TestVO1 = new TestVO1();
		var source:Object = getSource(1, 0xFFFF00, 36.5, "Hello World", new Date(), [
			getSource(2, 0xFF0000, NaN, "T2", null, null, null, null, 0),
			getSource(2, 0xFF0000, NaN, "T3", null, null, null, null, 1)
		], [1, 2, 3], [
			getSource(2, 0xFF0000, NaN, "T4", null, null, null, null, 1),
			getSource(2, 0xFF0000, NaN, "T5", null, null, null, null, 0)], -1);
		vo.setData(source);
		var newVO:TestVO1 = vo.clone();
		Assert.assertNotNull(newVO);
		Assert.assertTrue(vo.equals(newVO));
	}

	[Test]
	public function testSynchronize():void {
		var source:Object = getSource(1, 0xFFFF00, 36.5, "Hello World", new Date(), [
			getSource(2, 0xFF0000, NaN, "T2", null, null, null, null, 0),
			getSource(2, 0xFF0000, NaN, "T3", null, null, null, null, 1)
		], [1, 2, 3], [
			getSource(2, 0xFF0000, NaN, "T4", null, null, null, null, 1),
			getSource(2, 0xFF0000, NaN, "T5", null, null, null, null, 0)], -1);
		var syncData:TestVO1 = BaseVO.create(source, TestVO1);
		syncData.testTrans = "HELLO";
		var data:TestVO3 = new TestVO3();
		data.synchronizeWith(syncData);
		Assert.assertEquals(data.prop1, syncData.prop1);
		Assert.assertEquals(data.prop2, syncData.prop2);
		Assert.assertEquals(data.prop3, syncData.prop3);
		Assert.assertEquals(data.prop4, syncData.prop4);
		Assert.assertEquals(data.prop5, syncData.prop5);
		Assert.assertEquals(data.prop6, syncData.prop6);
		Assert.assertEquals(data.prop7, syncData.prop7);
		Assert.assertEquals(data.prop8, syncData.prop8);
		Assert.assertEquals(data.voType, syncData.voType);
		Assert.assertEquals(data.testRemote, syncData.testRemote);
		Assert.assertEquals(data.testInit, syncData.testInit);
		Assert.assertNotNull(data.testVO3Property);
	}
}
}
