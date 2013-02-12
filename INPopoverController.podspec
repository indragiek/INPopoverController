Pod::Spec.new do |s|
	s.name					= 'INPopoverController'
	s.version				= '0.0.1'
	s.summary				= 'A customizable popover controller for Mac OS X'
	s.homepage				= 'https://github.com/indragiek/INPopoverController'
	s.author   				= { 'Indragie Karunaratne' => 'i@indragie.com' }
	s.source   				= { :git => 'https://github.com/indragiek/INPopoverController.git' }
	s.source_files			= '*.{h,m}'
 	s.public_header_files	= '*.h'
	s.platform 				= :osx
	s.requires_arc 			= true
	s.license				= 'BSD'
end
