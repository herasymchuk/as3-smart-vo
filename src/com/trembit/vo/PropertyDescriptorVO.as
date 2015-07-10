package com.trembit.vo {
public class PropertyDescriptorVO {

    public var name:String;
    public var remoteName:String;
    public var fullType:String;
    public var accessType:String;
    public var type:String;

	public function PropertyDescriptorVO(name:String, remoteName:String, type:String, fullType:String, accessType:String) {
		this.name = name;
		this.remoteName = remoteName;
		this.type = type;
		this.fullType = fullType;
		this.accessType = accessType;
	}
}
}
