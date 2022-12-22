Class {
	#name : #EDATDomainTestEventGenerator,
	#superclass : #EDATGenerator,
	#category : #'EDAT-Tools'
}

{ #category : #sorting }
EDATDomainTestEventGenerator class >> priority [

	^ 150
]

{ #category : #'code generation' }
EDATDomainTestEventGenerator >> createDomainTestEventClass [

	| cls parent parentSymbol |
	parentSymbol := self isDeletedEvent
		                ifTrue: [ 
			                (self edaApplication eventClassPrefix
			                 , (self toCamelCase: self eventName)) asSymbol ]
		                ifFalse: [ self retrieveEventClassName asSymbol ].
	parent := self class environment at: parentSymbol.
	cls := self retrieveDomainTestEventClassName.
	parent
		subclass: cls
		uses: EDATTestEvent
		instanceVariableNames: ''
		classVariableNames: ''
		package: self edaApplication eventClassPrefix , '-Domain-Tests-'
			, (self toCamelCase: self aggregate).
	^ cls
]

{ #category : #'code generation' }
EDATDomainTestEventGenerator >> createDomainTestEventClassAggregateRootClassMethod [
	| cls |
	cls := self class environment at: self retrieveEventClassName asSymbol.
	^ self
		compile: 'aggregateRootClass'
		sourceCode: self generateEventClassAggregateRootClassMethod
		inClass: cls class
		classifiedAs: 'meta'
]

{ #category : #'code generation' }
EDATDomainTestEventGenerator >> createDomainTestEventEqualsMethod [
	^ self
		compile: '='
		sourceCode: self generateDomainTestEventEqualsMethod
		inClass: (self retrieveDomainTestEventClass)
		classifiedAs: self protocol
]

{ #category : #delegated }
EDATDomainTestEventGenerator >> createTestEventBuildEventClassMethod [
	| method |
	method := self generateTestEventBuildEventClassMethod.
	method
		associationsDo: [ :assoc | 
			^ self
				compile: assoc key
				sourceCode: assoc value
				inClass: self retrieveDomainTestEventClass class
				classifiedAs: self protocol ]
]

{ #category : #'code generation' }
EDATDomainTestEventGenerator >> createTestHelperBuildCommandMethod [

	| delegate |
	delegate := EDATTestTraitGenerator
		            fromExampleFile: self commandFile
		            version: self version
		            application: self edaApplication
		            aggregate: self aggregate
		            commandNameResolver: self commandNameResolver
		            andEventNameResolver: self eventNameResolver.
	^ delegate createTestHelperBuildCommandMethod
]

{ #category : #'code generation' }
EDATDomainTestEventGenerator >> createTestHelperBuildEventClassMethod [

	| delegate |
	delegate := EDATTestSupportGenerator
		            fromExampleFile: self commandFile
		            version: self version
		            application: self edaApplication
		            aggregate: self aggregate
		            commandNameResolver: self commandNameResolver
		            andEventNameResolver: self eventNameResolver.
	^ delegate createTestHelperBuildEventClassMethod
]

{ #category : #protected }
EDATDomainTestEventGenerator >> description [
	^ 'domain test event for ' , self aggregate greaseString
]

{ #category : #protected }
EDATDomainTestEventGenerator >> doGenerate [
	self createDomainTestEventClass.
	self createTestEventBuildEventClassMethod.
	self createTestHelperBuildEventClassMethod.
	self createDomainTestEventEqualsMethod.
	self createTestEventBuildEventClassMethod
]

{ #category : #'code generation' }
EDATDomainTestEventGenerator >> generateDomainTestEventAttributeMatchesMethodName [
	^ 'attribute:named:matches:'
]

{ #category : #'code generation' }
EDATDomainTestEventGenerator >> generateDomainTestEventEqualsAndBlockRecursively: attributes [
	| result attribute |
	attributes size > 0
		ifTrue: [ attribute := attributes first.
			result := ' (self attribute: self ' , attribute , ' named: ''' , attribute , ''' matches: anInstance ' , attribute , ')'.
			attributes size > 1
				ifTrue: [ result := result , ' and: [ ' , (self generateDomainTestEventEqualsAndBlockRecursively: attributes allButFirst) , ' ]' ] ].
	^ result
]

{ #category : #'code generation' }
EDATDomainTestEventGenerator >> generateDomainTestEventEqualsMethod [
	| result cr eventAttributes |
	eventAttributes := self
		allAttributesOf: self retrieveDomainTestEventClass
		including: (self retrieveEventAttributesBut: self class skippedEventAttributes).
	result := WriteStream with: String new.
	cr := Character cr.
	result
		nextPutAll: '= anInstance';
		nextPut: Character cr.
	result nextPutAll: self generateSignature.
	result
		nextPutAll: '	^ ';
		nextPutAll: ' (anInstance class isKindOf: '.
	result nextPutAll: self retrieveEventClassName.
	result
		nextPutAll: ' class) and: [';
		nextPut: cr.
	result
		nextPutAll:
			'		(self attribute: self aggregateRootClass matches: anInstance aggregateRootClass) and: [';
		nextPut: cr.
	result
		nextPutAll:
			'		(self attribute: self tenant matches: anInstance tenant) and: [';
		nextPut: cr.
	result
		nextPutAll:
			'				(self attribute: self id named: ''id'' matches: anInstance id) and: [';
		nextPut: cr.
	result
		nextPutAll:
			'					(self attribute: self aggregateRootVersion matches: anInstance aggregateRootVersion) and: [';
		nextPut: cr.
	result
		nextPutAll:
			'						(self attribute: self timestamp named: ''timestamp'' matches: anInstance timestamp) and: [';
		nextPut: cr.
	result
		nextPutAll:
			'							(self attribute: self commandId named: ''correlationId'' matches: anInstance commandId) '.
	self isDeletedEvent
		ifFalse: [ eventAttributes isNotEmpty
				ifTrue: [ result
						nextPutAll: 'and: [';
						nextPut: cr.
					result
						nextPutAll: '								';
						nextPutAll:
							(self
								generateDomainTestEventEqualsAndBlockRecursively: (self retrieveEventAttributesBut: self class skippedEventAttributes));
						nextPut: cr.
					result
						nextPutAll: '						]';
						nextPut: cr ] ].
	result
		nextPutAll: '						]';
		nextPut: cr.
	result
		nextPutAll: '					]';
		nextPut: cr.
	result
		nextPutAll: '				]';
		nextPut: cr.
	result
		nextPutAll: '			]';
		nextPut: cr.
	result
		nextPutAll: '		]';
		nextPut: cr.
	result
		nextPutAll: '	]';
		nextPut: cr.
	^ result contents
]

{ #category : #'code generation' }
EDATDomainTestEventGenerator >> generateTestEventBuildEventClassMethod [
	| method attrs result cr |
	cr := Character cr.
	method := WriteStream with: String new.
	method
		nextPutAll: (self generateTestEventBuildEventClassMethodNameWithArgPrefix: 'new');
		nextPut: cr.
	method nextPutAll: self generateSignature.
	attrs := self
		retrieveEventAttributesBut: self class skippedCommandAttributes.
	method
		nextPut: cr;
		nextPutAll: '	| result |';
		nextPut: cr.
	method
		nextPutAll: '	result := self new.';
		nextPut: cr.
	method
		nextPutAll: '	result tenant: newEvent tenant.';
		nextPut: cr.
	method
		nextPutAll: '	result id: ''<ANYTHING>''.';
		nextPut: cr.
	method
		nextPutAll: '	result commandId: newEvent commandId.';
		nextPut: cr.
	method
		nextPutAll: '	result version: newEvent class latestVersion.';
		nextPut: cr.
	method
		nextPutAll: '	result aggregateRootVersion: newEvent aggregateRootVersion.';
		nextPut: cr.
	method nextPutAll: '	result timestamp: ''<ANYTHING>''.'.
	attrs
		do: [ :attr | 
			method
				nextPut: cr;
				nextPutAll: '	result ';
				nextPutAll: attr uncapitalized;
				nextPutAll: ': newEvent ';
				nextPutAll: attr;
				nextPut: $. ].
	method
		nextPut: cr;
		nextPutAll: '	^ result'.
	result := Dictionary new.
	result
		at: self generateTestEventBuildEventClassMethodName
		put: method contents.
	^ result
]

{ #category : #'code generation' }
EDATDomainTestEventGenerator >> generateTestEventBuildEventClassMethodName [
	^ 'fromEvent:'
]

{ #category : #'code generation' }
EDATDomainTestEventGenerator >> generateTestEventBuildEventClassMethodNameWithArgPrefix: prefix [
	^ 'fromEvent: ' , prefix , 'Event'
]

{ #category : #delegated }
EDATDomainTestEventGenerator >> retrieveDomainTestEventClass [
	| cls result |
	cls := self class environment at: self retrieveDomainTestEventClassName ifAbsent: [ nil ].
	result := cls ifNotNil: [ :c | c ] ifNil: [ self createDomainTestEventClass ].
	^ result
]

{ #category : #'code generation' }
EDATDomainTestEventGenerator >> retrieveDomainTestEventClassName [

	^ (self edaApplication eventClassPrefix , 'Test'
	   , (self toCamelCase: self eventName)) asSymbol
]
