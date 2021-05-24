Trait {
	#name : #EDATCheckerGenerator,
	#category : #'EDAT-Tools'
}

{ #category : #api }
EDATCheckerGenerator >> generateCheckers [
	self
		compile: self checkerMethodName
		sourceCode: self checkerMethod
		inClass:
			(self class environment at: #ATSContractChecker)
		classifiedAs: self protocol
]
