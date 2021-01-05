# frozen_string_literal: true
module HykuAddons
  module GoogleTagManagerHelper


    def render_gtm_head
      tenant_gtm_id = current_account.settings['gtm_id']
      return '' if tenant_gtm_id.blank?

      <<-HTML.strip_heredoc.html_safe
      <!-- Google Tag Manager -->
      <script>
       (function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
            new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
        j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
        'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
       })(window,document,'script','dataLayer', "#{tenant_gtm_id}");
      </script>
     <!-- End Google Tag Manager -->
      HTML
    end

    def render_gtm_body
      #render 'layouts/google/gtm_body'
      tenant_gtm_id = current_account.settings['gtm_id']
      return '' if tenant_gtm_id.blank?

      <<-HTML.strip_heredoc.html_safe
       <!-- Google Tag Manager (noscript) -->

      <noscript><iframe src='https://www.googletagmanager.com/ns.html?id="#{tenant_gtm_id}"'
                    height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>

      <!-- End Google Tag Manager (noscript) -->
      HTML
    end

  end
end
