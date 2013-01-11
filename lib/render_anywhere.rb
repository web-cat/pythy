# found at:
#   http://blog.choonkeat.com/weblog/2006/08/rails-calling-r.html
# with modifications found at:
#   http://stackoverflow.com/questions/6318959/rails-how-to-render-a-view-partial-in-a-model

# 
# lib/render_anywhere.rb
# 
# Render templates outside of a controller or view.
# 
# Simply mixin this module to your existing class, for example:
# 
#   class MyTemplater < ActiveRecord::Base
#     include RenderAnywhere
# 
# And you can use render() method that works the same as ActionView::Base#render
# 
#   obj = MyTemplater.new
#   obj.html = obj.render :file => '/shared/header'
# 
# 
module RenderAnywhere

  # -------------------------------------------------------------
  def render(options, assigns = {})
    view = ActionView::Base.new(ActionController::Base.view_paths, assigns)

    # FIXME: I shouldn't have to manually extend with all the helpers; there
    # should be a way to get the list of modules. Rails 2 could do this, but
    # that way doesn't exist in Rails 3, and I can't find a Rails 3 way.
    view.extend ApplicationHelper
    view.extend CodeHelper

    view.render options
  end


  # -------------------------------------------------------------
  def template_exists?(path, assigns = {})
    view = ActionView::Base.new(ActionController::Base.view_paths, assigns)
    view.extend ApplicationHelper
    view.extend CodeHelper
    view.pick_template_extension(path) rescue false
  end

end
