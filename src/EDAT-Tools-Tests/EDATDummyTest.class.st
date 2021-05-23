Class {
	#name : #EDATDummyTest,
	#superclass : #TestCase,
	#instVars : [
		'a',
		'b'
	],
	#category : #'EDAT-Tools-Tests'
}

{ #category : #tests }
EDATDummyTest >> testTautology [
	self assert: true
]
