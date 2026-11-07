## Каталог квестов, журнал и отслеживание прогресса.

import mini_rpg/types
import mini_rpg/items

const Quests* = [
  Quest(
    id: "rats", title: "Крысы в подвале",
    desc: "Трактирщик просит вывести крыс из подвала: их развелось слишком много.",
    kind: qkKill, target: "cave_rat", amount: RatsInBasement,
    rewardGold: 25, rewardExp: 40,
  ),
  Quest(
    id: "goblin_steel", title: "Гоблинская сталь",
    desc: "Кузнец хочет два обломка гоблинской стали: из них выйдет добрый клинок.",
    kind: qkCollect, target: "goblin_steel", amount: 2,
    rewardGold: 30, rewardExp: 50,
  ),
]

proc questById*(id: string): Quest =
  for quest in Quests:
    if quest.id == id:
      return quest
  Quest(id: "", title: "неизвестный квест")

proc questIndex*(p: Player; id: string): int =
  for i, state in p.quests:
    if state.id == id:
      return i
  -1

proc questState*(p: Player; id: string): QuestState =
  let idx = p.questIndex(id)
  if idx >= 0:
    p.quests[idx]
  else:
    QuestState(id: id, status: qsInactive, progress: 0)

proc questProgress*(p: Player; quest: Quest): int =
  case quest.kind
  of qkKill: p.killCount(quest.target)
  of qkCollect: p.countItem(quest.target)

proc refreshQuest*(p: var Player; id: string) =
  ## Пересчитывает прогресс квеста по текущему состоянию игрока.
  let idx = p.questIndex(id)
  if idx < 0:
    return
  if p.quests[idx].status notin {qsActive, qsReady}:
    return
  let quest = questById(id)
  p.quests[idx].progress = min(quest.amount, p.questProgress(quest))
  p.quests[idx].status =
    if p.quests[idx].progress >= quest.amount: qsReady else: qsActive

proc acceptQuest*(p: var Player; id: string): bool =
  if p.questIndex(id) < 0:
    p.quests.add QuestState(id: id, status: qsActive, progress: 0)
  elif p.quests[p.questIndex(id)].status == qsInactive:
    p.quests[p.questIndex(id)].status = qsActive
  else:
    return false
  refreshQuest(p, id)
  true

proc canTurnIn*(p: Player; id: string): bool =
  p.questState(id).status == qsReady

proc turnInQuest*(p: var Player; id: string): bool =
  ## Сдаёт готовый квест: забирает трофеи и выдаёт награду.
  if not p.canTurnIn(id):
    return false
  let quest = questById(id)
  if quest.kind == qkCollect:
    for _ in 0 ..< quest.amount:
      if not p.removeItem(quest.target):
        return false
  discard p.gainExp(quest.rewardExp)
  p.gold += quest.rewardGold
  if quest.rewardItem.len > 0:
    discard p.addItem(quest.rewardItem)
  let idx = p.questIndex(id)
  p.quests[idx].status = qsDone
  p.quests[idx].progress = quest.amount
  true

proc activeQuests*(p: Player): seq[QuestState] =
  for state in p.quests:
    if state.status in {qsActive, qsReady}:
      result.add state

proc questStatusText*(state: QuestState): string =
  case state.status
  of qsInactive: "не взято"
  of qsActive: "в процессе"
  of qsReady: "готово к сдаче"
  of qsDone: "выполнено"
