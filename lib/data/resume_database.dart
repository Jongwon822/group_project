import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

//혹시 db파일 열어보고싶으면 VS Code에 SQLite Viewer 설치하면됨
//editing screen에서 자소서 저장하면 resumes 테이블에 추가됨

class ResumeDatabase {
  static Future<Database> open() async {
    // Windows와 Android에서 같은 SQLite 실행 방식을 사용한다.
    sqfliteFfiInit();

    // 앱 전용 폴더에 저장할 DB 파일의 경로를 정한다.
    final directory = await getApplicationSupportDirectory();
    final dbPath = p.join(directory.path, 'resume.db');

    print(dbPath);//자소서 저장하면 db저장경로 출력

    return databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,

        // DB를 열 때 외래키 제약을 적용한다.
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),

        // DB 파일을 처음 만들 때 테이블 세 개를 생성한다.
        onCreate: (db, version) async {
          // 1. 자소서
          await db.execute('''
            CREATE TABLE resumes (
              id INTEGER PRIMARY KEY,
              user_id TEXT NOT NULL,
              title TEXT NOT NULL,
              job TEXT,
              original_text TEXT NOT NULL,
              edited_text TEXT NOT NULL,
              UNIQUE (user_id, title)
            )
          ''');

          // 2. 면접 회차. resume_id로 자소서와 연결한다.
          // created_at에는 생성 시각을 밀리초 단위 정수로 저장한다.
          await db.execute('''
            CREATE TABLE interview_sessions (
              id INTEGER PRIMARY KEY,
              resume_id INTEGER NOT NULL,
              created_at INTEGER NOT NULL,
              FOREIGN KEY (resume_id) REFERENCES resumes (id)
            )
          ''');

          // 3. 피드백 기록. 같은 회차에서는 질문 번호가 겹칠 수 없다.
          await db.execute('''
            CREATE TABLE feedback_records (
              session_id INTEGER NOT NULL,
              question_no INTEGER NOT NULL CHECK (question_no >= 1),
              question TEXT NOT NULL,
              answer TEXT NOT NULL,
              feedback TEXT NOT NULL,
              PRIMARY KEY (session_id, question_no),
              FOREIGN KEY (session_id) REFERENCES interview_sessions (id)
            )
          ''');
        },
      ),
    );
  }

  // 기존 자소서를 갱신하면 true, 새로 저장하면 false를 반환한다.
  static Future<bool> saveResume({
    required String userId,
    required String title,
    required String? job,
    required String originalText,
    required String editedText,
  }) async {
    final db = await open();

    final values = <String, Object?>{
      'job': job,
      'original_text': originalText,
      'edited_text': editedText,
    };

    // 갱신 시도와 필요할 때의 삽입을 한 트랜잭션으로 처리한다.
    return db.transaction((txn) async {
      // 현재 사용자와 저장 제목이 모두 일치하는 행을 갱신한다.
      final updated = await txn.update(
        'resumes', // 갱신할 테이블
        values, // 바꿀 열과 새 값
        where: 'user_id = ? AND title = ?',
        whereArgs: [userId, title],
      );

      if (updated > 0) return true;

      // 갱신된 행이 없으면 새 자소서를 추가한다.
      await txn.insert('resumes', {
        'user_id': userId,
        'title': title,
        ...values,
      });

      return false;
    });
  }

  //feedback_screen에서 조회
  static Future<List<Map<String, Object?>>> getResumes(String userId) async {
    final db = await open();

    return db.query(
      'resumes',
      columns: ['id', 'title', 'job'], // 목록에 필요한 열만 가져온다.
      where: 'user_id = ?', // 로그인한 사용자의 자소서만 가져온다.
      whereArgs: [userId],
      orderBy: 'id DESC', // 새로 추가한 자소서부터
    );
  }

}