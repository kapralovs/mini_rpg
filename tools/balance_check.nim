## Грубая проверка баланса: прогоняем «идеального» игрока по сюжету
## без интерактивного ввода и смотрим, хватает ли сил на босса.
## Запуск: nim c -r --path:src tools/balance_check.nim

import mini_rpg/types
import mini_rpg/items
import mini_rpg/quests
import mini_rpg/shops
import mini_rpg/battle

proc report(p: Player; label: string) =
  echo label, ": уровень ", p.level, ", HP ", p.hp, "/", p.maxHp,
    ", сила ", p.attackPower, ", золото ", p.gold

var p = newPlayer("Баланс")
p.wieldWeapon("stick")
report(p, "старт")

discard p.simulateFight("cave_rat")
discard p.simulateFight("goblin")
discard p.simulateFight("bandit")
report(p, "до города")

discard p.acceptQuest("rats")
while p.questState("rats").progress < RatsInBasement:
  if p.hp < p.maxHp div 2:
    p.hp = p.maxHp
  discard p.simulateFight("cave_rat")
discard p.turnInQuest("rats")
report(p, "после квеста на крыс")

discard p.acceptQuest("goblin_steel")
while p.questState("goblin_steel").progress < 2:
  if p.hp < p.maxHp div 2:
    p.hp = p.maxHp
  discard p.simulateFight("goblin")
discard p.turnInQuest("goblin_steel")
report(p, "после квеста на сталь")

discard p.buyItem("sword")
discard p.equipWeapon("sword")
for _ in 0 ..< 3:
  discard p.buyItem("small_potion")
p.hp = p.maxHp
report(p, "перед замком")

discard p.simulateFight("skeleton")
report(p, "после скелета")
p.hp = p.maxHp

let outcome = p.simulateFight("boss")
report(p, "после босса")
echo "Итог: ", outcome
