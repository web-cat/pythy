require 'net/http'

class ProxyController < ApplicationController

  # -------------------------------------------------------------
  def get
    url = URI.parse(params[:url])
    hash = params[:hash]

    # TODO verify hash

    result = Net::HTTP.get_response(url)
    send_data result.body,
      type: result.content_type || 'text/plain',
      disposition: 'inline',
      status: result.code
  end

end
