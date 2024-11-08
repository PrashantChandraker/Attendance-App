import 'package:attendy/Database/DatabaseHelper.dart';
import 'package:attendy/EntryList/detailsList.dart';
import 'package:attendy/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // For formatting date/time
import 'package:flutter/services.dart'; // For Haptic Feedback

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = '';
  String checkIn = '--/--';
  String checkOut = '--/--';
  bool isCheckedIn = false;
  // Color avatarColor = Colors.red; // Default avatar color is red
  String duration = '0h 0m 0s'; // Duration default value
  String message = ''; // Message to display completion status

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCheckInData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? ''; // Load email
    setState(() {
      // Extract username from email
      username = email.split('@')[0]; // Get part before "@"
    });
  }

  Future<void> _loadCheckInData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      checkIn = prefs.getString('checkIn') ?? '--/--';
      checkOut = prefs.getString('checkOut') ?? '--/--';
      isCheckedIn = checkIn != '--/--';
      // avatarColor = isCheckedIn ? Colors.green : Colors.red;
      duration = _calculateDuration(); // Load initial duration
      message = _getCompletionMessage(); // Load initial completion message
    });
  }

  Future<void> _toggleCheckIn() async {
    HapticFeedback.vibrate(); // Trigger vibration on button press
    final prefs = await SharedPreferences.getInstance();
    final currentTime = DateFormat('HH:mm:ss').format(DateTime.now());

    if (isCheckedIn) {
      // Check Out
      await prefs.setString('checkOut', currentTime);
      setState(() {
        checkOut = currentTime;
        isCheckedIn = false;
        // avatarColor = Colors.red; // Change color to red on check out
      });
    } else {
      // Check In
      await prefs.setString('checkIn', currentTime);
      setState(() {
        checkIn = currentTime;
        isCheckedIn = true;
        // avatarColor = Colors.green; // Change color to green on check in
      });
    }
    // Update the duration and message after check-in or check-out
    duration = _calculateDuration();
    message = _getCompletionMessage();
  }

  String _calculateDuration() {
    if (checkIn != '--/--' && checkOut != '--/--') {
      DateTime checkInTime = DateFormat('HH:mm:ss').parse(checkIn);
      DateTime checkOutTime = DateFormat('HH:mm:ss').parse(checkOut);
      Duration diff = checkOutTime.difference(checkInTime);
      return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m ${diff.inSeconds.remainder(60)}s'; // Format duration with seconds
    }
    return '0h 0m 0s'; // Default if no check-in/check-out
  }

  String _getCompletionMessage() {
    if (checkIn != '--/--' && checkOut != '--/--') {
      return 'Today completed'; // Message when both check-in and check-out are done
    }
    return ''; // Default empty message
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data from SharedPreferences
    await DatabaseHelper().deleteAllEntries();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const Loginscreen())); // Navigate to LoginScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'W',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      TextSpan(
                        text: 'elcome',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  " $username", // Displaying the username
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            TextButton(
              onPressed: () async {
                bool? confirmLogout = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Confirm Logout"),
                      content: const Text(
                        "Are you sure you want to logout?",
                        style: TextStyle(color: Colors.deepOrange),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context)
                                .pop(false); // Close the dialog
                          },
                        ),
                        TextButton(
                          child: const Text(
                            "Logout",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(true); // Confirm logout
                          },
                        ),
                      ],
                    );
                  },
                );

                if (confirmLogout == true) {
                  _logout(); // Call the logout function if confirmed
                }
              },
              child: const Icon(
                Icons.logout,
                color: Colors.redAccent,
                size: 30,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            SizedBox(height:10,),
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 32),
              height: 100,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 5,
                    offset: Offset(2, 2),
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Check In',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          checkIn,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Check Out',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          checkOut,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
           SizedBox(height: 100,),
            checkOut == '--/--'
                ? GestureDetector(
                    onTap: _toggleCheckIn, // Toggle check-in/out
                    child: SizedBox(
                      height: 150,
                      width: 150,
                      child: AnimatedContainer(
                        duration: const Duration(
                            milliseconds: 1000), // Smooth transition
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: isCheckedIn
                                ? [Colors.green.shade300, Colors.green.shade900]
                                : [Colors.blue.shade300, Colors.blue.shade900],
                            center: Alignment.center,
                            radius: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.7),
                              spreadRadius: 1,
                              blurRadius: 15,
                              offset:
                                  const Offset(2, 5), // Shadow for 3D effect
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isCheckedIn ? 'Punch Out' : "Punch In",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            shadows: [
                              Shadow(
                                offset: Offset(1.5, 1.5),
                                blurRadius: 3.0,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : const Text(
                    'You already punched today!!',
                    style: TextStyle(
                      fontSize: 24,
                      color: Color.fromARGB(255, 142, 1, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            const SizedBox(height: 10),
            Text(
              'Duration:  $duration',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                HapticFeedback.vibrate(); // Trigger vibration on button press
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Detailslist()));
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.5), // Shadow color with opacity
                      spreadRadius: 2, // Spread of the shadow
                      blurRadius: 5, // Blur intensity of the shadow
                      offset:
                          Offset(0, 5), // Offset of the shadow: x-axis, y-axis
                    ),
                  ],
                  color: Colors.black,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
