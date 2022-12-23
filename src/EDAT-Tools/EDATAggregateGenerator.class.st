Class {
	#name : #EDATAggregateGenerator,
	#superclass : #EDATGenerator,
	#category : #'EDAT-Tools'
}

{ #category : #sorting }
EDATAggregateGenerator class >> priority [

	^ 100
]

{ #category : #'code generation' }
EDATAggregateGenerator >> createAggregateApplyEventVersionMethod [

	| result |
	result := self isDeletedEvent
		          ifTrue: [ nil ]
		          ifFalse: [ 
			          self
				          compile:
				          self generateAggregateApplyEventVersionMethodName
				          sourceCode:
				          self generateAggregateApplyEventVersionMethod
				          inClass: (self classOrTraitNamed: (self toCamelCase: self aggregate) asSymbol)
				          classifiedAs: self protocol ].
	^ result
]

{ #category : #'code generation' }
EDATAggregateGenerator >> createAggregateClass [

	| cls attributes |
	cls := self aggregateClass asSymbol.
	attributes := self retrieveAggregateAttributesBut:
		              self class skippedAggregateAttributes.
	(self classExists: cls) ifTrue: [ 
		attributes := self
			              allAttributesOf: (self class environment at: cls)
			              including: attributes ].
	^ EDAAggregateRoot
		  subclass: cls
		  instanceVariableNames:
		  (self concatenateCollection: attributes with: ' ')
		  classVariableNames: ''
		  package: self retrieveDomainPackage
]

{ #category : #'code generation' }
EDATAggregateGenerator >> createAggregateClassAccessors [

	| aggregateClass |
	aggregateClass := self classOrTraitNamed: 
		                  self retrieveAggregateClassName asSymbol.
	(self generateAccessorsFor: aggregateClass attributes: (self
			  allAttributesOf: aggregateClass
			  including: (self retrieveAggregateAttributesBut:
					   self class skippedAggregateAttributes))) associationsDo: [ 
		:assoc | 
		self
			compile: assoc key
			sourceCode: assoc value
			inClass: aggregateClass
			classifiedAs: self protocol ]
]

{ #category : #'code generation' }
EDATAggregateGenerator >> createAggregateClassEqualsMethod [
	| aggregateClassName |
	aggregateClassName := self class environment at: self retrieveAggregateClassName asSymbol.
	^ self
		compile: 'semanticEquals:'
		sourceCode: (self generateEqualsMethodFor: (self allAttributesOf: aggregateClassName including: self retrieveAggregateAttributes))
		inClass: aggregateClassName
		classifiedAs: self protocol
]

{ #category : #'code generation' }
EDATAggregateGenerator >> createAggregateClassHashMethod [
	| aggregateRootClass |
	aggregateRootClass := self class environment at: self retrieveAggregateClassName asSymbol.
	^ self
		compile: 'semanticHash'
		sourceCode: (self generateHashMethodFor: (self allAttributesOf: aggregateRootClass including: self retrieveAggregateAttributes))
		inClass: aggregateRootClass
		classifiedAs: self protocol
]

{ #category : #'code generation' }
EDATAggregateGenerator >> createAggregateHandleCommandMethod [

	| result |
	result := self isDeleteCommand
		          ifTrue: [ nil ]
		          ifFalse: [ 
			          self
				          compile: self generateAggregateHandleCommandMethodName
				          sourceCode: self generateAggregateHandleCommandMethod
				          inClass: (self classOrTraitNamed: (self toCamelCase: self aggregate) asSymbol)
				          classifiedAs: self protocol ].
	^ result
]

{ #category : #'code generation' }
EDATAggregateGenerator >> createAggregateRetrieveRepositoryMethod [

	^ self
		  compile: self generateAggregateRetrieveRepositoryMethodName
		  sourceCode: self generateAggregateRetrieveRepositoryMethod
		  inClass: (self classOrTraitNamed: (self retrieveAggregateClassName) asSymbol)
		  classifiedAs: self protocol
]

{ #category : #api }
EDATAggregateGenerator >> description [
	^ 'aggregate for ' , self aggregate greaseString.
]

{ #category : #protected }
EDATAggregateGenerator >> doGenerate [
	self createAggregateClass.
	self createAggregateHandleCommandMethod.
	self createAggregateApplyEventVersionMethod.
	self createAggregateClassAccessors.
	self createAggregateClassEqualsMethod.
	self createAggregateClassHashMethod.
	self createAggregateRetrieveRepositoryMethod
]

{ #category : #'code generation' }
EDATAggregateGenerator >> generateAggregateApplyEventVersionMethod [

	| result attrs cr cls |
	cr := Character cr.
	cls := (self edaApplication eventClassPrefix
	        , (self underscoreSeparatedToCamelCase: self aggregate))
		       asSymbol.
	attrs := self retrieveEventAttributesBut:
		         self class skippedEventAttributes.
	result := WriteStream with: String new.
	result
		nextPutAll:
			(self generateAggregateApplyEventVersionMethodNameWithArg:
					 ' anEvent');
		nextPut: cr.
	result nextPutAll: self generateSignature.
	result
		nextPutAll: '	self id: anEvent id.';
		nextPut: cr.
	attrs do: [ :attr | 
		result
			nextPutAll: '	self ';
			nextPutAll: attr;
			nextPutAll: ': anEvent ';
			nextPutAll: attr;
			nextPut: $.;
			nextPut: cr ].
	^ result contents
]

{ #category : #'code generation' }
EDATAggregateGenerator >> generateAggregateApplyEventVersionMethodName [
	^ 'apply' , (self toCamelCase: self eventName) capitalized , 'v' , (self version greaseString) , ':'
]

{ #category : #'code generation' }
EDATAggregateGenerator >> generateAggregateApplyEventVersionMethodNameWithArg: arg [
	^ 'apply' , (self toCamelCase: self eventName) capitalized , 'v' , (self version greaseString) , ':' , arg
]

{ #category : #'code generation' }
EDATAggregateGenerator >> generateAggregateHandleCommandMethod [

	| result commandClass attrs cr |
	cr := Character cr.
	commandClass := self retrieveCommandClassName asSymbol.
	attrs := self
		         allAttributesOf: (self classOrTraitNamed: commandClass)
		         including: self retrieveCommandAttributes.
	result := WriteStream with: String new.
	result
		nextPutAll:
			(self generateAggregateHandleCommandMethodNameWithArg: 'aCommand');
		nextPut: cr.
	result
		nextPutAll: '	<useAsCommandHandlerFor: #';
		nextPutAll: commandClass;
		nextPut: $>;
		nextPut: cr.
	result nextPutAll: self generateSignature.
	result
		nextPutAll: '	| theTenant theId theCommandId theAttrs |';
		nextPut: cr.
	(self commandContainsAttribute: 'id')
		ifTrue: [ result nextPutAll: '	theId := aCommand aggregateRootId.' ]
		ifFalse: [ result nextPutAll: '	theId := UUID new greaseString.' ].
	result nextPut: cr.
	result
		nextPutAll: '	theTenant := aCommand tenant.';
		nextPut: cr.
	result
		nextPutAll: '	theCommandId := aCommand commandId.';
		nextPut: cr.
	result
		nextPutAll:
			'	theAttrs := self class buildCommonArgsForCommand: aCommand.';
		nextPut: cr.
	(attrs reject: [ :attr | 
		 self class skippedEventAttributes anySatisfy: [ :skipped | 
			 attr = skipped ] ]) do: [ :attr | 
		result
			nextPutAll: '	aCommand ';
			nextPutAll: attr;
			nextPutAll: ' ifNotNil: [ :v | theAttrs at: ''';
			nextPutAll: attr;
			nextPutAll: ''' put: v ].';
			nextPut: cr ].
	result
		nextPutAll: '	^ ';
		nextPutAll: self edaApplication eventClassPrefix;
		nextPutAll: (self toCamelCase: self eventName);
		nextPut: cr.
	result
		nextPutAll: '		';
		nextPutAll:
			(self generateEventClassBuilderMethodNameWithArgPrefix: 'the');
		nextPut: cr.
	^ result contents
]

{ #category : #'code generation' }
EDATAggregateGenerator >> generateAggregateHandleCommandMethodName [
	^ 'handle' , (self toCamelCase: self commandName ) capitalized , ':'
]

{ #category : #'code generation' }
EDATAggregateGenerator >> generateAggregateHandleCommandMethodNameWithArg: arg [
	^ 'handle' , (self toCamelCase: self commandName) capitalized , ': ' , arg
]

{ #category : #'code generation' }
EDATAggregateGenerator >> generateAggregateRetrieveRepositoryMethod [
	| result cr |
	result := WriteStream with: String new.
	cr := Character cr.
	result
		nextPutAll: self generateAggregateRetrieveRepositoryMethodName;
		nextPut: cr.
	result nextPutAll: self generateSignature.
	result
		nextPutAll: '	^ ';
		nextPutAll: self retrieveAggregateClassName;
		nextPutAll: 'Repository uniqueInstance';
		cr.
	^ result contents
]

{ #category : #'code generation' }
EDATAggregateGenerator >> generateAggregateRetrieveRepositoryMethodName [
	^ 'retrieve' , (self toCamelCase: self aggregate) capitalized , 'Repository'
]

{ #category : #delegated }
EDATAggregateGenerator >> generateEventClassBuilderMethodNameWithArgPrefix: aString [

	| delegate |
	delegate := EDATEventGenerator
		            fromExampleFile: self commandFile
		            version: self version
		            application: self edaApplication
		            aggregate: self aggregate
		            commandNameResolver: self commandNameResolver
		            andEventNameResolver: self eventNameResolver.
	^ delegate generateEventClassBuilderMethodNameWithArgPrefix: aString
]
