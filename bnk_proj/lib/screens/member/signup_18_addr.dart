import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddressSearchPage extends StatefulWidget {
  const AddressSearchPage({super.key});

  @override
  State<AddressSearchPage> createState() => _AddressSearchPageState();
}

class _AddressSearchPageState extends State<AddressSearchPage> {
  final TextEditingController _ctrl = TextEditingController();
  List<dynamic> results = [];

  static const String jusoKey = 'devU01TX0FVVEgyMDI1MTIxNTE5NDEzNjExNjU3MjI=';

  Future<void> search(String query) async {
    final filtered = filterKeyword(query);
    if (filtered.isEmpty) return;

    final uri = Uri.parse(
      'https://business.juso.go.kr/addrlink/addrLinkApi.do'
          '?confmKey=$jusoKey'
          '&currentPage=1'
          '&countPerPage=20'
          '&keyword=$filtered'
          '&resultType=json',
    );

    final res = await http.get(uri);
    final body = jsonDecode(res.body);

    final resultsObj = body['results'];
    final common = resultsObj['common'];

    if (common['errorCode'] != '0') {
      setState(() {
        results = [];
      });
      return;
    }

    final List<dynamic>? juso = resultsObj['juso'];

    setState(() {
      results = juso ?? [];
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주소 검색')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _ctrl,
              decoration: const InputDecoration(
                hintText: '도로명 / 지번 입력',
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: search,
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (_, i) {
                final item = results[i];

                final zip = item['zipNo'];
                final road = item['roadAddrPart1'];

                return ListTile(
                  title: Text(road),
                  subtitle: Text('우편번호: $zip'),
                  onTap: () {
                    Navigator.pop(
                      context,
                      '$zip|$road',
                    );
                  },
                );
              },


            ),
          ),
        ],
      ),
    );
  }

  String filterKeyword(String input) {
    final special = RegExp(r'[%=><]');
    input = input.replaceAll(special, '');

    final sqlWords = [
      'OR','SELECT','INSERT','DELETE','UPDATE',
      'CREATE','DROP','EXEC','UNION','FETCH',
      'DECLARE','TRUNCATE'
    ];

    for (final w in sqlWords) {
      input = input.replaceAll(RegExp(w, caseSensitive: false), '');
    }

    return input.trim();
  }

}
