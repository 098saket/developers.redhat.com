module JBoss::Developer::Extensions
  # Post-process product metadata from product.yml, applying conventions
  class Product
    
    def initialize
      @default_guide_formats = {"html" => {}, "html-single" => {}, "pdf" => {}, "epub" => {}}
      @default_download_assets = {
        "installer" => {"name" => "Installer"},
        "zip" => {"name" => "ZIP"}, 
        "sha1" => {"name" => "SHA1"}, 
        "md5" => {"name" => "MD5"}, 
        "release_notes" => {"name" => "Release Notes"}, 
        "source" => {"name" => "Source"}}
    end


    def execute(site)
      site.products = {}
      site.pages.each do |page|
        if page.product
          product = page.product
          id = page.parent_dir
          if not site.products[id] 
            # Set the product id to the parent dir
            product.id = id
            # Set the forum url to the default value, if not set
            product.forum_url ||= site.product_forum_base_url + "jboss" + product.id
            if product.current_version
              # Set the product's current major.minor version
              product.current_minor_version = product.current_version[/^([0-9]*\.[0-9]*)/, 1]
            end
            downloads(product, site)
            docs(product, site)
            # Store the product in the global product map
            site.products[product.id] = product
          end
        end
      end
    end

    def downloads(product, site)
      # Process the downloads declared for the product
      a = {}
      if product.downloads
        product.downloads.each do |k, v|
          download = OpenStruct.new(v)
          download.version ||= k.gsub(/_/, ' ').to_s
          download.description ||= product.abbreviated_name
          download.release_date = download.release_date ? download.release_date : Date.today
          download.assets ||= @default_download_assets.clone
          b = []
          download.assets.each do |l, w|
            asset = OpenStruct.new(w)
            asset.name ||= @default_download_assets.has_key?(l) ? @default_download_assets[l]["name"] : l.gsub(/_/, ' ')
            asset.url ||= "#{site.download_manager_file_base_url}/#{product.id}/#{download.version}/#{asset.name}"
            b << asset 
          end
          download.assets = b
          a[download.version] = download
        end
        product.downloads = Hash[a.sort_by{|k, v| v.release_date}.reverse]
        product.current_download = product.downloads[product.current_version]
        product.older_downloads = product.downloads.clone
        product.older_downloads.delete(product.current_version)
      end
    end

    def docs(product, site)
      # Set the documentation url to the default value, if not set
      product.documentation_url ||= site.product_documentation_base_url + "/" + product.abbreviated_name.gsub(/ /, '_')
      # Process the guides declared for the product
      a = []
      if product.guides
        product.guides.each do |k, v|
          guide = OpenStruct.new(v)
          guide.name ||= k.gsub(/_/, ' ')
          # We do some special magic for release notes, to avoid the guide name needing continual updates
          if k == "Release_Notes"
            guide.dir_name = product.current_version[/^([0-9]*\.[0-9]*\.[0-9])/, 1] + "_Release_Notes"
          else
            guide.dir_name = k
          end
          guide.formats ||= @default_guide_formats.clone
          b = []
          guide.formats.each do |l, w|
            format = OpenStruct.new(w)
            format.name ||= l
            format.url ||= "#{product.documentation_url}/#{product.current_minor_version}/#{format.name}/#{guide.dir_name}"
            b << format
          end
          guide.formats = b
          a << guide
        end
      end
      product.guides = a
    end
  end
end

