package com.trembit.reflections.util {
import avmplus.getQualifiedClassName;

import com.trembit.reflections.vo.PropertyDescriptorVO;

import flash.display.Sprite;

public class MatchUtil extends Sprite {

    public static function equals(input:*, output:*, strict:Boolean = true):Boolean {
        if (input == output) {
            return true;
        } else if ((input == null) || (output == null)) {
            return false;
        } else if (strict && getQualifiedClassName(input) != getQualifiedClassName(output)) {
            return false;
        } else if ((input is Array || isVector(input) || isArrayCollection(input)) && (output is Array || isVector(output) || isArrayCollection(output))) {
            return equalsArray(input, output, strict);
        } else if (((input is Function) && (output is Function)) || ((input is Class) && (output is Class))) {
            return false;
        } else if ((input is Number) && isNaN(input) && isNaN(output)) {
            return true;
        } else if (TransformerUtil.PRIMITIVE_TYPES.indexOf(getQualifiedClassName(input)) == -1) {
            return equalsObject(input, output, strict);
        }
        return false;
    }

    private static function equalsObject(input:Object, output:Object, strict:Boolean):Boolean {
        trace(ReflectionUtil.getClassByInstance(input));
        var properties:Vector.<PropertyDescriptorVO> = ReflectionUtil.getProperties(ReflectionUtil.getClassByInstance(input));
        for each(var item:PropertyDescriptorVO in properties) {
            if (item.isTransient) continue;
            if (item.initializer != null) {
                if(!equals(getValue(input, item), input[item.initializer](output), strict)) {
                    return false;
                }
            } else if (!equals(getValue(input, item), getValue(output, item), strict)) {
                return false;
            }
        }
        if (!properties.length) {
            for (var p:* in input) {
                if (!equals(input[p], output[p], strict)) {
                    return false;
                }
            }
        }
        return true;
    }

    private static function getValue(source:Object, descriptor:PropertyDescriptorVO):* {
        var value:* = null;
        if (source) {
            if (source.hasOwnProperty(descriptor.name)) {
                value = source[descriptor.name];
            } else if (source.hasOwnProperty(descriptor.remoteName)) {
                value = source[descriptor.remoteName];
            } else if (source.hasOwnProperty(descriptor.remoteName.toLowerCase())) {
                value = source[descriptor.remoteName.toLowerCase()];
            }
        }
        if(descriptor.isSerialized && value is String) {
            value = JSON.parse(value);
        }
        return value;
    }

    private static function equalsArray(input:*, output:*, strict:Boolean):Boolean {
        if (input.length != output.length) {
            return false;
        } else {
            for (var i:int = 0; i < input.length; i++) {
                if (!equals(getElementAt(input, i), getElementAt(output, i), strict)) {
                    return false;
                }
            }
        }
        return true;
    }

    private static function getElementAt(input:*, i:int):* {
        if (isArrayCollection(input)) {
            return input.getItemAt(i);
        } else {
            return input[i];
        }
    }


    private static function isVector(obj:Object):Boolean {
        //return (getQualifiedClassName(obj).indexOf('__AS3__.vec::Vector') == 0);
        return (obj is Vector.<*>
        || obj is Vector.<Number>
        || obj is Vector.<int>
        || obj is Vector.<uint>);
    }

    private static function isArrayCollection(obj:Object):Boolean {
        CONFIG::Flex {
            import mx.collections.ArrayCollection;

            return obj is ArrayCollection;
        }
        return false;
    }
}
}
