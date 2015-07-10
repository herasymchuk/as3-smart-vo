package com.trembit.vo {
import com.trembit.util.ReflectionUtil;

import flash.events.EventDispatcher;
import flash.utils.getQualifiedClassName;


import mx.collections.ArrayCollection;

public class BaseVO extends EventDispatcher{

    public static function create(source:Object, baseClass:Class):* {
        var className:String = getQualifiedClassName(baseClass);
        return getItem(source, className);
    }

    public function copyPropertiesFrom(source:Object):void {
        if (!source) {
            return;
        }
        setData(source);
    }

    public function setData(source:Object):void {
        copyProperties(source);
    }

    private function copyProperties(source:Object):void {
        var className:String = getQualifiedClassName(this);
        var properties:Vector.<PropertyDescriptorVO> = ReflectionUtil.getProperties(getClassByName(className));
        var propertyName:String;
        var remotePropertyName:String;
        //var propertyType:String;
        var propertyFullType:String;
        for each(var property:PropertyDescriptorVO in properties) {
            propertyName = property.name;
            remotePropertyName = property.remoteName;
            //propertyType = property.type;
            propertyFullType = property.fullType;

            if (!source.hasOwnProperty(remotePropertyName)) {
                remotePropertyName = remotePropertyName.toLowerCase();
                if (!source.hasOwnProperty(remotePropertyName)) {
                    remotePropertyName = propertyName;
                    if (!source.hasOwnProperty(propertyName)) {
                        continue;
                    }
                }
            }

            this[propertyName] = getItem(source[remotePropertyName], propertyFullType);
        }
    }

    private static function getItem(source:*, propertyType:String):* {
        var res:* = null;
        if (source != null) {
            if (ReflectionUtil.isPrimitiveType(propertyType)) {
                res = source;
            } else if (ReflectionUtil.isVector(propertyType)) {
                res = getVector(source, propertyType);
            } else if (ReflectionUtil.isCustomVO(propertyType)) {
                res = getVOItem(source, propertyType);
            } else if (propertyType == "ArrayCollection") {
                //can store only primitive types!
                res = new ArrayCollection(source);
            }
        }
        return res;
    }


    private static function getVector(source:*, propertyType:String):* {
        var destArray:Array = [];
        var vectorItemType:String = propertyType.substring(propertyType.indexOf("<") + 1, propertyType.lastIndexOf(">"));
        var item:* = null;
        for each(var arrayItem:* in source) {
            item = getItem(arrayItem, vectorItemType);
            if (item != null) {
                destArray.push(item);
            }
        }
        return createVector(getClassByName(vectorItemType), destArray);
    }

    private static function createVector(cls:Class, sourceArray:Array):* {
        var className:String = getQualifiedClassName(cls);
        var vectorClass:Class = getClassByName("__AS3__.vec::Vector.<" + className + ">");

        var vector:* = new vectorClass(sourceArray.length);
        for (var i:int = 0; i < sourceArray.length; i++) {
            vector[i] = sourceArray[i];
        }

        return vector;
    }

    private static function getVOItem(source:*, baseClassFullType:String):* {
        //TODO:optimize
        var voClass:Class = getItemClass(baseClassFullType, source); //getClassByName(getItemType(baseClassFullType, source));//
        var item:* = new voClass();
        (item as BaseVO).copyPropertiesFrom(source);
        return item;
    }

    private static function getItemClass(baseClassFullType:String, source:*):Class {
        var voClass:Class = Class(ReflectionUtil.getDefinitionByName(baseClassFullType));
        return getClassByName((new voClass() as BaseVO).getItemType(baseClassFullType, source));
    }

    protected function getItemType(baseClassFullType:String, vo:*):String {
        return baseClassFullType;
    }

    private static function getClassByName(className:String):Class {
        return Class(ReflectionUtil.getDefinitionByName(className));
    }

    override public function toString():String {
        return '';
    }

}
}
