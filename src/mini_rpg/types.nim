## Общие типы игры и базовые операции над персонажем.
## Все числа баланса собраны в одном блоке констант ниже.

type
  ItemKind* = enum
    ikWeapon = "оружие"
    ikPotion = "зелье"
    ikQuest = "трофей"

  Item* = object
    id*: string
    name*: string
    desc*: string
    kind*: ItemKind
    price*: int
    power*: int
    heal*: int

  KillRecord* = object
    enemyId*: string
    count*: int

  QuestKind* = enum
    qkKill = "убийства"
    qkCollect = "предметы"

  QuestStatus* = enum
    qsInactive, qsActive, qsReady, qsDone

  Quest* = object
    id*: string
    title*: string
    desc*: string
    kind*: QuestKind
    target*: string
    amount*: int
    rewardGold*: int
    rewardExp*: int
    rewardItem*: string

  QuestState* = object
    id*: string
    status*: QuestStatus
    progress*: int

  Player* = object
    name*: string
    hp*: int
    maxHp*: int
    level*: int
    exp*: int
    power*: int
    gold*: int
    weapon*: string
    inventory*: seq[string]
    kills*: seq[KillRecord]
    quests*: seq[QuestState]

  EnemyMove* = object
    text*: string
    power*: int

  Enemy* = object
    id*: string
    name*: string
    desc*: string
    maxHp*: int
    power*: int
    defense*: int
    expReward*: int
    goldReward*: int
    drops*: seq[string]
    moves*: seq[EnemyMove]
    isBoss*: bool

  EnemyState* = object
    enemy*: Enemy
    hp*: int
    turn*: int

  BattleResult* = enum
    brVictory, brDefeat, brFled

  Game* = object
    player*: Player
    flags*: seq[string]

const
  StartHp* = 30
  StartPower* = 3
  StartGold* = 5
  InventoryLimit* = 12
  ExpBase* = 20
  ExpStep* = 10
  LevelHpGain* = 8
  LevelPowerGain* = 1
  InnPrice* = 10
  RatsInBasement* = 4
  GoblinsInForest* = 3

proc newPlayer*(name: string): Player =
  Player(
    name: name,
    hp: StartHp,
    maxHp: StartHp,
    level: 1,
    exp: 0,
    power: StartPower,
    gold: StartGold,
    weapon: "",
    inventory: @[],
    kills: @[],
    quests: @[],
  )

proc expToNext*(p: Player): int =
  ## Сколько опыта нужно набрать на текущем уровне для следующего.
  ExpBase + (p.level - 1) * ExpStep

proc gainExp*(p: var Player; amount: int): int =
  ## Начисляет опыт и возвращает число полученных уровней.
  p.exp += amount
  while p.exp >= expToNext(p):
    p.exp -= expToNext(p)
    p.level.inc
    p.maxHp += LevelHpGain
    p.hp += LevelHpGain
    p.power += LevelPowerGain
    result.inc

proc heal*(p: var Player; amount: int) =
  p.hp = min(p.maxHp, p.hp + amount)

proc killCount*(p: Player; enemyId: string): int =
  for k in p.kills:
    if k.enemyId == enemyId:
      return k.count

proc registerKill*(p: var Player; enemyId: string) =
  for k in p.kills.mitems:
    if k.enemyId == enemyId:
      k.count.inc
      return
  p.kills.add KillRecord(enemyId: enemyId, count: 1)

proc hasFlag*(g: Game; flag: string): bool =
  flag in g.flags

proc setFlag*(g: var Game; flag: string) =
  if flag notin g.flags:
    g.flags.add flag
