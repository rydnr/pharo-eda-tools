Trait {
	#name : #EDATCheckerHelper,
	#category : #'EDAT-Tools'
}

{ #category : #helper }
EDATCheckerHelper >> readFromContract: aBlock [
	| result file fileContents |
	file := aBlock value.
	fileContents := file readStream.
	result := NeoJSONReader fromString: fileContents.
	fileContents close.
	^ result
]
