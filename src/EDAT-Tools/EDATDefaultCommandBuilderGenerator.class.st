Class {
	#name : #EDATDefaultCommandBuilderGenerator,
	#superclass : #EDATGenerator,
	#category : #'EDAT-Tools'
}

{ #category : #'code generation' }
EDATDefaultCommandBuilderGenerator >> createDefaultCommandBuilderInitializeCommandBuilders [

	^ self
		  compile:
		  self
			  generateDefaultCommandBuilderInitializeCommandBuildersMethodName
		  sourceCode: (self 
				   generateDefaultCommandBuilderInitializeCommandBuildersMethodFor:
				   self edaApplication commandClassPrefix)
		  inClass: self edaApplication commandBuilder class
		  classifiedAs: self protocol
]

{ #category : #protected }
EDATDefaultCommandBuilderGenerator >> description [
	^ 'DefaultCommandBuilder'
]

{ #category : #protected }
EDATDefaultCommandBuilderGenerator >> doGenerate [
	self
		logDebugMessage:
			'** Generating DefaultCommandBuilder >> initializeCommandBuilders for '
				, self aggregate greaseString , ', version ' , self version greaseString.
	self createDefaultCommandBuilderInitializeCommandBuilders
]

{ #category : #'code generation' }
EDATDefaultCommandBuilderGenerator >> generateDefaultCommandBuilderInitializeCommandBuildersMethodFor: anAppName [
	| result commands cr |
	cr := Character cr.
	result := WriteStream with: String new.
	result
		nextPutAll: self generateDefaultCommandBuilderInitializeCommandBuildersMethodName;
		nextPut: cr.
	result nextPutAll: self generateSignature.
	result nextPutAll: '	commandDictionary := {'.
	commands := self retrieveImplementedCommandsFor: anAppName.
	commands keys asOrderedCollection
		keysAndValuesDo: [ :i :key | 
			i > 1
				ifTrue: [ result nextPut: $. ].
			result
				nextPut: cr;
				nextPutAll: '		(#';
				nextPutAll: key;
				nextPutAll: ' -> ';
				nextPutAll: (self removeClassLiteralFromMetaClassName: (commands at: key) name);
				nextPut: $) ].
	result
		nextPut: cr;
		nextPutAll: '	} asDictionary'.
	^ result contents
]

{ #category : #'code generation' }
EDATDefaultCommandBuilderGenerator >> generateDefaultCommandBuilderInitializeCommandBuildersMethodName [
	^ 'initializeCommandBuilders'
]
