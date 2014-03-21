Pod::Spec.new do |s|
	s.name					= 'INPopoverController'
	s.version				= '0.0.1'
	s.summary				= 'A customizable popover controller for Mac OS X'
	s.homepage				= 'https://github.com/indragiek/INPopoverController'
	s.author   				= { 'Indragie Karunaratne' => 'indragiek@gmail.com' }
	s.source   				= { :git => 'https://github.com/indragiek/INPopoverController.git' }
	s.source_files			= 'INPopoverController/*.{h,m}'
 	s.public_header_files	= 'INPopoverController/*.h'
	s.platform 				= :osx
	s.requires_arc 			= true
	s.license				= 'BSD'
	s.frameworks			= 'QuartzCore'
end
