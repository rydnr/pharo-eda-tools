"
**Class**

I'm a baseline to load PharoEDA Tools.

**Responsibilities**

Guide Metacello to load PharoEDA-Tools with its dependencies.

**Collaborators**

Metacello
"
Class {
	#name : #BaselineOfPharoEDATools,
	#superclass : #BaselineOf,
	#category : #BaselineOfPharoEDATools
}

{ #category : #meta }
BaselineOfPharoEDATools class >> declareGroupsIn: spec [

	spec
		group: 'core' with: #( #'EDAT-Tools' );
		group: 'ui' with: #( #'EDAT-Tools' #'EDAT-Tools-UI');
		group: 'tests' with: #( #'EDAT-Tools-Tests' );
		group: 'default' with: #( 'core' 'ui' 'tests' )
]

{ #category : #meta }
BaselineOfPharoEDATools class >> declarePackagesIn: spec [
	spec
		package: #'EDAT-Tools' with: [ spec requires: #('PharoEDACommon') ];
		package: #'EDAT-Tools-UI' with: [ spec requires: #('PharoEDACommon' 'Spec2') ];
		package: #'EDAT-Tools-Tests'
			with: [ spec requires: #('EDAT-Tools') ]
]

{ #category : #dependencies }
BaselineOfPharoEDATools class >> includePharoEDACommon: spec [
	spec
		baseline: 'PharoEDACommon'
		with: [ spec repository: 'github://rydnr/pharo-eda-common:main' ].
	^ spec
]

{ #category : #dependencies }
BaselineOfPharoEDATools class >> includeSpec: spec [
	spec
		baseline: 'Spec2'
		with: [ spec repository: 'github://pharo-spec/Spec:Pharo10' ].
	^ spec
]

{ #category : #baselines }
BaselineOfPharoEDATools >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		spec blessing: #baseline.
		spec postLoadDoIt: #postload:package:.
		self class includePharoEDACommon: spec;
		 includeSpec: spec;
		 declarePackagesIn: spec;
		 declareGroupsIn: spec ]
]

{ #category : #hooks }
BaselineOfPharoEDATools >> postload: loader package: packageSpec [

	| location |
	location := (IceRepository registry detect: [ :each | 
		             each name = 'pharo-eda-tools' ]) location.
	EDACIconProvider addDefaultLocation: location / 'resources' / 'icons'.
	EDACTranslationProvider addDefaultLocation:
		location / 'resources' / 'l10n'
]
