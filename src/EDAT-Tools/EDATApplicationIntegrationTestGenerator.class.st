Class {
	#name : #EDATApplicationIntegrationTestGenerator,
	#superclass : #EDATGenerator,
	#category : #'EDAT-Tools'
}

{ #category : #sorting }
EDATApplicationIntegrationTestGenerator class >> enabled [

	^ false
]

{ #category : #sorting }
EDATApplicationIntegrationTestGenerator class >> priority [

	^ 10
]

{ #category : #'code generation' }
EDATApplicationIntegrationTestGenerator >> createIntegrationTestClass [

	BabyMock2TestCase
		subclass: (self edaApplication eventClassPrefix
			 , (self toCamelCase: self edaApplication applicationName)
			 , 'ApplicationIntegrationTestCase') asSymbol
		instanceVariableNames: ''
		classVariableNames: ''
		package: self retrieveIntegrationTestsPackage
]

{ #category : #protected }
EDATApplicationIntegrationTestGenerator >> description [

	^ 'integration test for ' , self aggregate greaseString
]

{ #category : #protected }
EDATApplicationIntegrationTestGenerator >> doGenerate [

	self createIntegrationTestClass
]
