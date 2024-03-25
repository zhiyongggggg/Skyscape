import 'package:flutter/material.dart';
import 'package:skyscape/screens/home/home.dart';
import 'package:skyscape/services/database.dart';
import 'package:skyscape/services/auth.dart';


class SearchUsers extends StatefulWidget {
  const SearchUsers({super.key});

  @override
  State<SearchUsers> createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  String searchQuery = '';
  final AuthService _auth = AuthService();
  String foundUser = ""; 
  String followingStatus = "";
  bool isLoading = false; // Flag for loading state
  bool isFirstBoot = true; // Flag for initial state

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
                  getData(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search for an user...',
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
              child: isLoading ? _buildLoadingWidget() : (isFirstBoot ? Container() : _buildUserWidgets()),
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

  Widget _buildUserWidgets() {
    if (foundUser == "No user found.") {
      return Center(
        child: Text("No user found."),
      );
    } else {
      return Expanded(
        child: ListView(
          children: [
            ListTile(
              title: Text(foundUser),
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
    }
  }

  void unfollow(String username) async {
    setState(() {
      isLoading = true; // Set loading state to true before fetching data
    });

    await DatabaseService(uid: _auth.currentUser!.uid).unfollowUser(username);
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


  void getData(String username) async {
    setState(() {
      isLoading = true; // Set loading state to true before fetching data
      isFirstBoot = false; 
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

