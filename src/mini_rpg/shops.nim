## Городские магазины, трактир и доска квестов.

import mini_rpg/types
import mini_rpg/items
import mini_rpg/quests
import mini_rpg/render
import mini_rpg/ui

const
  BlacksmithStock* = ["club", "sword"]
  AlchemistStock* = ["small_potion", "big_potion"]
  SellPriceRatio* = 2  ## Продажа идёт за половину цены.

proc sellPrice*(item: Item): int =
  item.price div SellPriceRatio

proc buyItem*(p: var Player; id: string): bool =
  ## Покупка с проверкой золота и места в сумке.
  let item = itemById(id)
  if p.gold < item.price or p.inventory.len >= InventoryLimit:
    return false
  p.gold -= item.price
  discard p.addItem(id)
  true

proc sellableItems*(p: Player): seq[string] =
  ## Трофеи не продаются: они нужны для сдачи квестов.
  for id in p.inventory:
    if itemById(id).kind != ikQuest:
      result.add id

proc showShop*(p: var Player; title: string; stock: openArray[string]) =
  while true:
    clearScreen()
    echo line('=')
    echo "  ", title
    echo line('=')
    p.showStatus()
    echo ""
    for i, id in stock:
      let item = itemById(id)
      echo "  ", i + 1, ") ", item.name, " — ", item.price, " золота"
      echo "     ", item.desc
    echo "  ", stock.len + 1, ") Уйти"
    echo ""
    let choice = readInt("Твой выбор: ", 1, stock.len + 1)
    if choice == stock.len + 1:
      return
    let item = itemById(stock[choice - 1])
    if p.gold < item.price:
      echo "Не хватает золота: нужно ", item.price, ", у тебя ", p.gold, "."
    elif p.inventory.len >= InventoryLimit:
      echo "Сумка полна."
    else:
      discard p.buyItem(item.id)
      echo "Куплено: ", item.name, ". Осталось золота: ", p.gold, "."
    pause()

proc showSellMenu*(p: var Player) =
  while true:
    clearScreen()
    let stock = p.sellableItems
    if stock.len == 0:
      echo "Продавать нечего."
      pause()
      return
    echo line('=')
    echo "  Продажа"
    echo line('=')
    for i, id in stock:
      let item = itemById(id)
      echo "  ", i + 1, ") ", item.name, " — ", sellPrice(item), " золота"
    echo "  ", stock.len + 1, ") Назад"
    echo ""
    let choice = readInt("Что продать? ", 1, stock.len + 1)
    if choice == stock.len + 1:
      return
    let item = itemById(stock[choice - 1])
    discard p.removeItem(item.id)
    p.gold += sellPrice(item)
    echo "Продано: ", item.name, " за ", sellPrice(item), " золота."
    pause()

proc showBlacksmith*(p: var Player) =
  while true:
    clearScreen()
    echo line('=')
    echo "  Кузнец Гарм"
    echo line('=')
    echo "«Сталь — она всё помнит. Что тебе нужно?»"
    p.showStatus()
    let choice = readChoice("Кузнец:", @["Купить оружие", "Продать предметы", "Уйти"])
    case choice
    of 0: p.showShop("Товары кузнеца", BlacksmithStock)
    of 1: p.showSellMenu()
    else: return

proc showAlchemist*(p: var Player) =
  while true:
    clearScreen()
    echo line('=')
    echo "  Алхимик Мирта"
    echo line('=')
    echo "«Зелья варю сама. Не спрашивай из чего.»"
    p.showStatus()
    let choice = readChoice("Алхимик:", @["Купить зелья", "Продать предметы", "Уйти"])
    case choice
    of 0: p.showShop("Товары алхимика", AlchemistStock)
    of 1: p.showSellMenu()
    else: return

proc showInn*(p: var Player) =
  clearScreen()
  echo line('=')
  echo "  Трактир «Три кружки»"
  echo line('=')
  echo "Хозяин вытирает кружку: «Комната — ", InnPrice, " золота. Постель чистая. Почти.»"
  if p.gold < InnPrice:
    echo "У тебя только ", p.gold, " золота. Хозяин разводит руками."
    pause()
    return
  let choice = readChoice("Снять комнату?", @["Да, отдохнуть", "Нет, выйти"])
  if choice == 0:
    p.gold -= InnPrice
    p.hp = p.maxHp
    echo "Ты спишь без снов. Здоровье восстановлено полностью."
  pause()

proc showQuestBoard*(p: var Player) =
  while true:
    clearScreen()
    echo line('=')
    echo "  Доска объявлений"
    echo line('=')
    var options: seq[string] = @[]
    for quest in Quests:
      let state = p.questState(quest.id)
      var label = quest.title & " — " & questStatusText(state)
      if state.status in {qsActive, qsReady}:
        label &= " (" & $state.progress & "/" & $quest.amount & ")"
      options.add label
    options.add "Уйти"
    let choice = readChoice("Объявления:", options)
    if choice == options.len - 1:
      return
    let quest = Quests[choice]
    let state = p.questState(quest.id)
    clearScreen()
    echo line('=')
    echo "  ", quest.title
    echo line('=')
    echo quest.desc
    echo "Награда: ", quest.rewardGold, " золота, ", quest.rewardExp, " опыта."
    case state.status
    of qsInactive:
      if readChoice("Взяться за дело?", @["Да", "Нет"]) == 0:
        discard p.acceptQuest(quest.id)
        echo "Квест принят."
    of qsActive:
      echo "Прогресс: ", state.progress, "/", quest.amount
    of qsReady:
      if readChoice("Сдать квест?", @["Да", "Нет"]) == 0:
        if p.turnInQuest(quest.id):
          echo "Квест сдан. Награда получена."
    of qsDone:
      echo "Уже выполнено."
    pause()
