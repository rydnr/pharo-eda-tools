Class {
	#name : #EDATCommandGenerator,
	#superclass : #EDATGenerator,
	#category : #'EDAT-Tools'
}

{ #category : #sorting }
EDATCommandGenerator class >> priority [

	^ 50
]

{ #category : #'code generation' }
EDATCommandGenerator >> createCommandClass [

	| cls attributes |
	cls := self retrieveCommandClassName asSymbol.
	attributes := self retrieveCommandAttributesBut:
		              self class skippedCommandAttributes.
	(self classExists: cls) ifTrue: [ 
		attributes := self
			              allAttributesOf: (self class environment at: cls)
			              including: attributes ].
	EDACommand
		subclass: self retrieveCommandClassName asSymbol
		instanceVariableNames:
		(self concatenateCollection: attributes with: ' ')
		classVariableNames: ''
		package: self retrieveCommandPackage
]

{ #category : #'code generation' }
EDATCommandGenerator >> createCommandClassAccessors [
	| commandClass |
	commandClass := self class environment at: self retrieveCommandClassName asSymbol.
	(self generateAccessorsFor: commandClass attributes: (self retrieveCommandAttributesBut: self class skippedCommandAttributes))
		associationsDo: [ :assoc | 
			self
				compile: assoc key
				sourceCode: assoc value
				inClass: commandClass
				classifiedAs: self protocol ]
]

{ #category : #'code generation' }
EDATCommandGenerator >> createCommandClassAggregateRootClassMethod [
	| aggregateRootClass |
	aggregateRootClass := self class environment at: self retrieveCommandClassName asSymbol.
	^ self
		compile: self generateCommandClassAggregateRootClassMethodName
		sourceCode: self generateCommandClassAggregateRootClassMethod
		inClass: aggregateRootClass class
		classifiedAs: self protocol
]

{ #category : #'code generation' }
EDATCommandGenerator >> createCommandClassBuilderMethod [
	| methodAssoc |
	methodAssoc := self generateCommandClassBuilderMethod associations first.
	^ self
		compile: methodAssoc key
		sourceCode: methodAssoc value
		inClass: (self class environment at: self retrieveCommandClassName asSymbol) class
		classifiedAs: self protocol
]

{ #category : #'code generation' }
EDATCommandGenerator >> createCommandClassEqualsMethod [
	| aggregateRootClass |
	aggregateRootClass := self class environment at: self retrieveCommandClassName asSymbol.
	^ self
		compile: 'semanticEquals:'
		sourceCode: (self generateEqualsMethodFor: self retrieveCommandAttributes)
		inClass: aggregateRootClass
		classifiedAs: self protocol
]

{ #category : #'code generation' }
EDATCommandGenerator >> createCommandClassHashMethod [
	| aggregateRootClass |
	aggregateRootClass := self class environment at: self retrieveCommandClassName asSymbol.
	^ self
		compile: 'semanticHash'
		sourceCode: (self generateHashMethodFor: self retrieveCommandAttributes)
		inClass: aggregateRootClass
		classifiedAs: self protocol
]

{ #category : #'code generation' }
EDATCommandGenerator >> createCommandClassLatestVersionClassMethod [
	| cls |
	cls := self class environment
		at: self retrieveCommandClassName asSymbol.
	^ cls class
		compile: self generateCommandClassLatestVersionMethod
		classified: self protocol
]

{ #category : #'code generation' }
EDATCommandGenerator >> createCommandClassRetrieveAggregateRootClassMethod [
	| aggregateRootClass |
	aggregateRootClass := self class environment at: self retrieveCommandClassName asSymbol.
	^ self
		compile: (self generateCommandClassRetrieveAggregateRootClassMethodName)
		sourceCode: (self generateCommandClassRetrieveAggregateRootClassMethod)
		inClass: aggregateRootClass
		classifiedAs: self protocol
]

{ #category : #protected }
EDATCommandGenerator >> description [
	^ 'Command ', self commandName greaseString 
]

{ #category : #protected }
EDATCommandGenerator >> doGenerate [
	self isDeleteCommand
		ifTrue: [ ^ self ].
	self createCommandClass.
	self createCommandClassAccessors.
	self createCommandClassBuilderMethod.
	self createCommandClassEqualsMethod.
	self createCommandClassHashMethod.
	self createCommandClassAggregateRootClassMethod.
	self createCommandClassRetrieveAggregateRootClassMethod.
	self createCommandClassLatestVersionClassMethod
]

{ #category : #'code generation' }
EDATCommandGenerator >> generateCommandClassAggregateRootClassMethod [
	| result cr |
	cr := Character cr.
	result := WriteStream with: String new.
	result
		nextPutAll: self generateCommandClassAggregateRootClassMethodName;
		nextPut: cr.
	result nextPutAll: self generateSignature.
	result
		nextPutAll: '	^ ';
		nextPutAll: self retrieveAggregateClassName;
		nextPut: cr.
	^ result contents
]

{ #category : #'code generation' }
EDATCommandGenerator >> generateCommandClassAggregateRootClassMethodName [
	^ 'aggregateRootClass'
]

{ #category : #'code generation' }
EDATCommandGenerator >> generateCommandClassBuilderMethod [

	| method attrs result cr cls |
	cr := Character cr.
	method := WriteStream with: String new.
	method
		nextPutAll:
			(self generateCommandClassBuilderMethodNameWithArgPrefix: 'the');
		nextPut: cr.
	cls := self class environment at:
		       self retrieveCommandClassName asSymbol.
	attrs := self
		         allAttributesOf: cls
		         including: (self retrieveCommandAttributesBut:
				          self class skippedCommandAttributes).
	method nextPutAll: self generateSignature.
	method
		nextPutAll: '	<';
		nextPutAll: (self toCamelCase: self edaApplication applicationName) asLowercase;
		nextPutAll: 'CommandName: #';
		nextPutAll: self commandName;
		nextPut: $>;
		nextPut: cr.
	method
		nextPutAll: '	| result |';
		nextPut: cr.
	method nextPutAll: '	result := super '.
	method
		nextPutAll:
			(self generateCommandClassBuilderMethodNameWithArgPrefix: 'the');
		nextPut: $.;
		nextPut: cr.
	method
		nextPutAll: '	result version: ';
		nextPutAll: self version greaseString;
		nextPut: $.;
		nextPut: cr.
	attrs do: [ :attr | 
		method
			nextPut: cr;
			nextPutAll: '	theAttributes at: ''';
			nextPutAll: attr;
			nextPutAll: ''' ifPresent: [ :v | result ';
			nextPutAll: attr;
			nextPutAll: ': v ].' ].
	method nextPut: cr.
	method nextPutAll: '	^ result'.
	result := Dictionary new.
	result
		at: self generateCommandClassBuilderMethodName
		put: method contents.
	^ result
]

{ #category : #'code generation' }
EDATCommandGenerator >> generateCommandClassBuilderMethodName [
	^ 'ofTenant:withCommandId:aggregateRootVersion:andAttributes:'
]

{ #category : #'code generation' }
EDATCommandGenerator >> generateCommandClassBuilderMethodNameWithArgPrefix: prefix [
	^ 'ofTenant: ' , prefix , 'Tenant withCommandId: ' , prefix
		, 'CommandId aggregateRootVersion: ' , prefix
		, 'Version andAttributes: ' , prefix , 'Attributes'
]

{ #category : #'code generation' }
EDATCommandGenerator >> generateCommandClassLatestVersionMethod [
	| result cr |
	cr := Character cr.
	result := WriteStream with: String new.
	result nextPutAll: self generateCommandClassLatestVersionMethodName.
	result nextPut: cr.
	result nextPutAll: self generateSignature.
	result
		nextPutAll: '	^ ';
		nextPutAll: self version greaseString;
		nextPut: cr.
	^ result contents
]

{ #category : #'code generation' }
EDATCommandGenerator >> generateCommandClassLatestVersionMethodName [
	^ 'latestVersion'
]

{ #category : #'code generation' }
EDATCommandGenerator >> generateCommandClassRetrieveAggregateRootClassMethod [
	| result cr |
	cr := Character cr.
	result := WriteStream with: String new.
	result
		nextPutAll: self generateCommandClassRetrieveAggregateRootClassMethodName;
		nextPut: cr.
	result nextPutAll: self generateSignature.
	result
		nextPutAll: '	^ self class ';
		nextPutAll: self generateCommandClassAggregateRootClassMethodName;
		nextPut: cr.
	^ result contents
]

{ #category : #'code generation' }
EDATCommandGenerator >> generateCommandClassRetrieveAggregateRootClassMethodName [
	^ 'retrieveAggregateRootClass'
]
