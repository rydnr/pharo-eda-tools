Class {
	#name : #EDATApplicationGenerator,
	#superclass : #EDATGenerator,
	#category : #'EDAT-Tools'
}

{ #category : #'code generation' }
EDATApplicationGenerator >> createEDAApplicationRegisterCommandBuilders [

	^ self
		  compile:
		  self generateEDAApplicationRegisterCommandBuildersMethodName
		  sourceCode:
			  (self generateEDAApplicationRegisterCommandBuildersMethodFor:
				   self commandClassPrefix)
		  inClass: (self class environment at:
				   (commandClassPrefix , 'EDAApplication') asSymbol) class
		  classifiedAs: self protocol
]

{ #category : #protected }
EDATApplicationGenerator >> description [
	^ 'EDAApplication'
]

{ #category : #protected }
EDATApplicationGenerator >> doGenerate [
	self createEDAApplicationRegisterCommandBuilders
]

{ #category : #'code generation' }
EDATApplicationGenerator >> generateEDAApplicationRegisterCommandBuildersMethodFor: anAppName [

	| result commands cr |
	cr := Character cr.
	result := WriteStream with: String new.
	result
		nextPutAll:
			self generateEDAApplicationRegisterCommandBuildersMethodName;
		nextPut: cr.
	result nextPutAll: self generateSignature.
	result
		nextPutAll: '	| builder |';
		nextPut: cr.
	result
		nextPutAll: '	builder := ';
		nextPutAll: self commandClassPrefix;
		nextPutAll: 'DefaultCommandBuilder new.';
		nextPut: cr.
	result
		nextPutAll: '	EDACommandBuilderRegistry';
		nextPut: cr.
	commands := self retrieveImplementedCommandsFor: anAppName.
	commands keys asOrderedCollection keysAndValuesDo: [ :i :key | 
		i > 1 ifTrue: [ 
			result
				nextPut: $;;
				nextPut: cr ].
		result
			nextPutAll: '		addBuilder: builder forCommand: #';
			nextPutAll: key ].
	^ result contents
]

{ #category : #'code generation' }
EDATApplicationGenerator >> generateEDAApplicationRegisterCommandBuildersMethodName [
	^ 'registerCommandBuilders'
]
