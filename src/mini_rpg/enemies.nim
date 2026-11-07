## Каталог врагов и логика боя.
## Числа подобраны так, чтобы дорога до города была опасной, но проходимой
## без зелий, а босс требовал подготовки.

import mini_rpg/types
import mini_rpg/items

const Enemies* = [
  Enemy(
    id: "cave_rat", name: "Пещерная крыса", maxHp: 10, power: 2, defense: 0,
    expReward: 10, goldReward: 2,
    desc: "Крыса размером с кошку. Шипит и скалит зубы.",
    moves: @[EnemyMove(text: "вцепляется в ногу", power: 2)],
  ),
  Enemy(
    id: "goblin", name: "Гоблин", maxHp: 16, power: 3, defense: 1,
    expReward: 18, goldReward: 6,
    desc: "Сутулый гоблин с ржавым тесаком.",
    drops: @["goblin_steel"],
    moves: @[
      EnemyMove(text: "бьёт тесаком", power: 3),
      EnemyMove(text: "пинает тебя", power: 2),
    ],
  ),
  Enemy(
    id: "bandit", name: "Дорожный разбойник", maxHp: 18, power: 4, defense: 1,
    expReward: 30, goldReward: 12,
    desc: "Оборванец с дубиной перегородил дорогу.",
    moves: @[
      EnemyMove(text: "обрушивает дубину", power: 4),
      EnemyMove(text: "бьёт кулаком", power: 2),
    ],
  ),
  Enemy(
    id: "skeleton", name: "Скелет-стражник", maxHp: 30, power: 6, defense: 3,
    expReward: 40, goldReward: 15,
    desc: "Кости в ржавой кольчуге скрипят, поднимая меч.",
    moves: @[
      EnemyMove(text: "рубит ржавым мечом", power: 6),
      EnemyMove(text: "бьёт щитом", power: 4),
    ],
  ),
  Enemy(
    id: "boss", name: "Барон Кровавый Клык", maxHp: 90, power: 12, defense: 4,
    expReward: 200, goldReward: 100,
    desc: "Хозяин замка. Огромный, в чёрных доспехах, с двуручным мечом.",
    isBoss: true,
    moves: @[
      EnemyMove(text: "обрушивает двуручный меч", power: 11),
      EnemyMove(text: "бьёт щитом в лицо", power: 7),
      EnemyMove(text: "издаёт боевой клич и рубит сверху", power: 14),
    ],
  ),
]

proc enemyById*(id: string): Enemy =
  for enemy in Enemies:
    if enemy.id == id:
      return enemy
  Enemy(id: "", name: "неизвестный враг")

proc newEnemy*(id: string): EnemyState =
  let enemy = enemyById(id)
  EnemyState(enemy: enemy, hp: enemy.maxHp, turn: 0)

proc damageAgainst*(attackerPower, defenderDefense: int): int =
  ## Урон не может быть меньше единицы: иначе бой заходит в тупик.
  max(1, attackerPower - defenderDefense)

proc playerHit*(p: Player; e: EnemyState): int =
  damageAgainst(p.attackPower, e.enemy.defense)

proc enemyHit*(e: EnemyState; p: Player): tuple[text: string, damage: int] =
  let move = e.enemy.moves[e.turn mod e.enemy.moves.len]
  (text: move.text, damage: damageAgainst(move.power, 0))
