## Сюжетные сцены: пещера, дорога, город, подвал, лес, замок.

import mini_rpg/types
import mini_rpg/items
import mini_rpg/enemies
import mini_rpg/render
import mini_rpg/battle
import mini_rpg/shops
import mini_rpg/ui

proc storyHeader(title: string) =
  clearScreen()
  echo line('=')
  echo "  ", title
  echo line('=')

proc inventoryMenu*(p: var Player) =
  ## Инвентарь вне боя: экипировка оружия и лечение зельями.
  while true:
    clearScreen()
    echo line('=')
    echo "  Сумка"
    echo line('=')
    p.showStatus()
    p.showInventory()
    if p.inventory.len == 0:
      pause()
      return
    var options: seq[string] = @[]
    for id in p.inventory:
      options.add itemById(id).name
    options.add "Закрыть сумку"
    let choice = readChoice("Что взять?", options)
    if choice == options.len - 1:
      return
    let id = p.inventory[choice]
    let item = itemById(id)
    case item.kind
    of ikWeapon:
      if p.equipWeapon(id):
        echo "В руках теперь ", item.name, "."
    of ikPotion:
      if p.hp >= p.maxHp:
        echo "Здоровье и так полное — зелье жалко тратить."
      else:
        discard p.usePotion(id)
    of ikQuest:
      echo "Это трофей для квеста, в дело он не годится."
    pause()

proc gameOver*(p: Player) =
  storyHeader("Поражение")
  echo "Тьма смыкается. ", p.name, " не дожил до рассвета."
  echo "Уровень: ", p.level, ", золото: ", p.gold, "."
  echo ""
  echo "Игра окончена."
  quit(0)

proc victory*(p: Player) =
  storyHeader("Победа")
  echo "Барон Кровавый Клык падает на каменный пол."
  echo "Замок затихает, и над долиной впервые за годы встаёт спокойное утро."
  echo ""
  echo p.name, ", уровень ", p.level, ", золото ", p.gold, "."
  echo "Ты прошёл игру."
  quit(0)

proc caveScene*(g: var Game) =
  storyHeader("Пещера")
  echo "Холод. Камень под спиной. Ты открываешь глаза в темноте."
  echo "Голова гудит, во рту сухо, а где-то капает вода."
  echo ""
  echo "Рядом лежит кривая палка — единственное, что похоже на оружие."
  pause()

  if not g.hasFlag("hasStick"):
    if readChoice("Подобрать палку?", @["Взять палку", "Оставить"]) == 0:
      g.setFlag("hasStick")
      g.player.wieldWeapon("stick")
      echo "Ты сжимаешь палку. Уже не так страшно."
      pause()

  while true:
    storyHeader("Пещера")
    g.player.showStatus()
    echo ""
    echo "Из глубины пещеры слышно шорох. Впереди — свет выхода."
    let choice = readChoice("Что делаешь?", @[
      "Идти к выходу",
      "Проверить шорох",
      "Осмотреться",
      "Открыть сумку (экипировка, зелья)",
    ])
    case choice
    of 0:
      if not g.hasFlag("hasStick"):
        echo "Ты выходишь к свету с пустыми руками. Смело."
      g.setFlag("leftCave")
      echo "Ты выбираешься наружу. В лицо бьёт свежий ветер."
      pause()
      return
    of 1:
      if g.hasFlag("ratSlain"):
        echo "Здесь тихо. Только капли и твой шаг."
      else:
        echo "Из щели вылезает крыса и бросается на тебя."
        case g.player.fight("cave_rat")
        of brVictory:
          g.setFlag("ratSlain")
          echo "Шорох стихает."
        of brDefeat:
          gameOver(g.player)
        of brFled:
          echo "Ты отступаешь к стене."
      pause()
    of 2:
      if not g.hasFlag("caveLoot"):
        g.setFlag("caveLoot")
        echo "Под камнем — чья-то сумка. В ней уцелело малое зелье лечения."
        if g.player.addItem("small_potion"):
          echo "Ты забираешь его с собой."
        else:
          echo "Но сумка полна."
      else:
        echo "Стены в подтёках, старые кости в углу, у выхода — следы сапог."
        echo "Кто-то был здесь до тебя. И ушёл."
      pause()
    else:
      g.player.showInventory()
      pause()

proc roadScene*(g: var Game) =
  storyHeader("Дорога к городу")
  echo "Пыльная дорога вьётся между холмами. Впереди видны стены Эльдхейма."
  echo "Но до ворот ещё идти и идти."
  pause()

  const RoadEnemies = ["goblin", "bandit"]
  var step = 0
  while step < RoadEnemies.len:
    storyHeader("Дорога к городу")
    g.player.showStatus()
    echo ""
    let enemy = enemyById(RoadEnemies[step])
    echo "На дороге ", enemy.name, ". ", enemy.desc
    let choice = readChoice("Что делаешь?", @["Вступить в бой", "Попробовать обойти"])
    if choice == 1:
      echo "Ты пытаешься обойти, но ", enemy.name, " замечает тебя."
    case g.player.fight(RoadEnemies[step])
    of brVictory:
      step.inc
    of brDefeat:
      gameOver(g.player)
    of brFled:
      echo "Бежать некуда — дорога узкая. Придётся драться."
      case g.player.fight(RoadEnemies[step])
      of brVictory: step.inc
      of brDefeat: gameOver(g.player)
      of brFled: discard
    pause()

  storyHeader("Дорога к городу")
  echo "Дорога пуста. Впереди — городские ворота."
  pause()

proc basementScene*(g: var Game) =
  while true:
    storyHeader("Подвал трактира")
    g.player.showStatus()
    echo ""
    echo "Сырой подвал, бочки и шорох в углах. Крысы здесь чувствуют себя хозяевами."
    let choice = readChoice("Что делаешь?", @["Искать крыс", "Подняться наверх"])
    if choice == 1:
      return
    echo "Из-за бочки выскакивает крыса."
    case g.player.fight("cave_rat")
    of brVictory:
      if g.player.killCount("cave_rat") >= RatsInBasement:
        echo "Больше в подвале никто не шуршит."
    of brDefeat:
      gameOver(g.player)
    of brFled:
      echo "Ты отступаешь к лестнице."
    pause()

proc forestScene*(g: var Game) =
  while true:
    storyHeader("Лес у города")
    g.player.showStatus()
    echo ""
    echo "Кривые сосны, хруст веток. Где-то здесь гоблины устроили засаду."
    let choice = readChoice("Что делаешь?", @["Идти вглубь", "Вернуться в город"])
    if choice == 1:
      return
    echo "Из-за дерева выскакивает гоблин."
    case g.player.fight("goblin")
    of brVictory: discard
    of brDefeat: gameOver(g.player)
    of brFled: echo "Ты выбираешься к опушке."
    pause()

proc cityScene*(g: var Game) =
  while true:
    storyHeader("Город Эльдхейм")
    g.player.showStatus()
    echo ""
    echo "Улица пахнет хлебом и дымом. Слева кузница, справа лавка алхимика."
    echo "Дальше — трактир, доска объявлений, а за воротами — лес и замок."
    let choice = readChoice("Куда идёшь?", @[
      "К кузнецу",
      "К алхимику",
      "В трактир (отдохнуть)",
      "Спуститься в подвал трактира",
      "К доске объявлений",
      "В лес (гоблины)",
      "Открыть сумку (экипировка, зелья)",
      "Журнал квестов",
      "Выйти к замку",
    ])
    case choice
    of 0: g.player.showBlacksmith()
    of 1: g.player.showAlchemist()
    of 2: g.player.showInn()
    of 3: g.basementScene()
    of 4: g.player.showQuestBoard()
    of 5: g.forestScene()
    of 6: g.player.inventoryMenu()
    of 7:
      g.player.showQuestLog()
      pause()
    of 8:
      if readChoice("Дорога к замку опасна. Готов?", @["Идти", "Остаться"]) == 0:
        return
    else:
      discard

proc castleScene*(g: var Game) =
  storyHeader("Замок Кровавого Клыка")
  echo "Чёрные стены, мёртвая тишина, факелы горят зелёным."
  echo "В тронном зале тебя ждут."
  pause()

  if not g.hasFlag("skeletonSlain"):
    storyHeader("Караульный зал")
    echo "Из темноты поднимается скелет в ржавой кольчуге."
    echo "Он не дышит. Ему нечего терять."
    pause()
    case g.player.fight("skeleton")
    of brVictory:
      g.setFlag("skeletonSlain")
    of brDefeat:
      gameOver(g.player)
    of brFled:
      echo "Ты отступаешь из замка."
      return

  while true:
    storyHeader("Тронный зал")
    g.player.showStatus()
    echo ""
    echo "Барон Кровавый Клык поднимается с трона. Доспехи скрежещут."
    echo "«Ещё один герой. Как скучно.»"
    let choice = readChoice("Что делаешь?", @["Атаковать барона", "Отступить в город"])
    if choice == 1:
      echo "Ты отступаешь. Барон смеётся тебе в спину."
      pause()
      return
    case g.player.fight("boss")
    of brVictory: victory(g.player)
    of brDefeat: gameOver(g.player)
    of brFled: gameOver(g.player)
