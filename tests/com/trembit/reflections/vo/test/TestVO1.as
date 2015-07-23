/**
 * Created with IntelliJ IDEA.
 * User: Andrey Assaul
 * Date: 14.07.2015
 * Time: 13:30
 */
package com.trembit.reflections.vo.test {
import com.trembit.reflections.util.MatchUtil;
import com.trembit.reflections.vo.BaseVO;

import flash.utils.getQualifiedClassName;

import mx.collections.ArrayCollection;

public class TestVO1 extends BaseVO {

    protected static function collectionEquals(source:*, vo:*):Boolean {
        if (vo == null && source == null) {
            return true;
        }
        if (vo == null || source == null) {
            return false;
        }
        if (vo.length != source.length) {
            return false;
        }
        var l:int = vo.length;
        for (var i:int = 0; i < l; i++) {
            var item:BaseVO = vo[i] as BaseVO;
            if (item) {
                if (!item.equals(source[i])) {
                    return false;
                }
            } else {
                if (vo[i] != source[i]) {
                    return false;
                }
            }
        }
        return true;
    }

    protected static function dateEquals(d1:Date, d2:Date):Boolean {
        if (d1 == null && d2 == null) {
            return true;
        }
        if (d1 == null || d2 == null) {
            return false;
        }
        return (d1.time == d2.time);
    }

    private var _testTrans:String = "NOT_SET";

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

    public var prop9:Class;

    public var prop10:Function;

    public var prop11:*;

    [Serialized]
    public var testSerialized1:Object;

    [Serialized]
    public var testSerialized2:Object;

    public var voType:String;

    [RemoteProperty("remote")]
    public var testRemote:String;

    [RemoteProperty(initializer="testInitializer")]
    public var testInit:String;

    [Ignored]
    public var testIgnored:String = "NOT_SET";

    public function testInitializer(object:Object):String {
        if (object is getClass()) {
            return object.testInit;
        }
        return "SET_FROM_INIT";
    }

    public function get testTrans():String {
        return _testTrans;
    }

    [Transient]
    [Bindable]
    public function set testTrans(value:String):void {
        _testTrans = value;
    }

    override protected function getItemType(baseClassFullType:String, vo:*):String {
        if (vo is TestVO2) {
            return getQualifiedClassName(TestVO2);
        }
        if (vo is TestVO3) {
            return getQualifiedClassName(TestVO3);
        }
        if (vo.hasOwnProperty("voType")) {
            switch (vo.voType.toString()) {
                case "0":
                    return getQualifiedClassName(TestVO2);
                case "1":
                    return getQualifiedClassName(TestVO3);
                default:
                    return getQualifiedClassName(TestVO1);
            }
        }
        if (vo is TestVO1) {
            return getQualifiedClassName(vo);
        }
        return baseClassFullType;
    }

    override public function equals(value:*):Boolean {
        return (value &&
        value.prop1 == prop1 &&
        value.prop2 == prop2 &&
        (value.prop3 == prop3 || isNaN(value.prop3) && isNaN(prop3)) &&
        value.prop4 == prop4 &&
        value.prop9 == prop9 &&
        value.prop10 == prop10 &&
        MatchUtil.equals(value.prop11, prop11) &&
        dateEquals(value.prop5, prop5) &&
        collectionEquals(value.prop6, prop6) &&
        collectionEquals(value.prop7, prop7) &&
        collectionEquals(value.prop8, prop8)
        );
    }
}
}
