Class {
	#name : #EDATAbstractGeneratorTest,
	#superclass : #TestCase,
	#category : #'EDAT-Tools-Tests'
}

{ #category : #running }
EDATAbstractGeneratorTest >> setUp [
	EDAAggregateRoot
		subclass: #EDADummyAggregateRoot
		instanceVariableNames: ''
		classVariableNames: ''
		package: 'EDA-Tools-Tests'
]

{ #category : #running }
EDATAbstractGeneratorTest >> tearDown [
	RBRefactoringManager instance addRefactoring: (RBRemoveClassRefactoring classNames: { #EDADummyAggregateRoot } ) transform.

]

{ #category : #tests }
EDATAbstractGeneratorTest >> testFindRelativePathBetweenFileAndFolder [
	| instance |
	instance := EDATAbstractGenerator new.
	self
		assert: (instance findRelativePathBetweenFile: FileSystem disk workingDirectory / 'test.txt' andFolder: FileSystem disk workingDirectory)
		equals: #() asOrderedCollection.
	self
		assert:
			(instance
				findRelativePathBetweenFile: FileSystem disk workingDirectory / 'contracts' / 'commands' / 'v1' / 'create.tag.example.json'
				andFolder: FileSystem disk workingDirectory)
		equals: #('contracts' 'commands' 'v1') asOrderedCollection
]

{ #category : #tests }
EDATAbstractGeneratorTest >> testRemoveClassLiteralFromMetaClassName [
	| instance |
	instance := EDATAbstractGenerator new.
	self assert: (instance removeClassLiteralFromMetaClassName: self class className) equals: self class greaseString
]

{ #category : #tests }
EDATAbstractGeneratorTest >> testRetrieveAggregateClasses [
	| instance |
	instance := EDATAbstractGenerator new.
	self assert: (instance retrieveAggregateClasses select: [ :c | c class greaseString = 'EDADummyAggregateRoot class' ]) isNotEmpty
]

{ #category : #tests }
EDATAbstractGeneratorTest >> testRetrieveAggregateIdNames_does_not_include_aggregates_from_other_applications [

	| instance |
	instance := EDATAbstractGenerator new.
	self assert:
		(instance retrieveAggregateIdNames includes: 'dummyAggregateRootId')
			not.
	self assert:
		(instance retrieveAggregateIdNames includes:
			 'eDADummyAggregateRootId') not
]

{ #category : #tests }
EDATAbstractGeneratorTest >> testRetrieveCommandAttributes [
	| generator |
	generator := EDATAbstractGenerator new.
	generator
		commandJson:
			{(#body
				->
					{(#a -> 1).
					(#b -> 2).
					(#c -> 3)} asDictionary)} asDictionary.
	self assert: generator retrieveCommandAttributes equals: #(#a #b #c) asSortedCollection
]

{ #category : #tests }
EDATAbstractGeneratorTest >> testRetrieveCommandAttributesBut [
	| generator |
	generator := EDATAbstractGenerator new.
	generator
		commandJson:
			{(#body
				->
					{(#a -> 1).
					(#b -> 2).
					(#c -> 3)} asDictionary)} asDictionary.
	self assert: (generator retrieveCommandAttributesBut: #('a')) equals: #(#b #c) asSortedCollection.
	generator
		commandJson:
			{(#body
				->
					{(#answers -> 'a').
					(#applicantKey -> 'b').
					(#applicationKey -> 'c').
					(#contestId -> 'd').
					(#firstSubmissionDate -> 'e').
					(#formId -> 'f').
					(#language -> 'g').
					(#origin -> 'h').
					(#recoveryKey -> 'i').
					(#sections -> 'j').
					(#status -> 'k').
					(#submissionDate -> 'l')} asDictionary)} asDictionary.
	self
		assert: (generator retrieveCommandAttributesBut: #('applicationKey'))
		equals:
			#(#answers #applicantKey #contestId #firstSubmissionDate #formId #language #origin #recoveryKey #sections #status #submissionDate)
				asSortedCollection
]

{ #category : #tests }
EDATAbstractGeneratorTest >> testRetrieveMaxVersion [
	| instance tempFolder commandFolder |
	instance := EDATAbstractGenerator new.
	tempFolder := (FileSystem workingDirectory / '.test-contracts') nextVersion createDirectory.
	commandFolder := tempFolder / 'commands' / 'v599'.
	commandFolder parent createDirectory.
	commandFolder createDirectory.
	instance commandFile: commandFolder / 'sample.command.example.json'.
	[ self assert: instance retrieveMaxVersion equals: 599 ]
		ensure: [ commandFolder delete. commandFolder parent delete. tempFolder delete ]
]

{ #category : #tests }
EDATAbstractGeneratorTest >> testRetrieveVersion [
	| instance |
	instance := EDATAbstractGenerator new.
	instance commandFile: FileSystem workingDirectory / 'contracts' / 'v5' / 'sample.example.json'.
	self assert: instance retrieveVersion equals: 5.
	instance commandFile: FileSystem workingDirectory / 'contracts' / 'v46' / 'sample.example.json'.
	self assert: instance retrieveVersion equals: 46
]

{ #category : #tests }
EDATAbstractGeneratorTest >> testToDotSeparated [
	| instance |
	instance := EDATAbstractGenerator new.
	self assert: (instance upcasedToDotSeparated: 'CREATE_ROUND') equals: 'create.round'
]

{ #category : #tests }
EDATAbstractGeneratorTest >> testVerbInPastTense [
	| instance |
	instance := EDATAbstractGenerator new.
	self assert: (instance verbInPastTense: 'work') equals: 'worked'.
	self assert: (instance verbInPastTense: 'create') equals: 'created'.
	self assert: (instance verbInPastTense: 'submit') equals: 'submitted'.
	self assert: (instance verbInPastTense: 'update') equals: 'updated'.
	self assert: (instance verbInPastTense: 'delay') equals: 'delayed'.
	self assert: (instance verbInPastTense: 'build') equals: 'built'
]
