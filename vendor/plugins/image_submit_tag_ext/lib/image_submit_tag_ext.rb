# -*- coding: utf-8 -*-
#
# ImageSubmitTagExt
#
# Added :disable option to image_submit_tag helper, which functions like :disable_with option of submit_tag,
# prevents the submit button being pressed when the form is submitted.
#
# Released under the MIT license
#
# Junya Ishihara <junya@champierre.com>
# http://champierre.com
#

module ActionView
  module Helpers
    module FormTagHelper
      def image_submit_tag(source, options = {})
        options.stringify_keys!
        if confirm = options.delete("confirm")
          options["onclick"] ||= ''
          options["onclick"] += "return #{confirm_javascript_function(confirm)};"
        end

        if disable = options.delete("disable")
          onclick = "#{options.delete('onclick')};" if options['onclick']

          options["onclick"] = "this.disabled = true;#{onclick}"
          options["onclick"] << "result = (this.form.onsubmit ? (this.form.onsubmit() ? this.form.submit() : false) : this.form.submit());"
          options["onclick"] << "if (result == false) { this.disabled = false; }return result;"
        end

        tag :input, { "type" => "image", "src" => path_to_image(source) }.update(options.stringify_keys)
      end
    end
  end
end