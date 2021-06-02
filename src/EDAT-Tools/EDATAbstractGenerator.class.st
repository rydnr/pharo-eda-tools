Class {
	#name : #EDATAbstractGenerator,
	#superclass : #Object,
	#traits : 'EDACSourceCodeHelper + EDATCheckerHelper + EDACLogging',
	#classTraits : 'EDACSourceCodeHelper classTrait + EDATCheckerHelper classTrait + EDACLogging classTrait',
	#instVars : [
		'commandName',
		'commandRaw',
		'commandJson',
		'commandFile',
		'appName',
		'aggregate',
		'eventJson',
		'eventRaw',
		'eventFile',
		'eventName',
		'version'
	],
	#category : #'EDAT-Tools'
}

{ #category : #customization }
EDATAbstractGenerator class >> skippedAggregateAttributes [
	^ #('tenant' 'id' 'version' 'scopeContext' 'scopeKey' 'agent')
]

{ #category : #customization }
EDATAbstractGenerator class >> skippedCommandAttributes [
	^ #('applicationKey' 'commandId' 'aggregateRootId' 'originalTimestamp' 'aggregateRootVersion' 'version' 'id' 'scopeContext' 'scopeKey' 'tenant' 'agent' 'correlationId')
]

{ #category : #customization }
EDATAbstractGenerator class >> skippedEventAttributes [
	^ #('id' 'commandId' 'aggregateRootClass' 'timestamp' 'aggregateRootVersion' 'version' 'scopeContext' 'scopeKey' 'tenant' 'agent')
]

{ #category : #accessing }
EDATAbstractGenerator >> aggregate [
	^ aggregate
]

{ #category : #accessing }
EDATAbstractGenerator >> aggregate: aString [
	aggregate := aString
]

{ #category : #helper }
EDATAbstractGenerator >> aggregateClass [
	^ (self appName , (self underscoreSeparatedToCamelCase: self aggregate))
]

{ #category : #accessing }
EDATAbstractGenerator >> appName [
	^ appName
]

{ #category : #accessing }
EDATAbstractGenerator >> appName: aString [
	appName := aString
]

{ #category : #accessing }
EDATAbstractGenerator >> commandContainsAttribute: attr [
	| body |
	body := commandJson at: #body.
	^ body at: attr ifPresent: [ true ] ifAbsent: [ false ]
]

{ #category : #accessing }
EDATAbstractGenerator >> commandFile [
	^ commandFile
]

{ #category : #accessing }
EDATAbstractGenerator >> commandFile: aString [
	commandFile := aString
]

{ #category : #accessing }
EDATAbstractGenerator >> commandJson [
	^ commandJson
]

{ #category : #accessing }
EDATAbstractGenerator >> commandJson: aString [
	commandJson := aString
]

{ #category : #accessing }
EDATAbstractGenerator >> commandName [
	^ commandName
]

{ #category : #accessing }
EDATAbstractGenerator >> commandName: aString [
	commandName := aString
]

{ #category : #accessing }
EDATAbstractGenerator >> commandRaw [
	^ commandRaw
]

{ #category : #accessing }
EDATAbstractGenerator >> commandRaw: aString [
	commandRaw := aString
]

{ #category : #helper }
EDATAbstractGenerator >> eventClassForContract: aString [
	^ ATSEDAApplication eventClassPrefix , (self dotSeparatedToCamelCase: aString)
]

{ #category : #accessing }
EDATAbstractGenerator >> eventFile [
	^ eventFile
]

{ #category : #accessing }
EDATAbstractGenerator >> eventFile: aString [
	eventFile := aString
]

{ #category : #accessing }
EDATAbstractGenerator >> eventJson [
	^ eventJson
]

{ #category : #accessing }
EDATAbstractGenerator >> eventJson: aString [
	eventJson := aString
]

{ #category : #accessing }
EDATAbstractGenerator >> eventName [
	^ eventName
]

{ #category : #accessing }
EDATAbstractGenerator >> eventName: aString [
	eventName := aString
]

{ #category : #accessing }
EDATAbstractGenerator >> eventRaw [
	^ eventRaw
]

{ #category : #accessing }
EDATAbstractGenerator >> eventRaw: aString [
	eventRaw := aString
]

{ #category : #helper }
EDATAbstractGenerator >> findRelativePathBetweenFile: aFileReference andFolder: aFolderReference [
	^ (self recursivelyFindRelativePathBetweenFile: aFileReference  andFolder: aFolderReference) reverse
]

{ #category : #helper }
EDATAbstractGenerator >> isCreate: json [
	| type meta |
	meta := json at: #meta ifAbsent: [ nil ].
	type := meta
		ifNil: [ '' ]
		ifNotNil: [ :m | m at: #type ifAbsent: [ nil ] ].
	^ '^CREATE_.+' asRegexIgnoringCase matches: type
]

{ #category : #helper }
EDATAbstractGenerator >> isCreateCommand [
	^ self isCreate: commandJson
]

{ #category : #helper }
EDATAbstractGenerator >> isCreatedEvent [
	^ self isCreate: commandJson
]

{ #category : #helper }
EDATAbstractGenerator >> isDelete: json [
	| delete meta |
	meta := json at: #meta ifAbsent: [ nil ].
	delete := meta
		ifNil: [ nil ]
		ifNotNil: [ :m | m at: #delete ifAbsent: [ nil ] ].
	^ delete isNotNil and: [ delete ]
]

{ #category : #helper }
EDATAbstractGenerator >> isDeleteCommand [
	^ self isDelete: commandJson
]

{ #category : #helper }
EDATAbstractGenerator >> isDeletedEvent [
	^ self isDelete: commandJson

]

{ #category : #helper }
EDATAbstractGenerator >> protocol [
	^ self generatedProtocolFor: self version
]

{ #category : #helper }
EDATAbstractGenerator >> readCommandExampleFile [
	| result stream |
	stream := self commandFile readStream.
	result := stream contents.
	stream close.
	^ result
]

{ #category : #helper }
EDATAbstractGenerator >> readCommandFromContract: contractName version: version [
	^ self readFromContract: [ self retrieveCommandFile: contractName version: version ]
]

{ #category : #helper }
EDATAbstractGenerator >> readEventExampleFile [
	| result stream |
	stream := self eventFile exists
		ifTrue: [ self eventFile readStream ]
		ifFalse: [ nil ].
	result := stream ifNil: [ nil ] ifNotNil: [ :s | s contents ].
	stream ifNotNil: [ :s | s close ].
	^ result
]

{ #category : #helper }
EDATAbstractGenerator >> readFromContract: evtName version: version using: aBlock [
	| result file fileContents |
	file := aBlock cull: evtName cull: version.
	fileContents := file readStream.
	result := NeoJSONReader fromString: fileContents.
	fileContents close.
	^ result
]

{ #category : #helper }
EDATAbstractGenerator >> recursivelyFindRelativePathBetweenFile: aFileReference andFolder: aFolderReference [
	((aFileReference isDirectory and: [ aFileReference = aFolderReference ])
		or: [ aFileReference parent = aFolderReference ])
		ifTrue: [ ^ OrderedCollection new ]
		ifFalse: [ | result |
			result := OrderedCollection with: aFileReference parent basename.
			result
				addAll: (self recursivelyFindRelativePathBetweenFile: aFileReference parent andFolder: aFolderReference).
			^ result ]
]

{ #category : #helper }
EDATAbstractGenerator >> retrieveAggregateAttributes [
	^ self retrieveEventAttributes
]

{ #category : #helper }
EDATAbstractGenerator >> retrieveAggregateAttributesBut: excluded [
	| result attrs |
	attrs := self retrieveAggregateAttributes.
	result := attrs select: [ :attr | (excluded includes: attr) not ].
	^ result
]

{ #category : #helper }
EDATAbstractGenerator >> retrieveAggregateClassName [
	^ self appName , (self underscoreSeparatedToCamelCase: self aggregate)
]

{ #category : #helper }
EDATAbstractGenerator >> retrieveAggregateClasses [
	"Retrieves all aggregate classes"
	^ EDAAggregateRoot allSubclasses
]

{ #category : #helper }
EDATAbstractGenerator >> retrieveAggregateIdNames [
	^ self retrieveAggregateClasses
	select: [ :cls | (cls name greaseString beginsWith: self appName) ]
		thenCollect: [ :cls |
			((self remove: self appName fromBeginningOf: cls name greaseString) , 'Id') uncapitalized ]
]

{ #category : #helper }
EDATAbstractGenerator >> retrieveAttributeValue: attr in: dict [
	| result body |
	body := dict at: #body.
	result := body at: attr ifAbsent: [ result := '' ].
	^ result
]

{ #category : #helper }
EDATAbstractGenerator >> retrieveAttributesFrom: dict [
	| vars body |
	body := dict at: #body.
	vars := body keys asSortedCollection.
	^ vars
]

{ #category : #helper }
EDATAbstractGenerator >> retrieveCommandAttributeValue: attr [
	^ self retrieveAttributeValue: attr in: self commandJson
]

{ #category : #helper }
EDATAbstractGenerator >> retrieveCommandAttributes [
	^ self retrieveAttributesFrom: self commandJson
]

{ #category : #helper }
EDATAbstractGenerator >> retrieveCommandAttributesBut: excluded [
	| result attrs |
	attrs := self retrieveCommandAttributes.
	result := attrs select: [ :attr | (excluded includes: attr) not ].
	^ result

]

{ #category : #helper }
EDATAbstractGenerator >> retrieveCommandClassName [
	^ self appName , (self toCamelCase: self commandName)
]

{ #category : #helper }
EDATAbstractGenerator >> retrieveEventAttributeValue: attr [
	^ self retrieveAttributeValue: attr in: self eventJson
]

{ #category : #helper }
EDATAbstractGenerator >> retrieveEventAttributes [
	^ self retrieveAttributesFrom: self eventJson
]

{ #category : #helper }
EDATAbstractGenerator >> retrieveEventAttributesBut: excluded [
	| result attrs |
	attrs := self retrieveEventAttributes.
	result := attrs select: [ :attr | (excluded includes: attr) not ].
	^ result
]

{ #category : #helper }
EDATAbstractGenerator >> retrieveEventClassName [
	^ self appName , (self toCamelCase: self eventName)
]

{ #category : #helper }
EDATAbstractGenerator >> retrieveEventName [
	| result aux |
	result := nil.
	aux := self eventName allRegexMatches: '([^_]*)'.
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

{ #category : #helper }
EDATAbstractGenerator >> retrieveImplementedCommandsFor: appName [
	"Finds all pragmas like [appName]CommandName: #[COMMAND_NAME]"

	| cmds |
	cmds := {} asDictionary.
	EDACommand
		allSubclassesDo: [ :cls | (Pragma allNamed: (appName asLowercase , 'CommandName:') asSymbol in: cls class) do: [ :pragma | cmds at: (pragma arguments at: 1) put: pragma methodClass ] ].
	^ cmds
]

{ #category : #helper }
EDATAbstractGenerator >> retrieveMaxVersion [
	| parent |
	parent := self commandFile parent parent.
	parent entries isEmpty
		ifTrue: [ ^ -1 ]
		ifFalse: [ 
			^ ((parent entries
				select: [ :entry | entry isDirectory and: [ entry basename beginsWith: 'v' ] ]
				thenCollect: [ :entry | (EDAGenerator new removePrefix: 'v' from: entry basename) asInteger ])
				asOrderedCollection sort: [ :first :second | first < second ]) last ]
]

{ #category : #helper }
EDATAbstractGenerator >> retrieveRepositoryClassName [
	^ self appName , (self underscoreSeparatedToCamelCase: self aggregate) , 'Repository'
]

{ #category : #helper }
EDATAbstractGenerator >> retrieveVersion [
	^ (self removePrefix: 'v' from: self commandFile parent basename) asInteger
]

{ #category : #accessing }
EDATAbstractGenerator >> version [
	^ version
]

{ #category : #accessing }
EDATAbstractGenerator >> version: aNumber [
	version := aNumber
]
