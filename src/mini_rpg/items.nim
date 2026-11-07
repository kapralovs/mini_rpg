## Каталог предметов и операции с инвентарём.


import mini_rpg/types

const Items* = [
  Item(
    id: "stick", name: "Кривая палка", kind: ikWeapon, price: 5, power: 2,
    desc: "Обломок сухой ветки. Лучше, чем голые кулаки."
  ),
  Item(
    id: "club", name: "Дубовая дубина", kind: ikWeapon, price: 15, power: 4,
    desc: "Тяжёлая, зато бьёт по-настоящему."
  ),
  Item(
    id: "sword", name: "Железный меч", kind: ikWeapon, price: 45, power: 7,
    desc: "Работа городского кузнеца. Острая и увесистая."
  ),
  Item(
    id: "small_potion", name: "Малое зелье лечения", kind: ikPotion, price: 10, heal: 15,
    desc: "Восстанавливает 15 здоровья."
  ),
  Item(
    id: "big_potion", name: "Большое зелье лечения", kind: ikPotion, price: 20, heal: 35,
    desc: "Восстанавливает 35 здоровья."
  ),
  Item(
    id: "goblin_steel", name: "Обломок гоблинской стали", kind: ikQuest, price: 0,
    desc: "Кусок грубо кованого металла. Кузнец обещал за такие заплатить."
  ),
]

proc itemById*(id: string): Item =
  for item in Items:
    if item.id == id:
      return item
  Item(id: "", name: "неизвестный предмет")

proc attackPower*(p: Player): int =
  ## Итоговая сила удара: собственная сила плюс бонус оружия.
  p.power + itemById(p.weapon).power

proc countItem*(p: Player; id: string): int =
  for itemId in p.inventory:
    if itemId == id:
      result.inc

proc addItem*(p: var Player; id: string): bool =
  if p.inventory.len >= InventoryLimit:
    return false
  p.inventory.add id
  true

proc removeItem*(p: var Player; id: string): bool =
  let idx = p.inventory.find(id)
  if idx < 0:
    return false
  p.inventory.delete(idx)
  true

proc equipWeapon*(p: var Player; id: string): bool =
  ## Берёт оружие из сумки. Старое оружие возвращается в сумку.
  let item = itemById(id)
  if item.kind != ikWeapon:
    return false
  let idx = p.inventory.find(id)
  if idx < 0:
    return false
  p.inventory.delete(idx)
  if p.weapon.len > 0:
    p.inventory.add p.weapon
  p.weapon = id
  true

proc wieldWeapon*(p: var Player; id: string) =
  ## Сразу берёт оружие в руки, не заглядывая в сумку: для находок в мире.
  let item = itemById(id)
  if item.kind != ikWeapon:
    return
  if p.weapon.len > 0 and p.inventory.len < InventoryLimit:
    p.inventory.add p.weapon
  p.weapon = id
