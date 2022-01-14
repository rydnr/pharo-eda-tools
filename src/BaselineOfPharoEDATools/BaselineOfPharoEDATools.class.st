Class {
	#name : #BaselineOfPharoEDATools,
	#superclass : #BaselineOf,
	#category : #BaselineOfPharoEDATools
}

{ #category : #baselines }
BaselineOfPharoEDATools >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec blessing: #baseline.
			self includePharoEDACommon: spec.
			self declarePackagesIn: spec.
			self declareGroupsIn: spec ]
]

{ #category : #meta }
BaselineOfPharoEDATools >> declareGroupsIn: spec [
	spec
		group: 'core'
			with:
			#(#'EDAT-Tools');
		group: 'tests'
			with:
			#(#'EDAT-Tools-Tests');
		group: 'default' with: #('core' 'tests')
]

{ #category : #meta }
BaselineOfPharoEDATools >> declarePackagesIn: spec [
	spec
		package: #'EDAT-Tools' with: [ spec requires: #('PharoEDACommon') ];
		package: #'EDAT-Tools-Tests'
			with: [ spec requires: #('EDAT-Tools') ]
]

{ #category : #dependencies }
BaselineOfPharoEDATools >> includePharoEDACommon: spec [
	spec
		baseline: 'PharoEDACommon'
		with: [ spec repository: 'github://rydnr/pharo-eda-common:main' ].
	^ spec
]
