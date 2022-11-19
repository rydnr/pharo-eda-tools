Class {
	#name : #EDATCompositeGenerator,
	#superclass : #EDATGenerator,
	#instVars : [
		'generatorClasses'
	],
	#category : #'EDAT-Tools'
}

{ #category : #protected }
EDATCompositeGenerator >> description [
	^ 'Composite generator for ', self generatorClasses
]

{ #category : #protected }
EDATCompositeGenerator >> doGenerate [
	^ nil
]

{ #category : #api }
EDATCompositeGenerator >> generate [

	| generators |
	generators := self generatorClasses collect: [ :generatorClass | 
		              generatorClass
			              fromExampleFile: self commandFile
			              version: self version
			              application: self edaApplication
			              aggregate: self aggregate
			              commandNameResolver: self commandNameResolver
			              andEventNameResolver: self eventNameResolver ].
	generators
		keysAndValuesDo: [ :index :generator | generator generate ]
		displayingProgress: [ :index :generator | generator buildMessage ]
]

{ #category : #accessing }
EDATCompositeGenerator >> generatorClasses [
	^ generatorClasses
]

{ #category : #accessing }
EDATCompositeGenerator >> generatorClasses: aCollection [
	generatorClasses := aCollection
]

{ #category : #initialization }
EDATCompositeGenerator >> initialize [

	self generatorClasses:
		(self sortGeneratorClasses: EDATGenerator allSubclasses)
]

{ #category : #initialization }
EDATCompositeGenerator >> sortGeneratorClasses: aCollection [
	^ (aCollection reject: [ :cls | cls = self class ]) asSortedCollection: [ :first :second | (first shouldRunAfter: second) not ]
]
