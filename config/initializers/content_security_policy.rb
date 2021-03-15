# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy do |policy|
  def asset_host
    Rails.application.config.action_controller.asset_host
  end

  def facebook_csp
    { frame: 'https://www.facebook.com' }
  end

  def typeform_csp
    { frame: 'https://form.typeform.com' }
  end

  def slideshare_csp
    { frame: %w[slideshare.net *.slideshare.net] }
  end

  def speakerdeck_csp
    { frame: %w[speakerdeck.com *.speakerdeck.com] }
  end

  def google_form_csp
    { frame: %w[google.com *.google.com] }
  end

  def resource_csp
    { media: %w[https://s3.amazonaws.com/private-assets-sv-co/ https://public-assets.sv.co/ https://s3.amazonaws.com/uploads.pupilfirst.com/] }
  end

  def youtube_csp
    { frame: 'https://www.youtube.com' }
  end

  def vimeo_csp
    { connect: %w[*.cloud.vimeo.com *.tus.vimeo.com], frame: 'https://player.vimeo.com' }
  end

  def rollbar_csp
    { connect: 'https://api.rollbar.com' }
  end

  def newrelic_csp
    {
      script: %w[https://js-agent.newrelic.com https://*.nr-data.net],
      connect: %w[https://*.nr-data.net],
    }
  end

  def style_sources
    ['fonts.googleapis.com', 'assets.calendly.com', *heap_csp[:style], asset_host] - [nil]
  end

  def connect_sources
    sources = [rollbar_csp[:connect], *vimeo_csp[:connect], *hotjar_form_csp, *fullstory_csp, *newrelic_csp[:connect], *heap_csp[:connect]]
    sources += %w[http://localhost:3035 ws://localhost:3035] if Rails.env.development?
    sources
  end

  def font_sources
    ['fonts.gstatic.com', 'https://script.hotjar.com', *heap_csp[:font], asset_host] - [nil]
  end

  def child_sources
    ['https://www.youtube.com']
  end

  def script_sources
    [*hotjar_form_csp, *usetiful_csp, *newrelic_csp[:script], *gtm_csp[:script], *heap_csp[:script]]
  end

  def hotjar_form_csp
    %w[hotjar.com *.hotjar.com wss://*.hotjar.com]
  end

  def fullstory_csp
    %w[fullstory.com *.fullstory.com]
  end

  def usetiful_csp
    %w[usetiful.com *.usetiful.com]
  end

  def heap_csp
    {
      script: %w[https://cdn.heapanalytics.com https://heapanalytics.com],
      imgage: %w[ https://heapanalytics.com],
      style: %w[https://heapanalytics.com],
      connect: %w[https://heapanalytics.com],
      font: %w[https://heapanalytics.com],
    }
  end

  def gtm_csp
    {
      script: %w[https://www.googletagmanager.com],
      image: %w[www.googletagmanager.com],
    }
  end

  def frame_sources
    [
      'https://www.google.com', typeform_csp[:frame], youtube_csp[:frame], vimeo_csp[:frame], *slideshare_csp[:frame], *speakerdeck_csp[:frame], *google_form_csp[:frame], facebook_csp[:frame],
       *hotjar_form_csp, *usetiful_csp, 'https://calendly.com'
    ]
  end

  def image_sources
    [*gtm_csp[:image], *heap_csp[:image]]
  end

  def media_sources
    [*resource_csp[:media]]
  end

  policy.default_src :none
  policy.img_src '*', :data, :blob, *image_sources
  policy.script_src :unsafe_eval, :unsafe_inline, 'https:', 'http:', *script_sources
  policy.style_src :self, :unsafe_inline, *style_sources
  policy.connect_src :self, *connect_sources
  policy.font_src :self, *font_sources
  policy.child_src(*child_sources)
  policy.frame_src :data, *frame_sources
  policy.media_src :self, *media_sources
  policy.object_src :self
  policy.worker_src :self
  policy.manifest_src :self
end

# If you are using UJS then enable automatic nonce generation
Rails.application.config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }

# Set the nonce only to specific directives
Rails.application.config.content_security_policy_nonce_directives = %w[script-src]

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true
