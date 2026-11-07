## Пошаговый бой: интерактивный и автоматический (для тестов).

import std/sequtils

import mini_rpg/types
import mini_rpg/items
import mini_rpg/enemies
import mini_rpg/quests
import mini_rpg/ui

proc drinkPotion*(p: var Player; id: string): int =
  ## Выпивает зелье и возвращает восстановленное здоровье (0, если не вышло).
  let item = itemById(id)
  if item.kind != ikPotion or not p.removeItem(id):
    return 0
  let before = p.hp
  p.heal(item.heal)
  p.hp - before

proc usePotion*(p: var Player; id: string): bool =
  let item = itemById(id)
  let healed = p.drinkPotion(id)
  if item.kind != ikPotion:
    return false
  echo "Ты выпиваешь ", item.name, " и восстанавливаешь ", healed, " HP."
  true

proc healPotions*(p: Player): seq[string] =
  for id in p.inventory:
    if itemById(id).kind == ikPotion:
      result.add id

proc refreshAllQuests*(p: var Player) =
  let ids = p.quests.mapIt(it.id)
  for id in ids:
    p.refreshQuest(id)

proc grantRewards*(p: var Player; enemy: Enemy): tuple[levels: int, dropped, lost: seq[string]] =
  ## Начисляет награду за победу и сообщает, что попало в сумку, а что нет.
  p.registerKill(enemy.id)
  for id in enemy.drops:
    if p.addItem(id):
      result.dropped.add id
    else:
      result.lost.add id
  result.levels = p.gainExp(enemy.expReward)
  p.gold += enemy.goldReward
  p.refreshAllQuests()

proc simulateFight*(p: var Player; enemyId: string): BattleResult =
  ## Бой без ввода: игрок бьёт и пьёт зелья при низком здоровье.
  ## Используется тестами и как грубая проверка баланса.
  var e = newEnemy(enemyId)
  while true:
    if p.hp * 100 <= p.maxHp * 30:
      let potions = p.healPotions
      if potions.len > 0:
        discard p.drinkPotion(potions[0])
    e.hp -= p.playerHit(e)
    if e.hp <= 0:
      discard p.grantRewards(e.enemy)
      return brVictory
    p.hp -= e.enemyHit(p).damage
    e.turn.inc
    if p.hp <= 0:
      p.hp = 0
      return brDefeat

proc fight*(p: var Player; enemyId: string): BattleResult =
  var e = newEnemy(enemyId)
  clearScreen()
  echo line('=')
  echo "  ", e.enemy.name
  echo line('=')
  echo e.enemy.desc
  pause()

  while true:
    clearScreen()
    echo line('=')
    echo "  Бой: ", e.enemy.name
    echo line('=')
    echo e.enemy.name, ": ", e.hp, "/", e.enemy.maxHp, " HP   |   ",
      p.name, ": ", p.hp, "/", p.maxHp, " HP"

    var options = @["Атаковать"]
    let potions = p.healPotions
    if potions.len > 0:
      options.add "Выпить зелье"
    options.add "Бежать"

    let choice = readChoice("Что делаешь?", options)

    if choice == 0:
      let dmg = p.playerHit(e)
      e.hp -= dmg
      echo "Ты бьёшь и наносишь ", dmg, " урона."
    elif choice == options.len - 1:
      if e.enemy.isBoss:
        echo "Отступать некуда: барон перекрыл выход."
      else:
        echo "Ты отступаешь."
        pause()
        return brFled
    else:
      let pick = readChoice("Какое зелье? ", potions.mapIt(itemById(it).name))
      discard p.usePotion(potions[pick])

    if e.hp <= 0:
      e.hp = 0
      echo ""
      echo e.enemy.name, " повержен!"
      let reward = p.grantRewards(e.enemy)
      for id in reward.dropped:
        echo "Ты подбираешь: ", itemById(id).name
      for id in reward.lost:
        echo "Сумка полна, ", itemById(id).name, " остаётся на земле."
      echo "Получено ", e.enemy.expReward, " опыта и ", e.enemy.goldReward, " золота."
      if reward.levels > 0:
        echo "Новый уровень: ", p.level, "! Сила ", p.power, ", максимум HP ", p.maxHp, "."
      pause()
      return brVictory

    let attack = e.enemyHit(p)
    p.hp -= attack.damage
    e.turn.inc
    echo e.enemy.name, " ", attack.text, " — ", attack.damage, " урона."
    if p.hp <= 0:
      p.hp = 0
      echo ""
      echo "Ты падаешь без сил..."
      pause()
      return brDefeat
