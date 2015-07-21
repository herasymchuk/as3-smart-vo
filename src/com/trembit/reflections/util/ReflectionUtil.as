package com.trembit.reflections.util {

import avmplus.DescribeTypeJSONCache;
import avmplus.INCLUDE_ACCESSORS;
import avmplus.INCLUDE_METADATA;
import avmplus.INCLUDE_TRAITS;
import avmplus.INCLUDE_VARIABLES;
import avmplus.USE_ITRAITS;

import com.trembit.reflections.consts.MetadataConsts;

import com.trembit.reflections.vo.PropertyDescriptorVO;

import flash.system.System;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;
import flash.utils.getQualifiedSuperclassName;

import mx.utils.DescribeTypeCache;

use namespace USE_ITRAITS;

use namespace INCLUDE_VARIABLES;

use namespace INCLUDE_ACCESSORS;

use namespace INCLUDE_TRAITS;

public final class ReflectionUtil {

    private static const classDescriptionDictionary:Dictionary = new Dictionary();
    private static const definitionByNameDict:Dictionary = new Dictionary();
    private static const DESCRIBE_TYPE_FLAGS:uint = INCLUDE_TRAITS | INCLUDE_ACCESSORS | INCLUDE_VARIABLES | INCLUDE_METADATA | USE_ITRAITS;

    public static function getProperties(classOfInterest:Class):Vector.<PropertyDescriptorVO> {
        var properties:Vector.<PropertyDescriptorVO>;
        if (classOfInterest in classDescriptionDictionary) {
            properties = classDescriptionDictionary[classOfInterest];
        } else {
            var descriptionOfClass:Object = DescribeTypeJSONCache.describeType(classOfInterest, DESCRIBE_TYPE_FLAGS);
            properties = new Vector.<PropertyDescriptorVO>();
            if(descriptionOfClass && descriptionOfClass.traits) {
                var item:Object;
                var descriptor:PropertyDescriptorVO;
                for each(item in descriptionOfClass.traits.accessors) {
                    descriptor = getPropertyDescriptor(item);
                    if(descriptor) {
                        properties.push(descriptor);
                    }
                }
                for each (item in descriptionOfClass.traits.variables) {
                    descriptor = getPropertyDescriptor(item);
                    if(descriptor) {
                        properties.push(descriptor);
                    }
                }
            }
            classDescriptionDictionary[classOfInterest] = properties;
        }
        return properties;
    }

    private static function getPropertyDescriptor(item:Object):PropertyDescriptorVO {
        var accessType:String = item.access;

        if(accessType == MetadataConsts.ACCESS_TYPE_READONLY || accessType == MetadataConsts.ACCESS_TYPE_WRITEONLY) return null;

        var propertyName:String = item.name;
        var remotePropertyName:String = propertyName;
        var propertyFullType:String = item.type;
        var collectionElementType:String;
        var initializer:String;
        var isTransient:Boolean;
        for each(var meta:Object in item.metadata) {
            switch (meta.name){
                case MetadataConsts.REMOTE_PROPERTY_NAME:
                    for each(var metaItem:Object in meta.value) {
                        switch (metaItem.key) {
                            case MetadataConsts.DEFAULT_KEY:
                            case MetadataConsts.REMOTE_PROPERTY_REMOTE_NAME_KEY:
                                remotePropertyName = String(metaItem.value);
                                break;
                            case MetadataConsts.REMOTE_PROPERTY_COLLECTION_ELEMENT_TYPE_KEY:
                                var lastDotIndex:int = metaItem.value.lastIndexOf(".");
                                var packageName:String = metaItem.value.substring(0, lastDotIndex);
                                var className:String = metaItem.value.substring(lastDotIndex+1);
                                collectionElementType = packageName + "::" + className;
                                break;
                            case MetadataConsts.REMOTE_PROPERTY_INITIALIZER_KEY:
                                initializer = String(metaItem.value);
                                break;
                        }
                    }
                    break;
                case MetadataConsts.TRANSIENT_NAME:
                    isTransient = true;
                    break;
                case MetadataConsts.IGNORED_NAME: return null;
            }
        }
        return new PropertyDescriptorVO(propertyName, remotePropertyName, propertyFullType, collectionElementType, initializer, isTransient);
    }

    public static function getDefinitionByName(name:String):Class {
        var o:Class;
        if (name in definitionByNameDict) {
            o = definitionByNameDict[name];
        } else {
            o = Class(flash.utils.getDefinitionByName(name.replace("::", ".")));
            definitionByNameDict[name] = o;
        }
        return o;
    }

    public static function getClassByInstance(instance:Object):Class {
        if (!instance) {
            return null;
        }
        return instance["constructor"] || getDefinitionByName(getQualifiedClassName(instance));
    }

    [Deprecated]
    public static function getPublicBooleanProperties(propertyType:*):Array {
        var description:XML = DescribeTypeCache.describeType(propertyType).typeDescription;
        var accessor:XMLList = description..accessor.(@access == MetadataConsts.ACCESS_TYPE_READWRITE && @type == "Boolean").@name;
        var result:Array = [];
        for each (var node:XML in accessor) {
            result.push(node.toString());
        }
        return result;
    }

    [Deprecated]
    static public function isOverridden(source:*, methodName:String):Boolean {
        var parentTypeName:String = getQualifiedSuperclassName(source);
        if (parentTypeName == null) {
            return false;
        }
        var typeName:String = getQualifiedClassName(source);
        var typeDesc:XML = DescribeTypeCache.describeType(getDefinitionByName(typeName)).typeDescription;
        var methodList:XMLList = typeDesc.factory.method.(@name == methodName);

        if (methodList.length() > 0) {
            //Method exists
            var methodData:XML = methodList[0];
            if (methodData.@declaredBy == typeName) {
                //Method is declared in self
                var parentTypeDesc:XML = DescribeTypeCache.describeType(getDefinitionByName(parentTypeName)).typeDescription;
                var parentMethodList:XMLList = parentTypeDesc.factory.method.(@name == methodName);
                return parentMethodList.length() > 0;
            }
        }

        return false;
    }
}
}