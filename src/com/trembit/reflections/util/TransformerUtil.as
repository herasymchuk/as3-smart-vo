/**
 * Created with IntelliJ IDEA.
 * User: Andrey Assaul
 * Date: 11.07.2015
 * Time: 20:36
 */
package com.trembit.reflections.util {


import com.trembit.reflections.vo.BaseVO;
import com.trembit.reflections.vo.PropertyDescriptorVO;

import flash.utils.Dictionary;

import flash.utils.getQualifiedClassName;

import mx.collections.ArrayCollection;

public final class TransformerUtil {

	private static const PRIMITIVE_TYPES:Array = ["String", "Number", "int", "Boolean", "uint", "Class", "Function"];
	private static const ARRAY_COLLECTION_TYPE:String = getQualifiedClassName(ArrayCollection);
	private static const DATE_TYPE:String = getQualifiedClassName(Date);
	private static const ARRAY_TYPE:String = getQualifiedClassName(Array);

	private static const SUPPORT_PAIRS:Array = [];

	private static const DISCRIMINATOR_OBJECTS:Dictionary = new Dictionary();

	public static var dateParseFunction:Function;

	public static function populateItem(item:BaseVO, source:Object, ignoreTransient:Boolean):void{
		var pair:ItemClassPair = getItemClassPair();
		pair.setData(item, item.getClass());
		populateItemByClass(pair, source, ignoreTransient);
		pair.clean();
	}

	public static function createItemByClass(source:*, itemClass:Class, ignoreTransient:Boolean):*{
		return getItem(source, getQualifiedClassName(itemClass), ignoreTransient);
	}

	public static function createCollectionByElementClass(source:*, elementClass:Class, ignoreTransient:Boolean):ArrayCollection {
		return getItem(source, ARRAY_COLLECTION_TYPE, ignoreTransient, getQualifiedClassName(elementClass));
	}

	private static function populateItemByClass(pair:ItemClassPair, source:Object, ignoreTransient:Boolean):void{
		var properties:Vector.<PropertyDescriptorVO> = ReflectionUtil.getProperties(pair.itemClass);
		var propertyName:String;
		var remotePropertyName:String;
		var propertyFullType:String;
		var item:* = pair.item;
		for each(var property:PropertyDescriptorVO in properties) {
			if(property.isTransient && ignoreTransient){
				continue;
			}
			propertyName = property.name;
			if(property.initializer != null){
				item[propertyName] = item[property.initializer](source);
			} else {
				remotePropertyName = property.remoteName;
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
				item[propertyName] = getItem(source[remotePropertyName], propertyFullType, ignoreTransient, property.collectionElementType);
			}
		}
	}

	private static function getItemClassPair():ItemClassPair{
		for each (var pair:ItemClassPair in SUPPORT_PAIRS) {
			if(!pair.inUse){
				pair.inUse = true;
				return pair;
			}
		}
		pair = new ItemClassPair();
		SUPPORT_PAIRS[SUPPORT_PAIRS.length] = pair;
		pair.inUse = true;
		return pair;
	}

	private static function getItem(source:*, propertyType:String, ignoreTransient:Boolean, collectionElementType:String = null):* {
		var res:* = null;
		if (source != null) {
			if (PRIMITIVE_TYPES.indexOf(propertyType) > -1) {
				res = source;
			} else if(propertyType == DATE_TYPE) {
				res = (dateParseFunction != null)?dateParseFunction(source):source;
			} else if ((propertyType.indexOf("__AS3__.vec::Vector") == 0) || (propertyType.indexOf("Vector.<") == 0)) {
				res = getVector(source, propertyType, ignoreTransient);
			} else if (propertyType == ARRAY_COLLECTION_TYPE) {
				res = getCollection(source, collectionElementType, ignoreTransient);
			} else if (propertyType == ARRAY_TYPE) {
				res = getArray(source, collectionElementType, ignoreTransient);
			} else {
				res = getObject(source, propertyType, ignoreTransient);
			}
		}
		return res;
	}

	private static function getArray(source:*, collectionElementType:String, ignoreTransient:Boolean):Array {
		var resArray:Array = [];
		var object:Object;
		var currentIndex:int = 0;
		if(!collectionElementType){
			for each (object in source) {
				resArray[currentIndex] = object;
				currentIndex++;
			}
		} else {
			for each (object in source) {
				var item:* = getItem(object, collectionElementType, ignoreTransient);
				if(item != null){
					resArray[currentIndex] = getItem(object, collectionElementType, ignoreTransient);
					currentIndex++;
				}
			}
		}
		return resArray;
	}

	private static function getCollection(source:*, collectionElementType:String, ignoreTransient:Boolean):ArrayCollection {
		return new ArrayCollection(getArray(source, collectionElementType, ignoreTransient));
	}

	private static function getVector(source:*, propertyType:String, ignoreTransient:Boolean):* {
		var vectorItemType:String = propertyType.substring(propertyType.indexOf("<") + 1, propertyType.lastIndexOf(">"));
		return createVector(ReflectionUtil.getDefinitionByName(vectorItemType), getArray(source, vectorItemType, ignoreTransient));
	}

	private static function createVector(cls:Class, sourceArray:Array):* {
		var className:String = getQualifiedClassName(cls);
		var vectorClass:Class =  ReflectionUtil.getDefinitionByName("__AS3__.vec::Vector.<" + className + ">");
		var vector:* = new vectorClass(sourceArray.length);
		for (var i:int = 0; i < sourceArray.length; i++) {
			vector[i] = sourceArray[i];
		}
		return vector;
	}

	private static function createObject(baseClassFullType:String, source:*):ItemClassPair {
		var discriminator:BaseVO = DISCRIMINATOR_OBJECTS[baseClassFullType];
		var voClass:Class;
		var item:BaseVO;
		var pair:ItemClassPair = getItemClassPair();
		if(discriminator){
			voClass = ReflectionUtil.getDefinitionByName(BaseVO.getInstanceType(discriminator, baseClassFullType, source));
			item = BaseVO(new voClass());
		} else{
			voClass = ReflectionUtil.getDefinitionByName(baseClassFullType);
			var baseItem:* = new voClass();
			if(!(baseItem is BaseVO)){
				pair.setData(baseItem, voClass);
				return pair;
			}
			item = BaseVO(baseItem);
			var itemType:String = BaseVO.getInstanceType(item, baseClassFullType, source);
			if(itemType != baseClassFullType){
				voClass = ReflectionUtil.getDefinitionByName(itemType);
				DISCRIMINATOR_OBJECTS[baseClassFullType] = item;
				item = BaseVO(new voClass());
			}
		}
		pair.setData(item, voClass);
		return pair;
	}

	private static function getObject(source:*, baseClassFullType:String, ignoreTransient:Boolean):* {
		var pair:ItemClassPair = createObject(baseClassFullType, source);
		var item:* = pair.item;
		populateItemByClass(pair, source, ignoreTransient);
		pair.clean();
		return item;
	}

	public function TransformerUtil() {
		throw new Error("TransformerUtil is static and should not be instantiated");
	}
}
}

internal class ItemClassPair {

	public var item:*;
	public var itemClass:Class;
	public var inUse:Boolean;

	public function clean():void{
		item = null;
		itemClass = null;
		inUse = false;
	}

	public function setData(item:*, itemClass:Class):void{
		this.item = item;
		this.itemClass = itemClass;
	}
}