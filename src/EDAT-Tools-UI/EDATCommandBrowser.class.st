Class {
	#name : #EDATCommandBrowser,
	#superclass : #SpPresenter,
	#instVars : [
		'list'
	],
	#category : #'EDAT-Tools-UI'
}

{ #category : #layout }
EDATCommandBrowser class >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: self new;
		  yourself
]

{ #category : #initialization }
EDATCommandBrowser >> initializePresenters [

	list := self newList.
	list items: ((EDACommand allSubclasses reject: [ :commandClass | 
			  commandClass name beginsWithSubCollection: 'EDA' ]) sorted: [ :a :b | 
			 a name < b name ]).
	self focusOrder add: list
]

{ #category : #initialization }
EDATCommandBrowser >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'EDA Commands';
		initialExtent: 500 @ 350
]

{ #category : #accessing }
EDATCommandBrowser >> list [

	^ list
]

{ #category : #ui }
EDATCommandBrowser >> whenSelectedItemChanged: aBlock [
	list whenSelectedItemChanged: aBlock
]
