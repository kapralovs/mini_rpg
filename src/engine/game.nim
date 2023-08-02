proc run*()=
  #Here must be the title (like "miniRPG")
  echo "-----------------------------"
  echo "| Hello, stranger!          |"
  echo "| Welcome to mini RPG game! |"
  echo "-----------------------------"
  echo "What is your name?"

  let name = readLine(stdin)

  echo "Nice to meet you, ",name,"!"

