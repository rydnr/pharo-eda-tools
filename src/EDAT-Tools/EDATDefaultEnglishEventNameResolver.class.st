Class {
	#name : #EDATDefaultEnglishEventNameResolver,
	#superclass : #Object,
	#traits : 'EDACSourceCodeHelper + EDACLanguageHelper',
	#classTraits : 'EDACSourceCodeHelper classTrait + EDACLanguageHelper classTrait',
	#category : #'EDAT-Tools'
}

{ #category : #resolving }
EDATDefaultEnglishEventNameResolver >> resolve: aCommandName [
	| result aux |
	result := nil.
	aux := aCommandName allRegexMatches: '([^_]*)'.
	aux size > 2
		ifTrue: [ | verb rest past |
			verb := aux at: 1.
			rest := aux allButFirst.
			past := self verbInPastTense: verb.
			result := ''.
			rest
				keysAndValuesDo: [ :i :noun | 
					i > 1
						ifTrue: [ result := result , '_' ].
					result := result , noun ].
			result := result , past ].
	^ result
]
