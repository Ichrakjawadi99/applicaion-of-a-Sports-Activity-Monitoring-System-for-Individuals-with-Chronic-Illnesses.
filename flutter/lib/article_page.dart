import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: ArticlePage(),
  ));
}

class Article {
  final String title;
  final String content;

  Article(this.title, this.content);
}

class ArticlePage extends StatefulWidget {
  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  List<Article> articles = [
    Article(
      'The Importance of Water',
      'Water is essential for life. It regulates body temperature, keeps joints lubricated, helps prevent infections, and delivers nutrients to cells. Staying hydrated improves sleep quality, cognition, and mood.',
    ),
    Article(
      'Benefits of Physical Exercise',
      'Regular physical exercise can improve your muscle strength and boost your endurance. Exercise delivers oxygen and nutrients to your tissues and helps your cardiovascular system work more efficiently. It can also improve mental health and mood.',
    ),
    Article(
      'Walking for Chronic Disease Management',
      'Walking is a low-impact exercise that is easy, free, and suitable for people of all ages and most abilities. Regular walking can help reduce the risk of chronic illnesses such as heart disease, stroke, diabetes, and some cancers. It can also improve cardiovascular health, strengthen bones, and enhance mental well-being.',
    ),
    // Add more articles in English, French, or Arabic as needed
  ];
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Simulate loading time
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scientific Articles'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.white,
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(
                          articles[index].title,
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArticleDetailPage(article: articles[index]),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      backgroundColor: Colors.black,
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  final Article article;

  ArticleDetailPage({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          article.content,
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
