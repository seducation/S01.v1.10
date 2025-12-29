import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_app/appwrite_service.dart';
import 'package:my_app/model/profile.dart';
import 'package:provider/provider.dart';
import 'package:appwrite/models.dart' as models;

class OneTimeMessageScreen extends StatefulWidget {
  final models.Row message;

  const OneTimeMessageScreen({super.key, required this.message});

  @override
  OneTimeMessageScreenState createState() => OneTimeMessageScreenState();
}

class OneTimeMessageScreenState extends State<OneTimeMessageScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        final appwriteService = context.read<AppwriteService>();
        appwriteService.deleteMessage(widget.message.$id);

        // Use fileId from data if available, else fallback to split logic
        String? fileId = widget.message.data['fileId'];
        if (fileId == null) {
          final imageUrl = widget.message.data['message'];
          fileId = imageUrl.split('/')[6];
        }

        if (fileId != null) {
          appwriteService.deleteFile(fileId);
        }
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Image.network(widget.message.data['message'])),
    );
  }
}

class OTMSelectionList extends StatefulWidget {
  final List<String> imagePaths;
  const OTMSelectionList({super.key, required this.imagePaths});

  @override
  State<OTMSelectionList> createState() => _OTMSelectionListState();
}

class _OTMSelectionListState extends State<OTMSelectionList> {
  late final AppwriteService _appwriteService;
  List<Profile> _contacts = [];
  final Set<String> _selectedContactIds = {};
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _appwriteService = context.read<AppwriteService>();
    _loadFollowingContacts();
  }

  Future<void> _loadFollowingContacts() async {
    try {
      final currentUser = await _appwriteService.getUser();
      if (currentUser == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }
      final profiles = await _appwriteService.getFollowingProfiles(
        userId: currentUser.$id,
      );
      if (!mounted) return;
      setState(() {
        _contacts = profiles.rows
            .map((doc) => Profile.fromMap(doc.data, doc.$id))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _sendOTMs() async {
    if (_selectedContactIds.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final currentUser = await _appwriteService.getUser();
      if (currentUser != null) {
        for (final contactId in _selectedContactIds) {
          for (final imagePath in widget.imagePaths) {
            await _appwriteService.sendOneTimeMessage(
              senderId: currentUser.$id,
              receiverId: contactId,
              imagePath: imagePath,
            );
          }
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sent to ${_selectedContactIds.length} users!'),
          ),
        );
        setState(() {
          _selectedContactIds.clear();
          _isSending = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send messages: $e')));
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_contacts.isEmpty) {
      return const Center(child: Text("You are not following anyone yet."));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _contacts.length,
            itemBuilder: (context, index) {
              final contact = _contacts[index];
              final isSelected = _selectedContactIds.contains(contact.id);
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: contact.profileImageUrl != null
                      ? NetworkImage(contact.profileImageUrl!)
                      : null,
                  child: contact.profileImageUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(contact.name),
                trailing: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedContactIds.add(contact.id);
                      } else {
                        _selectedContactIds.remove(contact.id);
                      }
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedContactIds.remove(contact.id);
                    } else {
                      _selectedContactIds.add(contact.id);
                    }
                  });
                },
              );
            },
          ),
        ),
        if (_selectedContactIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: _isSending ? null : _sendOTMs,
              child: _isSending
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text("Sending..."),
                      ],
                    )
                  : Text("Send to ${_selectedContactIds.length} Users"),
            ),
          ),
      ],
    );
  }
}
