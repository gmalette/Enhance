module ActionView::Helpers::UrlHelper
  def enhance url, geometry
    matches = url.match /(?<url>[^?]*)\??(?<get>.*)?/
    [[matches['url'], geometry].compact.join("/"), matches['get']].compact.reject(&:empty?).join("?")
  end
  alias_method :enhance!, :enhance
end