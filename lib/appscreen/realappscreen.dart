
import 'package:flutter/material.dart';
import 'package:growi_project/appscreen/Form.dart';
import 'package:growi_project/appscreen/homescreen.dart';
import 'package:growi_project/appscreen/store.dart';
import 'package:growi_project/appscreen/thetick.dart';
import 'package:growi_project/appscreen/ticketstab.dart';
import 'package:growi_project/userdashbord.dart';


class RealHome extends StatefulWidget {
  final String name;
  final String email;

  const RealHome({super.key, required this.name, required this.email, });
  @override
  State<RealHome> createState() => _RealHomeState();
}
class _RealHomeState extends State<RealHome> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // Drawer for side popout for profile and other options
        drawer: _buildDrawer(), //Side popout
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer(); //  opens from LEFT
              },
            ),
          ),
          title: const Text(
            'Welcome',
            style: TextStyle(color: Colors.black, fontSize: 25),
          ),
          backgroundColor: const Color(0xFFF8EED2),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            tabs: [
              //classes for the two tabs will have these names
              Tab(text: 'Tickets'),
              Tab(text: 'Stores'),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFF8EED2),
        body: TabBarView(
          //these TabBarView will have the content of the two tabs in a form of a Row
          children: [
            //classes for the two tabs will be called here
            const Tickets(),
            const IStoreScreen(),
          ],
        ),
      ),
    );
  }
  Drawer _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Profile Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    child: Text(
                      widget.email.isNotEmpty ? widget.email[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name.isNotEmpty ? widget.name : 'User',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.email,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  )
                ],
              ),
            ),
      // Below the profile header, we will have a list of options for the user to navigate to different pages in the app
            const Divider(),
            _drawerItem(//all actions made by the user (e.g buying a ticket or produts )will appear here
              icon: Icons.person_outline,
              title: 'DashBoard',
              onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const  UserDashboard()));},
            ),
            _drawerItem(
              icon: Icons.person_outline,
              title: 'Update Profile',
              onTap: () {},
            ),
           
            _drawerItem(
              icon: Icons.confirmation_number_outlined,
              title: 'Organize Event',
              onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context)=>EventApplicationPage()));},
            ),
            //this will  later be used to create a business for the user to sell their products in the app
            /*      
            _drawerItem(
              icon:Icons.storefront_outlined,
              title: 'Create A business',
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(builder: (context) => const Business()),
                );
                if (result != null) {
                  setState(() {
                    _businesses.insert(0, result);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Business added to Buyiest')));
                }
              },
            ),*/
            _drawerItem(
              icon: Icons.help_outline,
              title: 'Help',
              onTap: () {},
            ),
            const Divider(),

            _drawerItem(
              icon: Icons.logout,
              title: 'Logout',
              textColor: Colors.red,
              onTap: () {
               showDialog(context: context, builder: (context) {
                 return AlertDialog(
                   title: const Text('Logout'),
                   content: const Text('Are you sure you want to logout?'),
                   actions: [
                     TextButton(
                       onPressed: () {
                         Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomePage()), (route) => false);
                       },
                       child: const Text('Yes'),
                     ),
                     TextButton(
                       onPressed: () {
                         Navigator.pop(context);
                       },
                       child: const Text('No'),
                     ),
                   ],
                 );
               });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      onTap: onTap,
    );
  }


}
