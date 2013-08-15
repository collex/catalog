class CorrectionsController < ApplicationController
  require 'uri'
  
  def create
    federation = Federation.find_by_name(params[:federation])
    ip = request.headers['REMOTE_ADDR']
    if federation && ip == federation.ip
      # corrected text is stored in a the 'correctedtext' directory that is a peer
      # to the main rdf directory
      out_path = RDF_PATH
      idx = out_path.rindex('/')
      out_path = "#{out_path[0...idx]}/correctedtext/#{params['archive']}"
      
      # Ensure that the out directory exists
      if !File.exist?(out_path)
        FileUtils.mkdir_p out_path  
      end
      
      # create a filename from the URI. URI format is like this:
      # lib://ECCO/1237801200
      # The ECCO part is already handled by the directory name above, so the
      # only unique bit needed is the number on the end
      doc_file_name = "#{File.basename( URI.parse(params['uri']).path)}.txt"
      File.open("#{out_path}/#{doc_file_name}", 'w') {|f| f.write(params['text']) }
      
      render :text => "Not yet implemented", :status => :not_implemented  
    else
      render :text => "You do not have permission to do this.", :status => :unauthorized 
    end
  end
end
