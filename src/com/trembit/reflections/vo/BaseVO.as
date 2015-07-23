package com.trembit.reflections.vo {

import com.trembit.reflections.util.ReflectionUtil;
import com.trembit.reflections.util.TransformerUtil;

import flash.events.EventDispatcher;

public class BaseVO extends EventDispatcher{

    public static function getInstanceType(baseClassObject:BaseVO, baseClassFullType:String, source:*):String{
        return baseClassObject.getItemType(baseClassFullType, source);
    }

    public static function create(source:Object, baseClass:Class, ignoreTransient:Boolean = true):* {
        return TransformerUtil.createItemByClass(source, baseClass, ignoreTransient);
    }

	public static function createArray(source:Object, elementClass:Class = null, ignoreTransient:Boolean = true):Array{
		return TransformerUtil.createArrayByElementClass(source, elementClass, ignoreTransient);
	}

    CONFIG::Flex {
        import mx.collections.ArrayCollection;
        public static function createVOCollection(source:Object, elementClass:Class, ignoreTransient:Boolean = true):ArrayCollection{
            return TransformerUtil.createCollectionByElementClass(source, elementClass, ignoreTransient);
        }
    }

    private var thisClass:Class;

    public final function getClass():Class {
        if(thisClass) {
            return thisClass;
        }
        thisClass = ReflectionUtil.getClassByInstance(this);
        return thisClass;
    }

    public final function clone():* {
        return create(this, getClass(), false);
    }

    public function synchronizeWith(source:*):void{
        var properties:Vector.<PropertyDescriptorVO> = ReflectionUtil.getProperties(getClass());
        for each (var propertyDescriptorVO:PropertyDescriptorVO in properties) {
            var propertyName:String = propertyDescriptorVO.name;
            if(propertyName in source){
                this[propertyName] = source[propertyName];
            }
        }
    }

    public function equals(value:*):Boolean{
        return (this == value);
    }

    override public function toString():String {
        return '';
    }

    public final function copyProperties(source:Object):void {
        TransformerUtil.populateItem(this, source, !(source is getClass()));
    }

    protected function getItemType(baseClassFullType:String, vo:*):String {
        return baseClassFullType;
    }
}
}
