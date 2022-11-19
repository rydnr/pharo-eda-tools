Class {
	#name : #EDATCommandContractCheckerGenerator,
	#superclass : #EDATAbstractGenerator,
	#traits : 'EDATCheckerGenerator',
	#classTraits : 'EDATCheckerGenerator classTrait',
	#category : #'EDAT-Tools'
}

{ #category : #'instance creation' }
EDATCommandContractCheckerGenerator class >> fromExampleFile: aFile version: version application: edaApplication aggregate: aggregate [

	| result |
	result := self new
		          commandFile: aFile;
		          edaApplication: edaApplication;
		          aggregate: aggregate;
		          version: version.
	result commandRaw: result readCommandExampleFile.
	result commandJson: (NeoJSONReader fromString: result commandRaw).
	result commandName: ((result commandJson at: #meta) at: #type).
	^ result
]

{ #category : #'code generation' }
EDATCommandContractCheckerGenerator >> checkerMethod [
	| result cr space command body attrs cls commandClassName |
	cr := Character cr.
	space := Character space.
	commandClassName := self retrieveCommandClassName.
	result := WriteStream with: String new.
	result
		nextPutAll: self checkerMethodName;
		nextPut: Character cr.
	result nextPutAll: self generateSignature.
	result
		nextPutAll: '	| contract commandClass commandVars |';
		nextPut: cr.
	result
		nextPutAll: '	contract := self readCommandFromContract: ''';
		nextPutAll: self commandFile basename;
		nextPutAll: ''' version: ';
		nextPutAll: self version greaseString;
		nextPut: $.;
		nextPut: cr.
	result
		nextPutAll: '	commandClass := ''';
		nextPutAll: commandClassName;
		nextPutAll: '''.';
		nextPut: cr.
	result
		nextPutAll: '	commandVars := (self class environment at: commandClass asSymbol) instVarNames asSet.';
		nextPut: cr.
	command := self commandJson.
	body := command at: #body.
	result
		nextPutAll: '	self assert: commandVars equals: #(';
		nextPut: cr.
	attrs := (body associations reject: [ :assoc | self class skippedCommandAttributes anySatisfy: [ :attr | attr = assoc key ] ])
		collect: [ :a | a key ].
	cls := self class environment at: commandClassName asSymbol.
	attrs := self allAttributesOf: cls including: attrs.
	attrs
		do: [ :attr | 
			result
				nextPut: $#;
				nextPutAll: attr;
				nextPut: space ].
	result
		nextPutAll: ') asSet';
		nextPut: cr.
	^ result contents
]

{ #category : #'code generation' }
EDATCommandContractCheckerGenerator >> checkerMethodName [
	^ 'test' , (self underscoreSeparatedToCamelCase: self commandName)
		, 'RespectsContractV' , self version greaseString
]
