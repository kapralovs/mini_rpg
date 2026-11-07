## Отображение состояния игрока, инвентаря и журнала квестов.

import std/strutils

import mini_rpg/types
import mini_rpg/items
import mini_rpg/quests
import mini_rpg/ui

proc expBar*(p: Player): string =
  let need = p.expToNext
  let filled = int(10.0 * float(p.exp) / float(need))
  "[" & repeat('#', filled) & repeat('.', 10 - filled) & "] " &
    $p.exp & "/" & $need

proc showStatus*(p: Player) =
  let weapon = if p.weapon.len > 0: itemById(p.weapon).name else: "кулаки"
  echo line()
  echo p.name, " — уровень ", p.level, ", HP ", p.hp, "/", p.maxHp,
    ", сила ", p.attackPower, " (", weapon, "), золото ", p.gold
  echo "Опыт: ", expBar(p)

proc showInventory*(p: Player) =
  echo line()
  echo "Инвентарь (", p.inventory.len, "/", InventoryLimit, "):"
  if p.inventory.len == 0:
    echo "  пусто"
  for i, id in p.inventory:
    let item = itemById(id)
    var extra = ""
    case item.kind
    of ikWeapon: extra = " (+" & $item.power & " к силе)"
    of ikPotion: extra = " (лечит " & $item.heal & ")"
    of ikQuest: extra = " (трофей)"
    echo "  ", i + 1, ") ", item.name, extra
  echo "Оружие в руках: ",
    (if p.weapon.len > 0: itemById(p.weapon).name else: "нет")

proc showQuestLog*(p: Player) =
  echo line()
  echo "Журнал квестов:"
  let active = p.activeQuests
  if active.len == 0:
    echo "  активных квестов нет"
  for state in active:
    let quest = questById(state.id)
    echo "  * ", quest.title, " — ", state.progress, "/", quest.amount,
      " (", questStatusText(state), ")"
  for state in p.quests:
    if state.status == qsDone:
      echo "  - ", questById(state.id).title, " — выполнено"
