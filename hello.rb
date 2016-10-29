require_relative "fastpokemap"

def display_pokemon_names pokemons
  puts '---'
  pokemons.each {|a| puts POKEMON_NAMES[a.to_i - 1].capitalize}
  puts '---'
end

fastpokemap = FastPokeMap.new

# searching by any pokemons, except for a set of pokemons
pokemons = fastpokemap.get_pokemons lat='-23.501667', long='-47.458056', mode=:ignore, pokemons=IGNORED_POKEMONS
display_pokemon_names pokemons

pokemons = fastpokemap.get_pokemons lat='-23.501667', long='-47.458056', mode=:only, pokemons=['dragonite']
display_pokemon_names pokemons
