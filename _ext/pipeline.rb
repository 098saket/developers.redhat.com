require 'zurb-foundation'
require 'common_dir'
require 'upstream_projects'
require 'aweplug/extensions/kramdown_quickstart'
require 'aweplug/extensions/sections'
require 'aweplug/extensions/asciidoc_example'
require 'jboss_developer'
require 'nav'
require 'stacks'
require 'product'
require 'vimeo'

Awestruct::Extensions::Pipeline.new do
  # parse AsciiDoc documents and create page variables out of their sections
  extension Aweplug::Extensions::Sections.new

  extension JBoss::Developer::Extensions::UpstreamProjects.new

  extension Aweplug::Extensions::Kramdown::Quickstart.new(repository: '_eap-quickstarts', layout: 'get-started-item', 
                                                          output_dir: '/quickstarts/eap')

  extension JBoss::Developer::Extensions::Stacks.new 'stacks.yaml', 'get-started-item', '_jdf-stack'
  
  extension Aweplug::Extensions::AsciidocExample.new(repository: '_ticket-monster', directory: 'tutorial', layout:'get-started-item', 
                                                     output_dir: 'ticket-monster', additional_excludes: ['ticket-monster.asciidoc'])

  # Load indexifier
  extension Awestruct::Extensions::Indexifier.new [/google4775292ed26aeefd.html/]

  extension JBoss::Developer::Extensions::Nav.new
 
  extension JBoss::Developer::Extensions::CommonDir.new
  # Must be loaded after CommonDir
  extension JBoss::Developer::Extensions::Product.new

  # Generate a sitemap.xml
  extension Awestruct::Extensions::Sitemap.new

  helper Awestruct::Extensions::Partial
  helper JBoss::Developer::Utilities
  helper JBoss::Developer::Vimeo
end

