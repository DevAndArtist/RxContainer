# Uncomment the next line to define a global platform 
# for your project
platform :ios, '10.0'

abstract_target 'project' do

  # Comment the next line if you're not using Swift and 
  # don't want to use dynamic frameworks
  use_frameworks!

  pod 'RxSwift', :git => 'https://github.com/ReactiveX/RxSwift.git', :branch => 'swift4.0'
  pod 'SwiftLint', :configurations => ['Debug']

  target 'RxContainer' do
    # The target 'RxContainer' has its own copies of all 
    # pods from abstract target 'project' (inherited)
  end

  target 'RxContainerTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
