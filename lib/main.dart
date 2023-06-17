import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Pagination Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String apiUrl = 'https://jsonplaceholder.typicode.com/posts';
  final int postsPerPage = 10;
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _posts = [];
  int _currentPage = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchPosts();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _fetchPosts();
    }
  }

  Future<void> _fetchPosts() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      final response = await http.get(Uri.parse(
          '$apiUrl?_start=${(_currentPage - 1) * postsPerPage}&_limit=$postsPerPage'));
      final data = jsonDecode(response.body) as List<dynamic>;

      setState(() {
        _posts.addAll(data);
        _currentPage++;
        _isLoading = false;
      });
    }
  }

  Widget _buildList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _posts.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _posts.length) {
          return ListTile(
            title: Text(_posts[index]['title']),
            subtitle: Text(_posts[index]['body']),
          );
        } else {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: Card(
        color: Colors.white,
        margin: const EdgeInsets.all(10),
        elevation: 2,
          child: _buildList()
      ),

    );
  }
}
