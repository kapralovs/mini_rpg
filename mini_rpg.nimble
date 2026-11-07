# Package

version       = "0.1.0"
author        = "kapralovs"
description   = "Text MINI RPG game"
license       = "MIT"
srcDir        = "src"
bin           = @["mini_rpg"]


# Dependencies

requires "nim >= 1.6.6"

task test, "Запускает тесты игры":
  exec "nim c -r --hints:off --path:src tests/test_game.nim"
