## Точка входа: приветствие и сюжетный цикл.

import std/random

import mini_rpg/types
import mini_rpg/scenes
import mini_rpg/ui

proc main() =
  randomize()
  clearScreen()
  echo line('=')
  echo "  MINI RPG"
  echo line('=')
  echo ""
  echo "Ты не помнишь, как здесь оказался."
  echo "Помнишь только холод камня и чей-то смех в темноте."
  echo ""
  let name = readName("Как тебя зовут? ")
  var game = Game(player: newPlayer(name))
  echo ""
  echo "Что ж, ", name, ". Начнём."

  game.caveScene()
  game.roadScene()
  while true:
    game.cityScene()
    game.castleScene()

when isMainModule:
  main()
