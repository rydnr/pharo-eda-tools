Class {
	#name : #EDATTestSupportGenerator,
	#superclass : #EDATGenerator,
	#category : #'EDAT-Tools'
}

{ #category : #sorting }
EDATTestSupportGenerator class >> priority [

	^ 30
]

{ #category : #'code generation' }
EDATTestSupportGenerator >> createTestHelperBuildEventClassMethod [

	| method |
	method := self generateTestHelperBuildEventClassMethod.
	method associationsDo: [ :assoc | 
		^ self
			  compile: assoc key
			  sourceCode: assoc value
			  inClass:
				  (self classOrTraitNamed:
					   self retrieveTestHelperTraitName asSymbol) class
			  classifiedAs: self protocol ]
]

{ #category : #protected }
EDATTestSupportGenerator >> description [
	^ 'helper methods for testing ' , self aggregate greaseString
]

{ #category : #protected }
EDATTestSupportGenerator >> doGenerate [
	self createTestHelperBuildEventClassMethod
]

{ #category : #'code generation' }
EDATTestSupportGenerator >> generateTestHelperBuildEventClassMethod [
	| result methodName method attrs cr |
	cr := Character cr.
	methodName := self generateTestHelperBuildEventClassMethodName.
	method := WriteStream with: String new.
	method nextPutAll: (self generateTestHelperBuildEventClassMethodNameWithArgPrefix: 'new').
	method nextPutAll: self generateSignature.
	attrs := self retrieveEventAttributesBut: self class skippedEventAttributes.
	method nextPut: cr.
	method
		nextPutAll: '	| result | ';
		nextPut: cr.
	method
		nextPutAll: '	result := self new.';
		nextPut: cr.
	method
		nextPutAll: '	result id: UUID new asString.';
		nextPut: cr.
	method
		nextPutAll: '	result commandId: newCommandId.';
		nextPut: cr.
	method nextPutAll: '	result timestamp: DateAndTime now asUTC.'.
	attrs
		do: [ :attr | 
			method
				nextPut: cr;
				nextPutAll: '	result ';
				nextPutAll: attr;
				nextPutAll: ': (newAttributes at: ''';
				nextPutAll: attr;
				nextPutAll: ''').' ].
	method nextPut: cr.
	method nextPutAll: '	^ result'.
	result := Dictionary new.
	result at: methodName put: method contents.
	^ result
]

{ #category : #'code generation' }
EDATTestSupportGenerator >> generateTestHelperBuildEventClassMethodName [
	^ 'ofTenant:withAggregateId:commandId:andAttributes:'
]

{ #category : #'code generation' }
EDATTestSupportGenerator >> generateTestHelperBuildEventClassMethodNameWithArgPrefix: prefix [
	^ 'ofTenant: ' , (prefix , 'Tenant') , ' withAggregateId: '
		, (prefix , 'Id') uncapitalized , ' commandId: '
		, (prefix , 'CommandId') uncapitalized , ' andAttributes: '
		, (prefix , 'Attributes') uncapitalized
]

{ #category : #delegated }
EDATTestSupportGenerator >> retrieveTestHelperTraitName [

	| delegate |
	delegate := EDATTestTraitGenerator
		            fromExampleFile: self commandFile
		            version: self version
		            application: self edaApplication
		            aggregate: self aggregate
		            commandNameResolver: self commandNameResolver
		            andEventNameResolver: self eventNameResolver.
	^ delegate retrieveTestHelperTraitName
]
