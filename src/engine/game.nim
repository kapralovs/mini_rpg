import strutils

proc showTitle()=
  #Here must be the title (like "miniRPG")
  echo "-----------------------------"
  echo "| Hello, stranger!          |"
  echo "| Welcome to mini RPG game! |"
  echo "-----------------------------"
  echo ""

proc newGame*()=
  echo "What is your name?"
  let name = readLine(stdin)
  echo "Nice to meet you, ",name,"!"

proc gotGames(): bool=
  let content=readFile("save_state.txt")
  let states=content.splitLines()

  return states.len()>0

proc run*()=
  showTitle()

  if gotGames():
    echo "got saved games"
  else:
    newGame()

