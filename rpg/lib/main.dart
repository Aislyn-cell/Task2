import 'dart:io';
import 'dart:math';

Future<int> calculate(int a, int b) async {
  return a + b; 
}

class Character {
  String name;
  int health;
  int attack;
  int defense;

  Character(this.name, this.health, this.attack, this.defense);

  void attackMonster(Monster monster) {
    int damage = attack;
    monster.takeDamage(damage);
    print('$name이(가) ${monster.name}에게 $damage의 데미지를 입혔습니다.');
  }

  void defend(int damageTaken) {
    health += damageTaken;
    // ignore: unnecessary_brace_in_string_interps
    print('$name이(가) 방어 태세를 취하여 ${damageTaken}만큼 체력을 회복했습니다.');
  }

  void takeDamage(int damage) {
    health -= damage;
    print('$name이(가) $damage의 데미지를 입었습니다.');
  }

  void showStatus() {
    print('$name - 체력: $health, 공격력: $attack, 방어력: $defense');
  }

  bool isAlive() {
    return health > 0;
  }
}

class Monster {
  String name;
  int health;
  int attack;
  final int attackRangeMax;

  Monster(this.name, this.health, this.attackRangeMax, int characterDefense)
    : attack = 0 {
    Random random = Random();
    int randomAttack = random.nextInt(attackRangeMax + 1);
    attack = max(characterDefense, randomAttack);
  }

  void attackCharacter(Character character) {
    int damage = max(0, attack - character.defense);
    character.takeDamage(damage);
    print('$name이(가) ${character.name}에게 $damage의 데미지를 입혔습니다.');
  }

  void takeDamage(int damage) {
    health -= damage;
    print('$name이(가) $damage의 데미지를 입었습니다.');
  }

  void showStatus() {
    print('$name - 체력: $health, 공격력: $attack');
  }

  bool isAlive() {
    return health > 0;
  }
}

class Game {
  Character character;
  List<Monster> monsterList;
  int defeatedMonsterCount = 0;

  Game(this.character, this.monsterList);

  void startGame() {
    print('\n게임을 시작합니다!\n');
    character.showStatus();
    print('\n');

    while (character.isAlive() && defeatedMonsterCount < monsterList.length) {
      Monster monster = getRandomMonster();
      if (battle(monster)) {
        defeatedMonsterCount++;
        if (defeatedMonsterCount < monsterList.length) {
          stdout.write('다음 몬스터와 대결하시겠습니까? (y/n): ');
          String? nextBattle = stdin.readLineSync();
          if (nextBattle?.toLowerCase() != 'y') {
            break;
          }
        }
      } else {
        break;
      }
    }

    String gameResult =
        character.isAlive() && defeatedMonsterCount == monsterList.length
            ? '승리'
            : '패배';

    print(gameResult == '승리' ? '모든 몬스터를 물리치고 승리했습니다!' : '패배했습니다!');

    // 게임 결과 저장 여부 확인
    stdout.write('결과를 저장하시겠습니까? (y/n): ');
    String? saveResult = stdin.readLineSync();
    if (saveResult?.toLowerCase() == 'y') {
      saveGameResult(character, gameResult);
    }
  }

  bool battle(Monster monster) {
    print('\n새로운 몬스터가 나타났습니다!\n');
    monster.showStatus();
    print('\n');

    while (character.isAlive() && monster.isAlive()) {
      print('${character.name}의 턴\n');
      stdout.write('행동을 선택하세요 (1: 공격, 2: 방어): ');
      String? action = stdin.readLineSync();

      if (action == '1') {
        character.attackMonster(monster);
      } else if (action == '2') {
        character.defend(monster.attack);
      } else {
        print('잘못된 입력입니다.');
        continue;
      }

      if (!monster.isAlive()) {
        break;
      }

      print('\n${monster.name}의 턴\n');
      monster.attackCharacter(character);

      print('\n');
      character.showStatus();
      monster.showStatus();
      print('\n');
    }

    if (character.isAlive()) {
      print('${monster.name}을(를) 물리쳤습니다!\n');
      monsterList.remove(monster);
      return true;
    } else {
      return false;
    }
  }

  Monster getRandomMonster() {
    Random random = Random();
    int randomIndex = random.nextInt(monsterList.length);
    return monsterList[randomIndex];
  }

  void saveGameResult(Character character, String gameResult) {
    File resultFile = File('result.txt');
    String resultData =
        '캐릭터 이름: ${character.name}\n남은 체력: ${character.health}\n게임 결과: $gameResult';
    resultFile.writeAsStringSync(resultData);
    print('결과가 result.txt 파일에 저장되었습니다.');
  }
}

void main() {
  // 캐릭터 이름 입력 및 유효성 검증
  String playerName;
  while (true) {
    stdout.write('캐릭터 이름을 입력하세요 (한글, 영문 대소문자만 허용): ');
    playerName = stdin.readLineSync() ?? '';
    if (playerName.isNotEmpty &&
        RegExp(r'^[a-zA-Z가-힣]+$').hasMatch(playerName)) {
      break;
    }
    print('유효하지 않은 이름입니다. 다시 입력해주세요.');
  }

  // 캐릭터 스탯 파일에서 읽어오기
  Character player;
  try {
    File characterFile = File('characters.txt');
    String characterData = characterFile.readAsStringSync();
    List<String> characterStats = characterData.split(',');
    player = Character(
      playerName,
      int.parse(characterStats[0]),
      int.parse(characterStats[1]),
      int.parse(characterStats[2]),
    );
  } catch (e) {
    print('characters.txt 파일을 읽는 중 오류가 발생했습니다: $e');
    return; // 프로그램 종료
  }

  // 몬스터 스탯 파일에서 읽어오기
  List<Monster> monsters = [];
  try {
    File monsterFile = File('monsters.txt');
    List<String> monsterLines = monsterFile.readAsLinesSync();
    for (String line in monsterLines) {
      List<String> monsterStats = line.split(',');
      monsters.add(
        Monster(
          monsterStats[0],
          int.parse(monsterStats[1]),
          int.parse(monsterStats[2]),
          player.defense,
        ),
      );
    }
  } catch (e) {
    print('monsters.txt 파일을 읽는 중 오류가 발생했습니다: $e');
    return; // 프로그램 종료
  }

  Game game = Game(player, monsters);
  game.startGame();
}
