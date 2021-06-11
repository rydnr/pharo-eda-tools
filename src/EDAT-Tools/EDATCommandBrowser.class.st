Class {
	#name : #EDATCommandBrowser,
	#superclass : #ComposableModel,
	#instVars : [
		'list'
	],
	#category : #'EDAT-Tools'
}

{ #category : #ui }
EDATCommandBrowser class >> defaultSpec [
	^ SpecLayout composed
		add: #list;
		yourself
]

{ #category : #ui }
EDATCommandBrowser >> initializeWidgets [
	list := self newList.
	list items: ((EDACommand allSubclasses select: [ :commandClass | (commandClass name beginsWith: 'EDA') not ]) sorted: [ :a :b | a name < b name ]).
	self focusOrder add: list
]

{ #category : #ui }
EDATCommandBrowser >> list [
	^ list
]

{ #category : #ui }
EDATCommandBrowser >> title [
	^ 'EDA Commands'
]

{ #category : #ui }
EDATCommandBrowser >> whenSelectedItemChanged: aBlock [
	list whenSelectedItemChanged: aBlock
]
