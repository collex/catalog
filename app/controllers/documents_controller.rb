require 'rest_client'

class DocumentsController < ApplicationController

  ALLOWED_IP =  Rails.application.secrets.authentication['allowed_ip']

  def typewright_enable

    if check_ip == true
      set_tw_status( params[:uri], true )
    else
      render :text => "You do not have permission to do this.", :status => :unauthorized 
    end
  end

  def typewright_disable

    if check_ip == true
      set_tw_status( params[:uri], false )
    else
      render :text => "You do not have permission to do this.", :status => :unauthorized
    end

  end

  def title

    if check_ip == true
      get_title( params[:uri] )
    else
      render :text => "You do not have permission to do this.", :status => :unauthorized
    end

  end

  private

  def get_title( uri )

    query = {}
    query['q'] = "uri:#{uri}"
    is_test = Rails.env == 'test' ? :test : :live
    solr = Solr.factory_create( is_test )
    document = solr.details( query )
    if document.nil? == false
      render :text => document['title'], :status => :ok
    else
      render :text => "NOT FOUND", :status => :not_found
    end
  end

  def set_tw_status( uri, status )
    begin
      query = {}
      query['q'] = "uri:#{uri}"
      is_test = Rails.env == 'test' ? :test : :live
      solr = Solr.factory_create( is_test )
      document = solr.details( query )
      if document.nil? == false
        document['typewright'] = status
        solr.add_object( document, false, true )
      end
      render :text => "OK", :status => :ok

    #rescue RestClient::Exception => rest_error
    #  render_error( rest_error.response, rest_error.http_code )
    rescue ArgumentError => e
      render_error(e.to_s)
    rescue SolrException => e
      render_error(e.to_s, e.status( ) )
    rescue Exception => e
      ExceptionNotifier.notify_exception(e, :env => request.env)
      render_error("Something unexpected went wrong.", :internal_server_error)
    end

  end

  def update_solr( doc )
    solr_url = "#{SOLR_URL}/update/json?commit=true"
    RestClient.post solr_url, doc, :content_type => "application/json"
  end

  def check_ip
    ip = request.headers['REMOTE_ADDR']
    return ip == ALLOWED_IP

  end
end
