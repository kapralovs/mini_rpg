# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

# when isMainModule:
#   echo("Hello, World!")

import std/os

echo "Welcome to Mini RPG"

type
  Person=object
    Name: string
    Health: int
    Experience: int
    Power: int

var p=Person(
  Health:100,
  Experience:0,
  Power: 1,
)

echo "Введите имя персонажа:"
p.Name=readLine(stdin)

discard execShellCmd("clear") # execute "clear" shell command

echo("Добро пожаловать в мир иной, ", p.Name)
