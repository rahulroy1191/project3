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
      title: 'Photo Gallery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PhotoListPage(),
    );
  }
}

class PhotoListPage extends StatefulWidget {
  @override
  _PhotoListPageState createState() => _PhotoListPageState();
}

class _PhotoListPageState extends State<PhotoListPage> {
  List<dynamic> _photos = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchPhotos();
  }

  Future<void> _fetchPhotos() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final response =
      await http.get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));
      if (response.statusCode == 200) {
        setState(() {
          _photos = json.decode(response.body);
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _error = 'Failed to load photos';
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Gallery'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : ListView.builder(
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          final photo = _photos[index];
          return ListTile(
            title: Text(photo['title']),
            leading: Image.network(
              photo['thumbnailUrl'],
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoDetailPage(photo: photo),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PhotoDetailPage extends StatelessWidget {
  final Map<String, dynamic> photo;

  PhotoDetailPage({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              photo['url'],
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16),
            Text(
              'Title: ${photo['title']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'ID: ${photo['id']}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
