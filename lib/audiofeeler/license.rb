module Audiofeeler
  class License
    attr_reader :symbol, :name

    def initialize(symbol, name)
      @symbol = symbol
      @name = name
    end

    def self.find(symbol)
      all.find { |l| l.symbol == symbol }
    end

    CC_BY_40 = License.new(
      'CC BY 4.0',
      'Creative Commons Attribution 4.0 International'
    ).freeze
    CC_BY_SA_40 = License.new(
      'CC BY-SA 4.0',
      'Creative Commons Attribution-ShareAlike 4.0 International'
    ).freeze
    CC_BY_NC_40 = License.new(
      'CC BY-NC 4.0',
      'Creative Commons Attribution-NonCommercial 4.0 International'
    ).freeze
    CC_BY_NC_SA_40 = License.new(
      'CC BY-NC-SA 4.0',
      'Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International'
    ).freeze
    CC_BY_ND_40 = License.new(
      'CC BY-ND 4.0',
      'Creative Commons Attribution-NoDerivatives 4.0 International'
    ).freeze
    CC_BY_NC_ND_40 = License.new(
      'CC BY-NC-ND 4.0',
      'Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International'
    ).freeze

    def self.all
      [
        CC_BY_40,
        CC_BY_SA_40,
        CC_BY_NC_40,
        CC_BY_NC_SA_40,
        CC_BY_ND_40,
        CC_BY_NC_ND_40,
      ]
    end

    def url
      "https://creativecommons.org/licenses/#{shortcut}/#{version}/"
    end

    def icon_url
      "https://i.creativecommons.org/l/#{shortcut}/#{version}/88x31.png"
    end

    def small_icon_url
      "https://i.creativecommons.org/l/#{shortcut}/#{version}/80x15.png"
    end

    def text
      "This work is licensed under the #{name} License."
    end

    private

    def shortcut
      @shortcut ||= symbol.split(' ')[1...-1].join('-')
    end

    def version
      @version ||= symbol.split(' ').last
    end
  end
end
