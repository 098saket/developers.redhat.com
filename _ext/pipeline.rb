require 'zurb-foundation'
require 'sections'
require 'common_dir'
require 'aweplug/extensions/kramdown_quickstart'
require 'jboss_developer'
require 'nav'

Awestruct::Extensions::Pipeline.new do
  # parse AsciiDoc documents and create page variables out of their sections
  extension Awestruct::Extensions::Sections.new

  extension Aweplug::Extensions::Kramdown::Quickstart.new '_eap-quickstarts', 'get-started-item','/quickstarts'

  # Load indexifier
  extension Awestruct::Extensions::Indexifier.new [/google4775292ed26aeefd.html/]

  extension Awestruct::Extensions::Nav.new
 
  extension Awestruct::Extensions::CommonDir.new

  helper Awestruct::Extensions::Partial
  helper JBoss::Developer::Utilities
end

