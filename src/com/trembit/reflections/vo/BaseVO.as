package com.trembit.reflections.vo {

import com.trembit.reflections.util.ReflectionUtil;
import com.trembit.reflections.util.TransformerUtil;

import flash.events.EventDispatcher;

import mx.collections.ArrayCollection;

public class BaseVO extends EventDispatcher{

    public static function getInstanceType(baseClassObject:BaseVO, baseClassFullType:String, source:*):String{
        return baseClassObject.getItemType(baseClassFullType, source);
    }

    public static function create(source:Object, baseClass:Class, ignoreTransient:Boolean = true):* {
        return TransformerUtil.createItemByClass(source, baseClass, ignoreTransient);
    }

    public static function createVOCollection(source:Object, elementClass:Class, ignoreTransient:Boolean = true):ArrayCollection{
        return TransformerUtil.createCollectionByElementClass(source, elementClass, ignoreTransient);
    }

    private var thisClass:Class;

    public final function getClass():Class {
        if(thisClass) {
            return thisClass;
        }
        thisClass = ReflectionUtil.getClassByInstance(this);
        return thisClass;
    }

    public function setData(source:Object):void {
        if(!source){
            return;
        }
        copyProperties(source);
    }

    public final function clone():* {
        var voClass:Class = getClass();
        var item:BaseVO = BaseVO(new voClass());
        item.setData(this);
        return item;
    }

    public function equals(value:*):Boolean{
        return (this == value);
    }

    override public function toString():String {
        return '';
    }

    protected final function copyProperties(source:Object):void {
        TransformerUtil.populateItem(this, source, !(source is getClass()));
    }

    protected function getItemType(baseClassFullType:String, vo:*):String {
        return baseClassFullType;
    }

}
}
