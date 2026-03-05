import 'package:flutter/material.dart';

class MessagePage extends StatelessWidget {
  final String contactName;

  const MessagePage({super.key, required this.contactName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(contactName),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      // On utilise SafeArea pour ne pas que la barre de saisie colle au bas de l'écran
      body: SafeArea(
        child: Column(
          children: [
            // Zone des messages
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildLinkPreview(),
                  const SizedBox(height: 12),
                  _buildChatBubble("Cc ça va ?"),
                ],
              ),
            ),

            // Barre de saisie
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Message",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 13,
                          ),

                          suffixIcon: Icon(Icons.send),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // La bulle de texte
  Widget _buildChatBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF5D546F),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
            topRight: Radius.circular(4),
          ),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // Aperçu du lien
  Widget _buildLinkPreview() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F0F7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: const Icon(Icons.image, size: 50, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Homemade Dumplings",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "everydumplingever.com",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
