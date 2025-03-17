import 'dart:io';
import 'dart:math';

// calculate 함수를 정의합니다. (예시)
int calculate(int a, int b) {
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
    print('$name이(가) 방어 태세를 취하여 $damageTaken만큼 체력을 회복했습니다.');
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
  final int attackRangeMax; // 몬스터 공격력 범위 최대값

  Monster(this.name, this.health, this.attackRangeMax, int characterDefense) {
    // 몬스터 공격력 설정: 캐릭터 방어력과 랜덤 값 중 최대값으로 설정
    Random random = Random();
    int randomAttack = random.nextInt(attackRangeMax + 1);
    attack = max(characterDefense, randomAttack);
  }

  void attackCharacter(Character character) {
    int damage = max(0, attack - character.defense); // 최소 데미지는 0
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

    if (character.isAlive() && defeatedMonsterCount == monsterList.length) {
      print('모든 몬스터를 물리치고 승리했습니다!');
    } else {
      print('패배했습니다!');
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
        character.defend(monster.attack); // 몬스터 공격력만큼 체력 회복
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
      monsterList.remove(monster); // 처치한 몬스터 제거
      return true;
    } else {
      print('패배했습니다!\n');
      return false;
    }
  }

  Monster getRandomMonster() {
    Random random = Random();
    int randomIndex = random.nextInt(monsterList.length);
    return monsterList[randomIndex];
  }
}

void main() {
  stdout.write('캐릭터의 이름을 입력하세요: ');
  String? playerName = stdin.readLineSync();
  Character player = Character(playerName ?? 'player', 50, 10, 5);

  List<Monster> monsters = [
    Monster('Spiderman', 20, 5, player.defense), // 몬스터 공격력 범위 최대값과 캐릭터 방어력 전달
    Monster('Goblin', 30, 7, player.defense),
    Monster('Dragon', 40, 9, player.defense),
    // 원하는 만큼 몬스터 추가
  ];

  Game game = Game(player, monsters);
  game.startGame();
} // TODO Implement this library.
