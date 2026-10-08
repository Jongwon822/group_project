import 'package:flutter/material.dart';
import 'package:group_project/data/user_data.dart';

class JobCategoryScreen extends StatefulWidget {
  final ValueChanged<String> login;
  final UserData ud;

  const JobCategoryScreen({super.key, required this.ud, required this.login});

  @override
  State<JobCategoryScreen> createState() => _JobCategoryScreenState();
}

class _JobCategoryScreenState extends State<JobCategoryScreen> {
  int selectionCounter1 = 0;
  int selectionCounter2 = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '시작하기 전',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        // 앱바 색상 변함 방지
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),

      // 본문 내용 가로 리스트뷰 및 첨삭/피드백 이동 위젯
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Divider(height: 1, thickness: 0.2, color: Colors.grey),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                        onPressed: () {
                          // 사전 설정이 여러페이지가 아니면 나중에 지우기
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 30,
                        )),
                  ),
                  Center( // 시작하기전 단계를 여러 단계로 구분할거면 이거 색깔 바꿔가면서 표시
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 8,color: Colors.grey.shade200,),
                      const SizedBox(width: 10,),
                      const Icon(Icons.circle, size: 8,color: Color(0xFF3B82F6),),
                      const SizedBox(width: 10,),
                      Icon(Icons.circle, size: 8,color: Colors.grey.shade200,),
                    ],
                  ))
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                '직군을 선택해주세요',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: const Text(
                '관심 있는 직군을 선택하시면 맞춤형 채용 정보와 맞춤 커리어를 추천해 드릴게요. (다중 선택 가능)',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        '문과 분야',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 4),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16)),
                        child: Text(
                          selectionCounter1.toString(),
                          style: const TextStyle(fontSize: 11),
                        ),
                      )
                    ],
                  ),

                  // chip 넣을 공간
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: const Text(
                      '준혁아 설정에 만든 chip 여기에 이식해줘',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),

                  Row(
                    children: [
                      const Text(
                        '이과 분야',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 4),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16)),
                        child: Text(
                          selectionCounter2.toString(),
                          style: const TextStyle(fontSize: 11),
                        ),
                      )
                    ],
                  ),
                  // chip 넣을 공간
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: const Text(
                      '준혁아 설정에 만든 chip 여기에 이식해줘',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Colors.black),
              children: [
                const TextSpan(text: '현재 '),
                TextSpan(
                    text: '${selectionCounter1 + selectionCounter2}개',
                    style: const TextStyle(color: Color(0xFF3B82F6))),
                const TextSpan(text: ' 선택됨')
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 300,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                widget.ud.userSettings = widget.ud.userSettings.copyWith(firstSetting: false);
                widget.login(widget.ud.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text(
                '다음 단계로',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          )
        ],
      )),
    );
  }
}
