require 'watir'
require 'watir-webdriver'
require 'set'
require 'active_support/inflector'

POKEMON_NAMES = ["bulbasaur", "ivysaur", "venusaur", "charmander", "charmeleon", "charizard", "squirtle", "wartortle", "blastoise", "caterpie", "metapod", "butterfree", "weedle", "kakuna", "beedrill", "pidgey", "pidgeotto", "pidgeot", "rattata", "raticate", "spearow", "fearow", "ekans", "arbok", "pikachu", "raichu", "sandshrew", "sandslash", "nidoran-f", "nidorina", "nidoqueen", "nidoran-m", "nidorino", "nidoking", "clefairy", "clefable", "vulpix", "ninetales", "jigglypuff", "wigglytuff", "zubat", "golbat", "oddish", "gloom", "vileplume", "paras", "parasect", "venonat", "venomoth", "diglett", "dugtrio", "meowth", "persian", "psyduck", "golduck", "mankey", "primeape", "growlithe", "arcanine", "poliwag", "poliwhirl", "poliwrath", "abra", "kadabra", "alakazam", "machop", "machoke", "machamp", "bellsprout", "weepinbell", "victreebel", "tentacool", "tentacruel", "geodude", "graveler", "golem", "ponyta", "rapidash", "slowpoke", "slowbro", "magnemite", "magneton", "farfetchd", "doduo", "dodrio", "seel", "dewgong", "grimer", "muk", "shellder", "cloyster", "gastly", "haunter", "gengar", "onix", "drowzee", "hypno", "krabby", "kingler", "voltorb", "electrode", "exeggcute", "exeggutor", "cubone", "marowak", "hitmonlee", "hitmonchan", "lickitung", "koffing", "weezing", "rhyhorn", "rhydon", "chansey", "tangela", "kangaskhan", "horsea", "seadra", "goldeen", "seaking", "staryu", "starmie", "mr-mime", "scyther", "jynx", "electabuzz", "magmar", "pinsir", "tauros", "magikarp", "gyarados", "lapras", "ditto", "eevee", "vaporeon", "jolteon", "flareon", "porygon", "omanyte", "omastar", "kabuto", "kabutops", "aerodactyl", "snorlax", "articuno", "zapdos", "moltres", "dratini", "dragonair", "dragonite", "mewtwo"]
IGNORED_POKEMONS = ['Zubat', 'Golbat', 'Nidoran M', 'Nidoran F', 'Pidgey', 'Spearow', 'Ekans', 'Eevee', 'Rattata', 'Caterpie', 'Weedle']

class FastPokeMap
  def initialize
      @profile = Selenium::WebDriver::Chrome::Profile.new
      @profile["geolocation.enabled"] = false
  end

  def get_pokemons lat='-23.501667', long='-47.458056', mode=:ignore, pokemons=IGNORED_POKEMONS
      @browser = Watir::Browser.new(:chrome, :profile => @profile)

      @browser.goto "https://fastpokemap.se/##{lat},#{long}"
      @browser.button(:class => 'close').when_present.click
      @browser.img(src: 'https://fastpokemap.se/images/marker-icon.png').wait_until_present

      filter_pokemons mode, pokemons

      begin
        Watir::Wait.until {@browser.divs(class: 'displaypokemon').length > 0}
        finded_pokemons = parse_pokemons @browser.divs(class: 'displaypokemon')
      rescue Exception => e
        puts 'No pokemons on this region'
        finded_pokemons = Set.new
      end

      @browser.close
      message = finded_pokemons.length == 1 ? "I find #{finded_pokemons.length} pokemon" : "I find #{finded_pokemons.length} #{'pokemons'.pluralize}"
      puts message
      finded_pokemons
  end

private
  def filter_pokemons rule=:ignore, pokemons=IGNORED_POKEMONS
    @browser.button(id: 'openfilter').when_present.click

    case rule
    when :ignore
      @browser.button(id: 'deselect-all').when_present.click
    when :only
      @browser.button(id: 'select-all').when_present.click
    else
      raise 'The rule should be :ignore or :only'
    end

    pokemons.each {|pokemon| @browser.label(text: pokemon.split.map(&:capitalize)*' ').when_present.click }
    @browser.button(id: 'applyfilter').when_present.click
    @browser.button(class: 'scan').when_present.click
  end

  def parse_pokemons pokemons
    finded_pokemons = Set.new
    pokemons = pokemons.reject { |div| 
      div.class_name.split.include?('hidden')
    }
    pokemons.each do |pokemon|
      finded_pokemons.add /data-pokeid="\d+"/.match(pokemon.html)[0].scan(/\d+/).first
    end
    finded_pokemons
  end
end
