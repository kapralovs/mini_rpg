import std/unittest

import mini_rpg/types
import mini_rpg/items
import mini_rpg/enemies
import mini_rpg/quests
import mini_rpg/shops
import mini_rpg/battle

suite "персонаж":
  test "новый персонаж начинает с базовыми характеристиками":
    let p = newPlayer("Тест")
    check p.hp == StartHp
    check p.maxHp == StartHp
    check p.level == 1
    check p.exp == 0
    check p.attackPower == StartPower

  test "опыт повышает уровень и характеристики":
    var p = newPlayer("Тест")
    let levels = p.gainExp(ExpBase)
    check levels == 1
    check p.level == 2
    check p.exp == 0
    check p.maxHp == StartHp + LevelHpGain
    check p.power == StartPower + LevelPowerGain

  test "несколько уровней за один раз и перенос остатка опыта":
    var p = newPlayer("Тест")
    let need = p.expToNext + (ExpBase + ExpStep)
    let levels = p.gainExp(need)
    check levels == 2
    check p.level == 3
    check p.exp == 0

  test "лечение не превышает максимум":
    var p = newPlayer("Тест")
    p.hp = 10
    p.heal(1000)
    check p.hp == p.maxHp

suite "инвентарь и оружие":
  test "экипировка оружия меняет силу удара":
    var p = newPlayer("Тест")
    discard p.addItem("club")
    check p.equipWeapon("club")
    check p.weapon == "club"
    check p.attackPower == StartPower + itemById("club").power

  test "старое оружие возвращается в сумку":
    var p = newPlayer("Тест")
    p.wieldWeapon("stick")
    discard p.addItem("club")
    check p.equipWeapon("club")
    check p.countItem("stick") == 1
    check p.weapon == "club"

  test "нельзя взять оружие, которого нет в сумке":
    var p = newPlayer("Тест")
    check not p.equipWeapon("sword")

  test "инвентарь ограничен":
    var p = newPlayer("Тест")
    for _ in 0 ..< InventoryLimit:
      check p.addItem("small_potion")
    check not p.addItem("small_potion")

  test "зелье лечит и исчезает из сумки":
    var p = newPlayer("Тест")
    discard p.addItem("small_potion")
    p.hp = 5
    check p.usePotion("small_potion")
    check p.hp == 5 + itemById("small_potion").heal
    check p.countItem("small_potion") == 0

suite "бой":
  test "урон не может быть меньше единицы":
    check damageAgainst(1, 100) == 1
    check damageAgainst(10, 3) == 7

  test "атака игрока учитывает оружие и защиту врага":
    var p = newPlayer("Тест")
    p.wieldWeapon("sword")
    let e = newEnemy("bandit")
    check p.playerHit(e) == StartPower + itemById("sword").power - e.enemy.defense

  test "враг бьёт по своему набору атак":
    var p = newPlayer("Тест")
    var e = newEnemy("bandit")
    let first = e.enemyHit(p)
    check first.text == e.enemy.moves[0].text
    e.turn.inc
    let second = e.enemyHit(p)
    check second.text == e.enemy.moves[1].text

  test "победа начисляет опыт, золото и трофеи":
    var p = newPlayer("Тест")
    p.power = 100
    check p.simulateFight("goblin") == brVictory
    check p.killCount("goblin") == 1
    check p.gold == StartGold + enemyById("goblin").goldReward
    check p.countItem("goblin_steel") == 1

suite "магазин":
  test "покупка списывает золото и кладёт предмет в сумку":
    var p = newPlayer("Тест")
    p.gold = 100
    check p.buyItem("sword")
    check p.gold == 100 - itemById("sword").price
    check p.countItem("sword") == 1

  test "покупка без денег невозможна":
    var p = newPlayer("Тест")
    p.gold = 0
    check not p.buyItem("sword")

  test "продажа возвращает половину цены":
    var p = newPlayer("Тест")
    discard p.addItem("club")
    let price = sellPrice(itemById("club"))
    check price == itemById("club").price div 2

suite "квесты":
  test "квест на убийства считается по счётчику":
    var p = newPlayer("Тест")
    p.power = 100
    check p.acceptQuest("rats")
    check p.questState("rats").status == qsActive
    for _ in 0 ..< RatsInBasement:
      discard p.simulateFight("cave_rat")
    check p.questState("rats").progress == RatsInBasement
    check p.canTurnIn("rats")

  test "сдача квеста выдаёт награду и закрывает его":
    var p = newPlayer("Тест")
    p.power = 100
    discard p.acceptQuest("rats")
    for _ in 0 ..< RatsInBasement:
      discard p.simulateFight("cave_rat")
    let goldBefore = p.gold
    check p.turnInQuest("rats")
    check p.gold == goldBefore + questById("rats").rewardGold
    check p.questState("rats").status == qsDone

  test "квест на предмет требует трофеи и забирает их":
    var p = newPlayer("Тест")
    check p.acceptQuest("goblin_steel")
    check not p.canTurnIn("goblin_steel")
    for _ in 0 ..< questById("goblin_steel").amount:
      discard p.addItem("goblin_steel")
    p.refreshQuest("goblin_steel")
    check p.canTurnIn("goblin_steel")
    check p.turnInQuest("goblin_steel")
    check p.countItem("goblin_steel") == 0

  test "нельзя взять один квест дважды":
    var p = newPlayer("Тест")
    check p.acceptQuest("rats")
    check not p.acceptQuest("rats")

  test "нельзя сдать невыполненный квест":
    var p = newPlayer("Тест")
    discard p.acceptQuest("rats")
    check not p.turnInQuest("rats")

suite "баланс":
  test "подготовленный игрок побеждает босса":
    var p = newPlayer("Тест")
    p.power = 100
    check p.simulateFight("boss") == brVictory

  test "неподготовленный игрок не проходит замок":
    var p = newPlayer("Тест")
    check p.simulateFight("boss") == brDefeat
