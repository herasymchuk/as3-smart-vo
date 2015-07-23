package com.trembit.reflections.util {
import com.trembit.reflections.vo.BaseVO;
import com.trembit.reflections.vo.test.TestVO1;
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertTrue;

public class MatchUtilTest {

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


    [Test]
    public function equalsTest():void {
        assertTrue(MatchUtil.equals(5, 5));
        assertTrue(MatchUtil.equals([1, new Object()], [1, new Object()]));

        var s:Object = getSource(2, 0xFF0000, NaN, "T2", new Date(), null, null, null, TestVO1, equalsTest, {
            prop: 1,
            prop2: "String",
            prop3: new BaseVO()
        }, 0);
        var s2:Object = getSource(2, 0xFF0000, NaN, "T2", new Date(), null, null, null, TestVO1, getSource, {
            prop: 1,
            prop2: "String",
            prop3: new BaseVO()
        }, 0);
        var vo1:TestVO1 = BaseVO.create(s, TestVO1);
        var vo2:TestVO1 = BaseVO.create(s, TestVO1);
        assertFalse(MatchUtil.equals(s, BaseVO.create(s, TestVO1)));
        assertTrue(MatchUtil.equals(vo1, vo2));
        assertFalse(MatchUtil.equals(s, s2));

        var source:Object = getSource(1, 0xFFFF00, 36.5, "Hello World", new Date(), [
            getSource(2, 0xFF0000, NaN, "T2", null, null, null, null, null, null, {prop: 1, prop2: "String"}, -1),
            getSource(2, 0xFF0000, NaN, "T3", null, null, null, null, null, null, {prop: 1, prop2: "String"}, -1)
        ], [1, 2, 3], [
            getSource(2, 0xFF0000, NaN, "T4", null, null, null, null, null, null, {prop: 1, prop2: "String"}, -1),
            getSource(2, 0xFF0000, NaN, "T5", null, null, null, null, null, null, {
                prop: 1,
                prop2: "String"
            }, 0)], MatchUtilTest, getSource, {prop: 1, prop2: "String", prop3: new BaseVO()}, -1);
        assertTrue(MatchUtil.equals(BaseVO.create(source, TestVO1), source, false));
    }
}
}
