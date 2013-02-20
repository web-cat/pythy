require 'net/http'

class ProxyController < ApplicationController

  # -------------------------------------------------------------
  def get
    url = URI.parse(params[:url])
    hash = params[:hash]

    # TODO verify hash

    result = get_response_with_redirect(url)
    send_data result.body,
      type: result.content_type || 'text/plain',
      disposition: 'inline',
      status: result.code
  end


  private

  # -------------------------------------------------------------
  def get_response_with_redirect(uri)
    r = Net::HTTP.get_response(uri)
    
    if r.code == "301"
      r = Net::HTTP.get_response(URI.parse(r.header['location']))
    end
    
    r
  end

end
