/**
 * Created with IntelliJ IDEA.
 * User: Andrey Assaul
 * Date: 10.07.2015
 * Time: 21:33
 */
package com.trembit.reflections.consts {
public final class MetadataConsts {

	public static const DEFAULT_KEY:String = "";

	public static const IGNORED_NAME:String = "Ignored";
	public static const TRANSIENT_NAME:String = "Transient";
	public static const REMOTE_PROPERTY_NAME:String = "RemoteProperty";

	public static const REMOTE_PROPERTY_REMOTE_NAME_KEY:String = "remoteName";
	public static const REMOTE_PROPERTY_COLLECTION_ELEMENT_TYPE_KEY:String = "collectionElementType";
	public static const REMOTE_PROPERTY_INITIALIZER_KEY:String = "initializer";
	public static const REMOTE_PROPERTY_DEFAULT_VALUE_KEY:String = "defaultValue";

	public static const ACCESS_TYPE_READONLY:String = "readonly";
	public static const ACCESS_TYPE_WRITEONLY:String = "writeonly";
	public static const ACCESS_TYPE_READWRITE:String = "readwrite";

	public function MetadataConsts() {
		throw new Error("MetadataConsts is static and should not be instantiated");
	}
}
}