import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok/models/user_model.dart';
import 'package:tiktok/views/screens/profile_screen.dart';

import '../../controller/search_controller.dart';
 //import 'package:tiktok/controller/search_controller.dart';
//import 'package:tiktok/models/user.dart';

class SearchScreen extends StatelessWidget {
   SearchScreen({super.key});

  //final SearchController searchController = Get.put(SearchController());
  
  final  searchController = Get.put(MySearchController());
  final textCtr = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Obx(() =>
       Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: TextFormField(
            controller: textCtr,
            decoration: InputDecoration(
            filled: false,
            hintText: 'Search',
            hintStyle: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          onFieldSubmitted: (value) => searchController.searchUser(value),
          ),
        ),
        body: searchController.searchedUsers.isEmpty ? Center(
          child: Text('Search for users!',style: TextStyle(fontSize: 25,color: Colors.white,fontWeight: FontWeight.bold),),
        ): ListView.builder(
          itemCount: searchController.searchedUsers.length,
          itemBuilder: (context,index){
            User user = searchController.searchedUsers[index];
           return  InkWell(
               onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileScreen(uid: user.uid))),
               child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.profilePhoto),
                ),
                title: Text(user.name,style: TextStyle(
                  fontSize: 18,
                  color: Colors.white
                ),),
               ),
            );
      
        })
      ),
    );
  }
}