Class {
	#name : #EDATDomainTestGenerator,
	#superclass : #EDATGenerator,
	#category : #'EDAT-Tools'
}

{ #category : #sorting }
EDATDomainTestGenerator class >> priority [

	^ 300
]

{ #category : #'code generation' }
EDATDomainTestGenerator >> createDomainTestClass [

	| cls testTraitGenerator |
	cls := self retrieveDomainTestClassName asSymbol.
	testTraitGenerator := EDATTestTraitGenerator new
		                      edaApplication: self edaApplication;
		                      aggregate: self aggregate;
		                      yourself.
	(self containsAnyDisableRegenerationMethod: cls) ifFalse: [ 
		^ BabyMock2TestCase
			  subclass: cls
			  uses: EDATDomainBDD + (self classOrTraitNamed:
					   testTraitGenerator retrieveTestHelperTraitName asSymbol)
			  instanceVariableNames: ''
			  classVariableNames: ''
			  package: self retrieveDomainTestsPackage ]
]

{ #category : #'code generation' }
EDATDomainTestGenerator >> createDomainTestMethod [

	^ self
		  compile: self generateDomainTestMethodName
		  sourceCode: self generateDomainTestMethod
		  inClass: (self classOrTraitNamed: self retrieveDomainTestClassName)
		  classifiedAs: self protocol
]

{ #category : #delegated }
EDATDomainTestGenerator >> createTestEventBuildEventClassMethod [

	| delegate |
	delegate := EDATDomainTestEventGenerator
		            fromExampleFile: self commandFile
		            version: self version
		            application: self edaApplication
		            aggregate: self aggregate
		            commandNameResolver: self commandNameResolver
		            andEventNameResolver: self eventNameResolver.
	^ delegate createTestEventBuildEventClassMethod
]

{ #category : #delegated }
EDATDomainTestGenerator >> createTestHelperBuildCommandMethod [

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

{ #category : #delegated }
EDATDomainTestGenerator >> createTestHelperBuildEventClassMethod [

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

{ #category : #delegated }
EDATDomainTestGenerator >> createTestHelperBuildEventMethod [

	| delegate |
	delegate := EDATTestTraitGenerator
		            fromExampleFile: self commandFile
		            version: self version
		            application: self edaApplication
		            aggregate: self aggregate
		            commandNameResolver: self commandNameResolver
		            andEventNameResolver: self eventNameResolver.
	^ delegate createTestHelperBuildEventMethod
]

{ #category : #protected }
EDATDomainTestGenerator >> description [
	^ 'domain test for ' , self aggregate greaseString
]

{ #category : #protected }
EDATDomainTestGenerator >> doGenerate [
	self createDomainTestClass.
	self createDomainTestMethod.
	self createTestHelperBuildCommandMethod.
	self createTestHelperBuildEventMethod.
	self createTestEventBuildEventClassMethod.
	self createTestHelperBuildEventClassMethod.
]

{ #category : #'code generation' }
EDATDomainTestGenerator >> generateDomainTestMethod [

	| result cmdName evtName cr |
	cr := Character cr.
	cmdName := self toCamelCase: self commandName.
	evtName := self toCamelCase: self eventName.
	result := WriteStream with: String new.
	result nextPutAll: self generateDomainTestMethodName.
	result nextPut: cr.
	result nextPutAll: self generateSignature.
	result
		nextPutAll: '	| command event |';
		nextPut: cr.
	result
		nextPutAll: '	command := self build';
		nextPutAll: cmdName;
		nextPutAll: 'SampleCommand.';
		nextPut: cr.
	result nextPutAll: '	event := self build'.
	self isDeletedEvent
		ifTrue: [ 
			result
				nextPutAll: 'DeletedEventWithId: ''<ANYTHING>'' ';
				nextPutAll: 'andCommand: command.' ]
		ifFalse: [ 
			result
				nextPutAll: evtName;
				nextPutAll: 'SampleEventWithId: ''<ANYTHING>'' ';
				nextPutAll: 'andCommandId: command commandId.' ].
	result nextPut: cr.
	result nextPutAll:
		'	event aggregateRootVersion: command aggregateRootVersion + 1.'.
	result
		nextPutAll: '	self';
		nextPut: cr.
	result
		nextPutAll: '		givenAggregate: #';
		nextPutAll: self edaApplication eventClassPrefix;
		nextPutAll: self aggregate capitalized;
		nextPut: cr.
	result
		nextPutAll: '			withEvents: OrderedCollection new';
		nextPut: cr.
	result
		nextPutAll: '			whenReceiveCommand: command';
		nextPut: cr.
	result
		nextPutAll: '			thenEvent: event';
		nextPut: cr.
	^ result contents
]

{ #category : #'code generation' }
EDATDomainTestGenerator >> generateDomainTestMethodName [
	^ 'test' , (self toCamelCase: self commandName)
]

{ #category : #delegated }
EDATDomainTestGenerator >> generateEventClassAggregateRootClassMethod [

	| delegate |
	delegate := EDATEventGenerator
		            fromExampleFile: self commandFile
		            version: self version
		            application: self edaApplication
		            aggregate: self aggregate
		            commandNameResolver: self commandNameResolver
		            andEventNameResolver: self eventNameResolver.
	^ delegate generateEventClassAggregateRootClassMethod
]

{ #category : #'code generation' }
EDATDomainTestGenerator >> retrieveDomainTestClassName [

	^ self aggregate capitalized
	  , 'DomainTestCase'
]
