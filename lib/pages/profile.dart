import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fornature/auth/register/register.dart';
import 'package:fornature/components/stream_grid_wrapper.dart';
import 'package:fornature/models/post.dart';
import 'package:fornature/models/user.dart';
import 'package:fornature/screens/edit_profile.dart';
import 'package:fornature/utils/firebase.dart';
import 'package:fornature/widgets/post_tiles.dart';

class Profile extends StatefulWidget {
  final profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User user;
  bool isLoading = false;
  int postCount = 0;
  int followersCount = 0;
  int followingCount = 0;
  //int visithistory = 0;
  // bool isToggle = true; // list or grid view of posts
  bool isFollowing = false;
  bool isvisitHistory = false;
  UserModel users;
  final DateTime timestamp = DateTime.now();
  ScrollController controller = ScrollController();

  currentUserId() {
    return firebaseAuth.currentUser?.uid;
  }

  @override
  void initState() {
    super.initState();
    checkIfFollowing();
    // checkIfvisithistory();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId())
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('내 프로필'),
        actions: [
          widget.profileId == firebaseAuth.currentUser.uid
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 3.0, right: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        firebaseAuth.signOut();
                        Navigator.of(context).push(
                            CupertinoPageRoute(builder: (_) => Register()));
                      },
                      child: Text(
                        'Log Out',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14.0),
                      ),
                    ),
                  ),
                )
              : SizedBox()
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            floating: false,
            toolbarHeight: 5.0,
            collapsedHeight: 6.0,
            expandedHeight: 210.0,
            flexibleSpace: FlexibleSpaceBar(
              background: StreamBuilder(
                stream: usersRef.doc(widget.profileId).snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  /* profile pic */
                  if (snapshot.hasData) {
                    UserModel user = UserModel.fromJson(snapshot.data.data());
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 28.0),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(user?.photoUrl),
                                radius: 50.0,
                              ),
                            ),
                            SizedBox(width: 20.0),
                            /* username */
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 32.0),
                                Row(
                                  children: [
                                    Visibility(
                                      visible: false,
                                      child: SizedBox(width: 10.0),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 130.0,
                                          child: Text(
                                            user?.username,
                                            style: TextStyle(
                                                fontSize: 23.0,
                                                fontWeight: FontWeight.w900),
                                            maxLines: null,
                                          ),
                                        ),
                                        // Container(
                                        //   width: 130.0,
                                        //   child: Text(
                                        //     user?.country,
                                        //     style: TextStyle(
                                        //       fontSize: 12.0,
                                        //       fontWeight: FontWeight.w600,
                                        //     ),
                                        //     maxLines: 1,
                                        //     overflow: TextOverflow.ellipsis,
                                        //   ),
                                        // ),
                                        /* email account */
                                        SizedBox(height: 5.0),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user?.email,
                                              style: TextStyle(
                                                // color: Color(0xff4D4D4D),
                                                fontSize: 15.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    /* settings button */
                                    // widget.profileId == currentUserId()
                                    //     ? InkWell(
                                    //         onTap: () {
                                    //           Navigator.of(context).push(
                                    //             CupertinoPageRoute(
                                    //               builder: (_) => Setting(),
                                    //             ),
                                    //           );
                                    //         },
                                    //         child: Column(
                                    //           children: [
                                    //             Icon(
                                    //               Icons.settings,
                                    //               // color: Theme.of(context)
                                    //               //     .accentColor
                                    //             ),
                                    //             Text(
                                    //               'settings',
                                    //               style:
                                    //                   TextStyle(fontSize: 11.5),
                                    //             )
                                    //           ],
                                    //         ),
                                    //       )
                                    //     : buildLikeButton()
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        /* bio */
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 10.0, left: 20.0),
                        //   child: user.bio.isEmpty
                        //       ? Container()
                        //       : Container(
                        //           width: 200,
                        //           child: Text(
                        //             user?.bio,
                        //             style: TextStyle(
                        //               //    color: Color(0xff4D4D4D),
                        //               fontSize: 10.0,
                        //               fontWeight: FontWeight.w600,
                        //             ),
                        //             maxLines: null,
                        //           ),
                        //         ),
                        // ),

                        /* POSTS, FOLLOWERS, FOLLOWING */
                        SizedBox(height: 15.0),
                        Center(
                          child: Container(
                            height: 50.0,
                            width: 350.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Container(
                                    width: 50.0,
                                    child: StreamBuilder(
                                      stream: postRef
                                          .where('ownerId',
                                              isEqualTo: widget.profileId)
                                          .snapshots(),
                                      builder: (context,
                                          AsyncSnapshot<QuerySnapshot>
                                              snapshot) {
                                        if (snapshot.hasData) {
                                          QuerySnapshot snap = snapshot.data;
                                          List<DocumentSnapshot> docs =
                                              snap.docs;
                                          return buildCount(
                                              "포스트", docs?.length ?? 0);
                                        } else {
                                          return buildCount("포스트", 0);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                /* line between posts and followers */
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: Container(
                                    height: 50.0,
                                    width: 0.3,
                                    color: Colors.black,
                                  ),
                                ),
                                Container(
                                  width: 50.0,
                                  child: StreamBuilder(
                                    stream: followersRef
                                        .doc(widget.profileId)
                                        .collection('userFollowers')
                                        .snapshots(),
                                    builder: (context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasData) {
                                        QuerySnapshot snap = snapshot.data;
                                        List<DocumentSnapshot> docs = snap.docs;
                                        return buildCount(
                                            "팔로워", docs?.length ?? 0);
                                      } else {
                                        return buildCount("팔로워", 0);
                                      }
                                    },
                                  ),
                                ),
                                /* line between followers and following */
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: Container(
                                    height: 50.0,
                                    width: 0.3,
                                    color: Colors.black,
                                  ),
                                ),
                                Container(
                                  width: 50.0,
                                  child: StreamBuilder(
                                    stream: followingRef
                                        .doc(widget.profileId)
                                        .collection('userFollowing')
                                        .snapshots(),
                                    builder: (context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasData) {
                                        QuerySnapshot snap = snapshot.data;
                                        List<DocumentSnapshot> docs = snap.docs;
                                        return buildCount(
                                            "팔로잉", docs?.length ?? 0);
                                      } else {
                                        return buildCount("팔로잉", 0);
                                      }
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: Container(
                                    height: 50.0,
                                    width: 0.3,
                                    color: Colors.black,
                                  ),
                                ),
                                Container(
                                  width: 50.0,
                                  child: StreamBuilder(
                                    stream: visithistoryRef
                                        .doc(currentUserId())
                                        .collection('visithistory')
                                        .snapshots(),
                                    builder: (context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasData) {
                                        QuerySnapshot snap = snapshot.data;
                                        List<DocumentSnapshot> docs = snap.docs;
                                        //print(docs[0].get('Count'));
                                        return buildCount(
                                            "방문기록",docs[0]?.get('Count') ?? 0);
                                      } else {
                                        return buildCount("방문기록", 0);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        //),
                        buildProfileButton(user),
                      ],
                    );
                  }
                  return Container();
                },
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index > 0) return null;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Text(
                            '모든 포스트',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          /* view mode icon */
                          // Spacer(),
                          // buildIcons(),
                        ],
                      ),
                    ),
                    // buildPostView()
                    buildGridPost()
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }

/*
//show the toggling icons "grid" or "list" view.
  buildIcons() {
    if (isToggle) {
      return IconButton(
          icon: Icon(Icons.list),
          onPressed: () {
            setState(() {
              isToggle = false;
            });
          });
    } else if (isToggle == false) {
      return IconButton(
        icon: Icon(Icons.grid_view),
        onPressed: () {
          setState(() {
            isToggle = true;
          });
        },
      );
    }
  }
*/

  buildCount(String label, int count) {
    return Column(
      children: <Widget>[
        /* count text style */
        Text(
          count.toString(),
          style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w900,
              fontFamily: 'Ubuntu-Regular'),
        ),
        SizedBox(height: 4.0),
        /* category text style */
        Text(
          label,
          style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
              fontFamily: 'Ubuntu-Regular'),
        )
      ],
    );
  }

  buildProfileButton(user) {
    //if isMe then display "edit profile"
    bool isMe = widget.profileId == firebaseAuth.currentUser.uid;
    if (isMe) {
      return buildButton(
          text: "프로필 수정",
          function: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => EditProfile(
                  user: user,
                ),
              ),
            );
          });
      //if you are already following the user then "unfollow"
    } else if (isFollowing) {
      return buildButton(
        text: "Unfollow",
        function: handleUnfollow,
      );
      //if you are not following the user then "follow"
    } else if (!isFollowing) {
      return buildButton(
        text: "Follow",
        function: handleFollow,
      );
    }
  }

/* Edit Profile Button */
  buildButton({String text, Function function}) {
    return Center(
      child: GestureDetector(
        onTap: function,
        child: Container(
          height: 30.0,
          width: 380.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3.0),
            border: Border.all(width: 0.3, color: Colors.black),
            // gradient: LinearGradient(
            //   begin: Alignment.topRight,
            //   end: Alignment.bottomLeft,
            //   colors: [
            //     Theme.of(context).accentColor,
            //     Color(0x000000),
            //     // Color(0xff597FDB),
            //   ],
            // ),
          ),
          child: Center(
            child: Text(
              text,
              style:
                  TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  handleUnfollow() async {
    DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
    users = UserModel.fromJson(doc.data());
    setState(() {
      isFollowing = false;
    });
    //remove follower
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId())
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //remove following
    followingRef
        .doc(currentUserId())
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //remove from notifications feeds
    notificationRef
        .doc(widget.profileId)
        .collection('notifications')
        .doc(currentUserId())
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollow() async {
    DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
    users = UserModel.fromJson(doc.data());
    setState(() {
      isFollowing = true;
    });
    //updates the followers collection of the followed user
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId())
        .set({});
    //updates the following collection of the currentUser
    followingRef
        .doc(currentUserId())
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});
    //update the notification feeds
    notificationRef
        .doc(widget.profileId)
        .collection('notifications')
        .doc(currentUserId())
        .set({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": users.username,
      "userId": users.id,
      "userDp": users.photoUrl,
      "timestamp": timestamp,
    });
  }

/*
  buildPostView() {
    if (isToggle == true) {
      return buildGridPost();
    } else if (isToggle == false) {
      return buildPosts();
    }
  }

  buildPosts() {
    return StreamBuilderWrapper(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      stream: postRef
          .where('ownerId', isEqualTo: widget.profileId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (_, DocumentSnapshot snapshot) {
        PostModel posts = PostModel.fromJson(snapshot.data());
        return Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Posts(
            post: posts,
          ),
        );
      },
    );
  }
*/

  buildGridPost() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: StreamGridWrapper(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        stream: postRef
            .where('ownerId', isEqualTo: widget.profileId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (_, DocumentSnapshot snapshot) {
          PostModel posts = PostModel.fromJson(snapshot.data());
          return PostTile(
            post: posts,
          );
        },
      ),
    );
  }

  buildLikeButton() {
    return StreamBuilder(
      stream: favUsersRef
          .where('postId', isEqualTo: widget.profileId)
          .where('userId', isEqualTo: currentUserId())
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> docs = snapshot?.data?.docs ?? [];
          return GestureDetector(
            onTap: () {
              if (docs.isEmpty) {
                favUsersRef.add({
                  'userId': currentUserId(),
                  'postId': widget.profileId,
                  'dateCreated': Timestamp.now(),
                });
              } else {
                favUsersRef.doc(docs[0].id).delete();
              }
            },
            child: Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 3.0,
                  blurRadius: 5.0,
                )
              ], color: Colors.white, shape: BoxShape.circle),
              child: Padding(
                padding: EdgeInsets.all(3.0),
                child: Icon(
                  docs.isEmpty
                      ? CupertinoIcons.heart
                      : CupertinoIcons.heart_fill,
                  color: Colors.red,
                ),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
