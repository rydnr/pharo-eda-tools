Class {
	#name : #EDATRepositoryGenerator,
	#superclass : #EDATGenerator,
	#category : #'EDAT-Tools'
}

{ #category : #'code generation' }
EDATRepositoryGenerator >> createRepositoryClass [

	| cls attributes result |
	cls := self retrieveRepositoryClassName asSymbol.
	attributes := OrderedCollection new.
	attributes add: ''.
	(self classExists: cls) ifTrue: [ 
		attributes := self
			              allAttributesOf: (self class environment at: cls)
			              including: attributes ].
	result := EDAAggregateRepository
		          subclass: cls
		          instanceVariableNames:
		          (self concatenateCollection: attributes with: ' ')
		          classVariableNames: ''
		          package: self retrieveRepositoryPackage.
	(self class environment at: cls) class instanceVariableNames: ''.
	^ result
]

{ #category : #'code generation' }
EDATRepositoryGenerator >> createRepositoryClassAccessors [
	| repositoryClass |
	repositoryClass := self class environment at: self retrieveRepositoryClassName asSymbol.
	(self generateAccessorsFor: repositoryClass attributes: (self allAttributesOf: repositoryClass))
		associationsDo: [ :assoc | 
			self
				compile: assoc key
				sourceCode: assoc value
				inClass: repositoryClass
				classifiedAs: self protocol ]
]

{ #category : #'code generation' }
EDATRepositoryGenerator >> createRepositoryFindByIdMethod [
	| repositoryClass |
	"Not used anymore"
"	repositoryClass := self class environment at: self retrieveRepositoryClassName asSymbol.
	self
		compile: self generateRepositoryFindByIdMethodName
		sourceCode: self generateRepositoryFindByIdMethod
		inClass: repositoryClass
		classifiedAs: self protocol"
]

{ #category : #'code generation' }
EDATRepositoryGenerator >> createRepositorySetupEventStoreClassMethod [
	"Not used anymore"
	"| repositoryClass |
	repositoryClass := self class environment at: self retrieveRepositoryClassName asSymbol.
	self
		compile: self generateRepositorySetupEventStoreClassMethodName
		sourceCode: self generateRepositorySetupEventStoreClassMethod
		inClass: repositoryClass class
		classifiedAs: self protocol"
]

{ #category : #'code generation' }
EDATRepositoryGenerator >> createRepositoryUniqueInstanceGetterClassMethod [
	"Not used anymore"
	"| repositoryClass |
	repositoryClass := self class environment at: self retrieveRepositoryClassName asSymbol.
	self
		compile: self generateRepositoryUniqueInstanceGetterClassMethodName
		sourceCode: self generateRepositoryUniqueInstanceGetterClassMethod
		inClass: repositoryClass class
		classifiedAs: self protocol"
]

{ #category : #'code generation' }
EDATRepositoryGenerator >> createRepositoryUniqueInstanceSetterClassMethod [
	"Not used anymore"
	"| repositoryClass |
	repositoryClass := self class environment at: self retrieveRepositoryClassName asSymbol.
	self
		compile: self generateRepositoryUniqueInstanceSetterClassMethodName
		sourceCode: self generateRepositoryUniqueInstanceSetterClassMethod
		inClass: repositoryClass class
		classifiedAs: self protocol"
]

{ #category : #protected }
EDATRepositoryGenerator >> description [
	^ 'repository for ' , self aggregate greaseString
]

{ #category : #protected }
EDATRepositoryGenerator >> doGenerate [
	self createRepositoryClass.
	self createRepositoryClassAccessors.
	self createRepositorySetupEventStoreClassMethod.
	self createRepositoryUniqueInstanceGetterClassMethod.
	self createRepositoryUniqueInstanceSetterClassMethod.
	self createRepositoryFindByIdMethod
]

{ #category : #'code generation' }
EDATRepositoryGenerator >> generateRepositoryFindByIdMethod [
	| result cr aggregateClassName |
	cr := Character cr.
	result := WriteStream with: String new.
	aggregateClassName := self retrieveAggregateClassName.
	result
		nextPutAll: self generateRepositoryFindByIdMethodName;
		nextPutAll: ' anId';
		nextPut: cr.
	result nextPutAll: self generateSignature.
	result
		nextPutAll: '	| result events criteria |';
		nextPut: cr.
	result
		nextPutAll: '	criteria := Dictionary new.';
		nextPut: cr.
	result
		nextPutAll: '	criteria at: ''id'' put: anId.';
		nextPut: cr.
	result
		nextPutAll: '	events := self eventStore findEventsOfAggregate: ';
		nextPutAll: aggregateClassName;
		nextPutAll: ' whereCriteria: criteria.';
		nextPut: cr.
	result
		nextPutAll: '	events ifEmpty: [ Transcript print: ''WARNING: No ';
		nextPutAll: self aggregate;
		nextPutAll: ' found with '' , (anId ifNil: [ ''null id'' ] ifNotNil: [ :v | ''id '' , v ]); cr. result := nil ]';
		nextPut: cr.
	result
		nextPutAll: '		ifNotEmpty: [ :evts | ';
		nextPut: cr.
	result
		nextPutAll: '			result := ';
		nextPutAll: aggregateClassName;
		nextPutAll: ' new.';
		nextPut: cr.
	result
		nextPutAll: '			result applyEvents: evts. ].';
		nextPut: cr.
	result
		nextPutAll: '	^ result';
		nextPut: cr.
	^ result contents
]

{ #category : #'code generation' }
EDATRepositoryGenerator >> generateRepositoryFindByIdMethodName [
	^ 'findById:'
]

{ #category : #'code generation' }
EDATRepositoryGenerator >> generateRepositorySetupEventStoreClassMethod [
	| result cr |
	cr := Character cr.
	result := WriteStream with: String new.
	result nextPutAll: self generateRepositorySetupEventStoreClassMethodName;
	nextPutAll: ' anEventStore';
	nextPut: cr.
	result nextPutAll: self generateSignature.
	result nextPutAll: '	EventStore := anEventStore';
		nextPut: cr.
	^ result contents
]

{ #category : #'code generation' }
EDATRepositoryGenerator >> generateRepositorySetupEventStoreClassMethodName [
	^ 'setupEventStore:'

]

{ #category : #'code generation' }
EDATRepositoryGenerator >> generateRepositoryUniqueInstanceGetterClassMethod [
	| result cr |
	cr := Character cr.
	result := WriteStream with: String new.
	result
		nextPutAll: self generateRepositoryUniqueInstanceGetterClassMethodName;
		nextPut: cr.
	result nextPutAll: self generateSignature.
	result
		nextPutAll: '	| result |';
		nextPut: cr.
	result
		nextPutAll: '	result := UniqueInstance.';
		nextPut: cr.
	result
		nextPutAll: '	result';
		nextPut: cr.
	result
		nextPutAll: '		ifNil: [ result := self new.';
		nextPut: cr.
	result
		nextPutAll: '			result eventStore: EventStore.';
		nextPut: cr.
	result
		nextPutAll: '			self ';
		nextPutAll: self generateRepositoryUniqueInstanceSetterClassMethodName;
		nextPutAll: ' result ].';
		nextPut: cr.
	result nextPutAll: '	^ result'; nextPut: cr.
	^ result contents
]

{ #category : #'code generation' }
EDATRepositoryGenerator >> generateRepositoryUniqueInstanceGetterClassMethodName [
	^ 'uniqueInstance'
]

{ #category : #'code generation' }
EDATRepositoryGenerator >> generateRepositoryUniqueInstanceSetterClassMethod [
	| result cr |
	cr := Character cr.
	result := WriteStream with: String new.
	result
		nextPutAll: self generateRepositoryUniqueInstanceSetterClassMethodName;
		nextPutAll: ' anInstance';
		nextPut: cr.
	result nextPutAll: self generateSignature.
	result
		nextPutAll: '	UniqueInstance := anInstance';
		nextPut: cr.
	^ result contents
]

{ #category : #'code generation' }
EDATRepositoryGenerator >> generateRepositoryUniqueInstanceSetterClassMethodName [
	^ 'uniqueInstance:'
]
