## Ввод-вывод для терминала: меню, подтверждения, безопасный ввод.

import std/os
import std/strutils

proc clearScreen*() =
  discard execShellCmd("clear")

proc line*(ch: char = '-'; width: int = 52): string =
  repeat(ch, width)

proc header*(title: string) =
  echo ""
  echo line('=')
  echo "  " & title
  echo line('=')

proc readLineOrQuit*(): string =
  ## Читает строку; на конце потока ввода (Ctrl-D, пайп) просто выходит.
  ## Перед чтением сбрасывает буфер вывода, иначе при перенаправлении
  ## в пайп приглашение остаётся в буфере и игра выглядит зависшей.
  stdout.flushFile()
  try:
    result = stdin.readLine()
  except EOFError:
    quit(0)

proc pause*() =
  echo ""
  echo "Нажми Enter, чтобы продолжить..."
  discard readLineOrQuit()

proc readInt*(prompt: string; lo, hi: int): int =
  ## Читает число в диапазоне [lo, hi], переспрашивая при ошибке.
  while true:
    stdout.write(prompt)
    stdout.flushFile()
    let raw = readLineOrQuit().strip
    if raw.len == 0:
      continue
    try:
      let value = parseInt(raw)
      if value >= lo and value <= hi:
        return value
      echo "Нужно число от ", lo, " до ", hi, "."
    except ValueError:
      echo "Это не число. Попробуй ещё раз."

proc readChoice*(prompt: string; options: openArray[string]): int =
  ## Показывает нумерованный список и возвращает индекс выбранного пункта.
  echo ""
  for i, option in options:
    echo "  ", i + 1, ") ", option
  echo ""
  readInt(prompt & " (1-" & $options.len & "): ", 1, options.len) - 1

proc readName*(prompt: string): string =
  while true:
    stdout.write(prompt)
    stdout.flushFile()
    let raw = readLineOrQuit().strip
    if raw.len > 0:
      return raw
    echo "Имя не может быть пустым."
