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

var p=Person(Name: "Hero")

discard execShellCmd("clear") # execute "clear" shell command

echo p.Name
