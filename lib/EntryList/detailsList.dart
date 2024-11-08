import 'package:attendy/Database/DatabaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'createList.dart';

class Detailslist extends StatefulWidget {
  const Detailslist({super.key});

  @override
  State<Detailslist> createState() => _DetailslistState();
}

class _DetailslistState extends State<Detailslist> {
  List<Map<String, dynamic>> _entries = [];
  List<Map<String, dynamic>> _filteredEntries = []; // For filtered results
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print("list ${_entries.length}");
    _fetchEntries();
    _searchController
        .addListener(_filterEntries); // Listen for changes in the search box
  }

  Future<void> _fetchEntries() async {
    List<Map<String, dynamic>> entries = await DatabaseHelper().fetchEntries();
    setState(() {
      _entries = entries.reversed.toList(); // Store all entries
      _filteredEntries = _entries; // Initialize filtered list with all entries
    });
  }

  // Filter entries based on the search query
  void _filterEntries() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      // If the query is empty, show all entries
      _filteredEntries = query.isEmpty
          ? _entries // Show all entries if search is empty
          : _entries.where((entry) {
              return entry['vehicleNumber']
                  .toString()
                  .toLowerCase()
                  .contains(query);
            }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose of the controller when not needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        toolbarHeight: 80,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 5,
        title: const Text(
          "Register Entry",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body:  _entries.isNotEmpty ? Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 15),
            child: TextField(
              style: TextStyle(color: Colors.white, fontSize: 16),
              controller: _searchController,
              decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color.fromARGB(
                        255, 2, 37, 99), // Border color when focused
                    width: 2.0, // Increased border width when focused
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                hintText: 'Search by Vehicle Number',
                hintStyle: TextStyle(color: Colors.black45),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 1),
              itemCount: _filteredEntries.length, // Use filtered list
              itemBuilder: (context, index) {
                final entry = _filteredEntries[index];
                return Container(
                  
                  margin:
                      const EdgeInsets.only(left: 3.0, right: 3, bottom: 10),
                  
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
                  child: ListTile(
                    contentPadding: EdgeInsets.only(
                        left: 30, right: 30, bottom: 10, top: 10),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Vehicle Number:  ",
                          style: const TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 18),
                        ),
                        Text(
                          "${entry['vehicleNumber']}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          height: 15,
                          thickness: 1,
                          color: Colors.black,
                        ),
                        buildRow("Driver", "${entry['driverName']}"),
                        buildRow("Date", "${entry['date']}"),
                        buildRow("Time In", "${entry['time']}"),
                        buildRow("Time Out", "${entry['timeout']}"),
                        buildRow("Location", "${entry['location']}"),
                        buildRow("Latitude", "${entry['latitude']}"),
                        buildRow("Longitude", "${entry['longitude']}"),
                      ],
                    ),
                    onTap: () {
                      print("Location  ===> ${entry['location']}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Createlist(
                            vehicleNumber: entry['vehicleNumber'],
                            driverName: entry['driverName'],
                            date: entry['date'],
                            truckInTime: entry['time'],
                            truckOutTime: entry['timeout'],
                            selectedLocation: entry['location'],
                            isEdit:
                                true, // Indicate that this is an edit operation
                          ),
                        ),
                      ).then((_) {
                        _fetchEntries(); // Refresh the list after editing
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ) : Center(child: Lottie.asset('assets/empty.json')),
      floatingActionButton: SizedBox(
        height: 60,
        width: 60,
        child: FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: () {
            HapticFeedback.vibrate(); // Trigger vibration on button press
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Createlist()),
            ).then((_) {
              _fetchEntries(); // Refresh the list after returning
            });
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 35,
          ),
        ),
      ),
    );
  }

  Widget buildRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: value.isEmpty
                  ? const Color.fromARGB(255, 255, 0, 0)
                  : Colors.black,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            ":",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 9,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
