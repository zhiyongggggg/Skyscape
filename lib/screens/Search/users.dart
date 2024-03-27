import 'package:flutter/material.dart';
import 'package:skyscape/screens/Search/followedusers.dart';
import 'package:skyscape/screens/home/home.dart';
import 'package:skyscape/services/database.dart';
import 'package:skyscape/services/auth.dart';

class SearchUsers extends StatefulWidget {
  const SearchUsers({super.key});

  @override
  State<SearchUsers> createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  @override
  void initState() {
    super.initState();
    getData();
  }

  String searchQuery = '';
  final AuthService _auth = AuthService();
  String foundUser = "";
  String targetUserID = "";
  String followingStatus = "";
  bool isLoading = false; // Flag for loading state
  bool showFollowingList = true; // Flag for initial state
  List<String> followingList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange[300]!, Colors.orange[200]!],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                onSubmitted: (value) {
                  if (value == "") {
                    showFollowingList = true;
                    getData();
                  } else {
                    showFollowingList = false;
                    searchUsername(value);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search for a user...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? _buildLoadingWidget()
                  : (showFollowingList
                      ? _buildFollowingListWidget(followingList)
                      : _buildUserWidgets()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildFollowingListWidget(List<String> followingList) {
    return ListView.builder(
      itemCount: followingList.length,
      itemBuilder: (context, index) {
        final username = followingList[index];
        return FutureBuilder<Map<String, dynamic>>(
          future: DatabaseService(uid: _auth.currentUser!.uid).getUserData(username),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListTile(
                leading: CircleAvatar(),
                title: Text(username),
              );
            }
            final userData = snapshot.data ?? {};
            final profilePicture = userData['profilePicture'] ?? '';
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: profilePicture.isNotEmpty
                    ? NetworkImage(profilePicture)
                    : AssetImage('assets/default_profile.jpg') as ImageProvider,
              ),
              title: Text(username),
              onTap: () {
                // Navigate to FollowedUser page when a username is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FollowedUser(username: username),
                  ),
                );
              },
              trailing: ElevatedButton(
                onPressed: () {
                  // Handle unfollow action
                  unfollow(username);
                },
                child: Text("Unfollow"),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserWidgets() {
    if (foundUser == "No user found.") {
      return Center(
        child: Text("No user found."),
      );
    } else {
      return FutureBuilder<Map<String, dynamic>>(
        future: DatabaseService(uid: _auth.currentUser!.uid).getUserData(foundUser),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListTile(
              leading: CircleAvatar(),
              title: Text(foundUser),
            );
          }
          final userData = snapshot.data ?? {};
          final profilePicture = userData['profilePicture'] ?? '';
          return Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: profilePicture.isNotEmpty
                        ? NetworkImage(profilePicture)
                        : AssetImage('assets/default_profile.jpg') as ImageProvider,
                  ),
                  title: Text(foundUser),
                  onTap: () {
                    // Navigate to FollowedUser page when the username is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FollowedUser(username: foundUser),
                      ),
                    );
                  },
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Handle follow/unfollow action
                      if (followingStatus == "following") {
                        unfollow(foundUser);
                      } else if (followingStatus == "not_following") {
                        follow(foundUser);
                      }
                    },
                    child: Text(followingStatus == "not_following" ? "Follow" : "Unfollow"),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void unfollow(String username) async {
    setState(() {
      isLoading = true; // Set loading state to true before fetching data
    });

    await DatabaseService(uid: _auth.currentUser!.uid).unfollowUser(username);
    followingList = await DatabaseService(uid: _auth.currentUser!.uid).getFollowingList();
    followingStatus = "not_following";
    setState(() {
      isLoading = false; // Set loading state to false after fetching data
    });
  }

  void follow(String username) async {
    setState(() {
      isLoading = true; // Set loading state to true before fetching data
    });

    await DatabaseService(uid: _auth.currentUser!.uid).followUser(username);
    followingStatus = "following";
    setState(() {
      isLoading = false; // Set loading state to false after fetching data
    });
  }

  void getData() async {
    followingList.clear();
    setState(() {
      isLoading = true; // Set loading state to true before fetching data
    });

    followingList = await DatabaseService(uid: _auth.currentUser!.uid).getFollowingList();

    setState(() {
      isLoading = false; // Set loading state to false after fetching data
    });
  }

  void searchUsername(String username) async {
    setState(() {
      isLoading = true; // Set loading state to true before fetching data
    });

    String user = await DatabaseService(uid: _auth.currentUser!.uid).findUsername(username);
    foundUser = user;

    List<String> followingList = await DatabaseService(uid: _auth.currentUser!.uid).getFollowingList();

    setState(() {
      isLoading = false; // Set loading state to false after fetching data
      if (followingList.contains(username)) {
        followingStatus = "following";
      } else {
        followingStatus = "not_following";
      }
    });
  }
}