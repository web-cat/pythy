class HomeController < FriendlyUrlController

  # -------------------------------------------------------------
  def index
    if @offerings.any?
      respond_to do |format|
        format.html do
          render 'index'
        end
      end
    else
      not_found
    end
  end

end
