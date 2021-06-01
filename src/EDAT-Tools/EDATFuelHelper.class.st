
Class {
	#name : #EDATFuelHelper,
	#superclass : #Object,
	#category : #'EDAT-Tools'
}

{ #category : #handling }
EDATFuelHelper >> readFuelFromFileNamed: aFileReference [
	| aContext |
	aContext := FLMaterializer
		materializeFromFileNamed: aFileReference pathString.
	^ Process forContext: aContext priority: Processor activePriority
]

{ #category : #handling }
EDATFuelHelper >> readFuelFromFileNamed: aString inFolder: aFolder [
	^ self readFuelFromFileNamed: (aFolder / aString)
]

{ #category : #handling }
EDATFuelHelper >> writeFuelContext: aContext named: aString inFolder: aFolder [
	| result |
	result := aFolder / aString.
	FLSerializer serialize: aContext toFileNamed: result pathString.
	^ result
]
