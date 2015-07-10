package avmplus {

import flash.utils.getDefinitionByName;

public class DescribeTypeJSONCache {

	public static var available : Boolean = describeTypeJSON != null;

	private static var typeCache:Object = {};

	public static function describeType(o:*, flags:uint):Object {
		var className:String;
		var cacheKey:String;

		if (o is String)
			cacheKey = className = o;
		else
			cacheKey = className = getQualifiedClassName(o);

		//Need separate entries for describeType(Foo) and describeType(myFoo)
		if (o is Class)
			cacheKey += "$";

		if (cacheKey in typeCache) {
			return typeCache[cacheKey];
		}
		else {
			if (o is String) {
				try {
					o = getDefinitionByName(o);
				}
				catch (error:ReferenceError) {
					// The o parameter doesn't refer to an ActionScript
					// definition, it's just a string value.
				}
			}
			var typeDescription:Object = describeTypeJSON(o, flags);
			typeCache[cacheKey] = typeDescription;

			return typeDescription;
		}
	}


	public static const INSTANCE_FLAGS:uint = INCLUDE_BASES | INCLUDE_INTERFACES
			| INCLUDE_VARIABLES | INCLUDE_ACCESSORS | INCLUDE_METHODS | INCLUDE_METADATA
			| INCLUDE_CONSTRUCTOR | INCLUDE_TRAITS | USE_ITRAITS | HIDE_OBJECT;
	public static const CLASS_FLAGS:uint = INCLUDE_INTERFACES | INCLUDE_VARIABLES
			| INCLUDE_ACCESSORS | INCLUDE_METHODS | INCLUDE_METADATA | INCLUDE_TRAITS | HIDE_OBJECT;

	public static function getInstanceDescription(type : Class) : Object
	{
		return describeTypeJSON(type, INSTANCE_FLAGS);
	}

	public static function getClassDescription(type : Class) : Object
	{
		return describeTypeJSON(type, CLASS_FLAGS);
	}
}

}
