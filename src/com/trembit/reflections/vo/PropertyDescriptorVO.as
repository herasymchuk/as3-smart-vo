package com.trembit.reflections.vo {
public final class PropertyDescriptorVO {

	public var name:String;
	public var remoteName:String;
	public var fullType:String;
	public var collectionElementType:String;
	public var initializer:String;
	public var isTransient:Boolean;
    public var isSerialized:Boolean;
	public var defaultValue:*;

	public function PropertyDescriptorVO(name:String, remoteName:String, fullType:String, collectionElementType:String, initializer:String, isTransient:Boolean, isSerialized:Boolean, defaultValue:*) {
		super();
		this.name = name;
		this.fullType = fullType;
		this.remoteName = remoteName;
		this.collectionElementType = collectionElementType;
		this.initializer = initializer;
		this.isTransient = isTransient;
		this.isSerialized = isSerialized;
		this.defaultValue = defaultValue;
	}
}
}