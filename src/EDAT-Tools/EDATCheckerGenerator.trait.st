Trait {
	#name : #EDACTCheckerGenerator,
	#category : #'EDACT-Tools'
}

{ #category : #api }
EDACTCheckerGenerator >> generateCheckers [
	self
		compile: self checkerMethodName
		sourceCode: self checkerMethod
		inClass:
			(self class environment at: #ATSContractChecker)
		classifiedAs: self protocol
]
