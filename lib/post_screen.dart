import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  List<dynamic> allPosts = [];
  List<dynamic> displayPosts = [];

  int currentLength = 0;
  final int increment = 10;
  bool isLoadingMore = false;
  bool isInitialLoading = true;

  final ScrollController _scrollController = ScrollController();

  List<Color> cardColors = [
    Colors.indigo.shade50,
    Colors.indigo.shade100,
  ];

  @override
  void initState() {
    super.initState();
    fetchAllPosts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isLoadingMore) {
        loadMore();
      }
    });
  }

  Future<void> fetchAllPosts() async {
    final url = Uri.parse('https://jsonplaceholder.typicode.com/posts');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        allPosts = data;
        isInitialLoading = false;
        loadMore();
      });
    }
  }

  void loadMore() {
    if (currentLength >= allPosts.length) return;

    setState(() {
      isLoadingMore = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        int nextLength = currentLength + increment;
        if (nextLength > allPosts.length) {
          nextLength = allPosts.length;
        }

        displayPosts.addAll(allPosts.getRange(currentLength, nextLength));
        currentLength = nextLength;
        isLoadingMore = false;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget buildPostCard(dynamic post, int index) {
    return Card(
      color: cardColors[index % cardColors.length],
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post['title'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              post['body'],
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blue],
            ),
          ),
        ),
        title: const Text(
          'Posts List',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: displayPosts.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < displayPosts.length) {
                  return buildPostCard(displayPosts[index], index);
                } else {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
    );
  }
}
