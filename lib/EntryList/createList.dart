import 'dart:ui';

import 'package:attendy/Database/DatabaseHelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import 'package:intl/intl.dart'; // For formatting date and time

class Createlist extends StatefulWidget {
  final String? vehicleNumber;
  final String? driverName;
  final String? date;
  final String? truckInTime;
  final String? truckOutTime;
  final String? selectedLocation;
  final bool isEdit; // New flag to indicate edit mode
  const Createlist({
    Key? key,
    this.vehicleNumber,
    this.driverName,
    this.date,
    this.truckInTime,
    this.truckOutTime,
    this.selectedLocation,
    this.isEdit = false, // Default is create mode
  }) : super(key: key);

  @override
  State<Createlist> createState() => _CreatelistState();
}

class _CreatelistState extends State<Createlist> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _dateController = TextEditingController();
  final _truckInController = TextEditingController();
  final _truckOutController = TextEditingController();

  bool _vehicleNumberError = false;
  bool _driverNameError = false;
  bool _dateError = false;
  bool _timeError = false;
  // bool _timeOutError = false;
  bool _locationError = false;

  String? _selectedLocation; // Variable to store selected location
  bool _isLoading = false;

  // List of locations
  final List<String> _locations = ['BALCO', 'DB POWER', 'LANCO', 'GEVERA' , 'KHUSMUNDA', 'DIPKA'];

  // Function to open date picker
  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
        _dateError = false;
      });
    }
  }

  // Function to open truck In time picker
  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        _truckInController.text = selectedTime.format(context);
        _timeError = false;
      });
    }
  }

  // Function to open Truck out time picker
  Future<void> _selectOutTime(BuildContext context) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        _truckOutController.text = selectedTime.format(context);
        // _timeOutError = false;
      });
    }
  }

  double? _latitude;
  double? _longitude;

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue accessing the position
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  Future<void> _saveData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current location before saving data
      await _getCurrentLocation();

      Map<String, dynamic> entry = {
        'vehicleNumber': _vehicleNumberController.text,
        'driverName': _driverNameController.text,
        'date': _dateController.text,
        'time': _truckInController.text,
        'timeout': _truckOutController.text,
        'location': _selectedLocation,
        'latitude': _latitude,
        'longitude': _longitude,
      };

      if (widget.isEdit) {
        // Update existing entry (add your update logic here)
        await DatabaseHelper().updateEntry(entry);
      } else {
        // Create new entry
        await DatabaseHelper().insertEntry(entry);
      }

      // Navigate back to previous screen
      Navigator.pop(context);
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  //initial time when the widget is created
  void _setInitialTime() {
    final now = TimeOfDay.now();
    _truckInController.text = now.format(context);
  }

//Use didChangeDependencies instead of initState:
//didChangeDependencies is called immediately after initState and
//is safe for accessing inherited dependencies.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Move any code from initState that relies on context here
    _setInitialTime(); //accessing the current time with context

    // Set initial date to current date
    _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  @override
  void initState() {
    super.initState();

    // Initialize controllers with passed values
    _vehicleNumberController.text = widget.vehicleNumber ?? '';
    _driverNameController.text = widget.driverName ?? '';
    _dateController.text = widget.date ?? '';
    _truckInController.text = widget.truckInTime ?? '';
    _truckOutController.text = widget.truckOutTime ?? '';

    // Initialize the selected location with the passed value (if in edit mode)
    _selectedLocation = widget.isEdit ? widget.selectedLocation : null;

    // Set truck out time to allow editing
    _truckOutController.text = widget.truckOutTime ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        foregroundColor: Colors.white,
        toolbarHeight: 80,
        backgroundColor: Colors.black,
        elevation: 5,
        title: const Text(
          "Vehicle Entry",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  TextFormField(
                    readOnly:
                        widget.isEdit, // Make it read-only if in edit mode
                    controller: _vehicleNumberController,
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: 'Vehicle Number',
                        errorText: _vehicleNumberError
                            ? 'Please enter vehicle number'
                            : null,
                        labelStyle: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w400)),
                    onChanged: (value) {
                      setState(() {
                        _vehicleNumberError = false;
                      });
                    },
                  ),
                  const SizedBox(height: 25),
                  TextFormField(
                    readOnly:
                        widget.isEdit, // Make it read-only if in edit mode
                    controller: _driverNameController,
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: 'Driver Name',
                        errorText: _driverNameError
                            ? 'Please enter driver name'
                            : null,
                        labelStyle: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w400)),
                    onChanged: (value) {
                      setState(() {
                        _driverNameError = false;
                      });
                    },
                  ),
                  const SizedBox(height: 25),
                  TextFormField(
                    readOnly: true,
                       
                    controller: _dateController,

                    // onTap: () => _selectDate(context), // Open date picker
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: 'Date',
                        errorText: _dateError ? 'Please select a date' : null,
                        labelStyle: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w400)),
                  ),

                  SizedBox(
                    height: 25,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _truckInController,
                          readOnly: true,
                          // onTap: () => _selectTime(context), // Open time picker
                          decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 2, 37,
                                      99), // Border color when focused
                                  width:
                                      2.0, // Increased border width when focused
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: 'Truck In',
                              errorText:
                                  _timeError ? 'Please select a time' : null,
                              labelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400)),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _truckOutController,
                          readOnly: widget
                              .isEdit, // Make it read-only if in edit mode
                          onTap: () =>
                              _selectOutTime(context), // Open time picker
                          decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 2, 37,
                                      99), // Border color when focused
                                  width:
                                      2.0, // Increased border width when focused
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: 'Truck Out',
                              // errorText:
                              //     _timeOutError ? 'Please select a time' : null,
                              labelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400)),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 25,
                  ),
                  // DropdownButtonFormField for Location

                  DropdownButtonFormField<String>(
                    value: _selectedLocation,
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: 'Choose Location',
                      errorText:
                          _locationError ? 'Please select a location' : null,
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    items: _locations.map((location) {
                      return DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    onChanged: widget.isEdit
                        ? null // Disable the dropdown in edit mode
                        : (value) {
                            setState(() {
                              _selectedLocation = value;
                              _locationError = false;
                            });
                          },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a location';
                      }
                      return null;
                    },
                    // This enables/disables the dropdown based on edit mode
                    onTap: () {
                      if (widget.isEdit) {
                        // Prevent dropdown from opening in edit mode
                        FocusScope.of(context)
                            .unfocus(); // Dismiss the keyboard if necessary
                      }
                    },
                    // Set the enabled property
                    // enabled: !widget.isEdit,
                  ),

                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback
                          .vibrate(); // Trigger vibration on button press
                      setState(() {
                        _vehicleNumberError =
                            _vehicleNumberController.text.isEmpty;
                        _driverNameError = _driverNameController.text.isEmpty;
                        _dateError = _dateController.text.isEmpty;
                        _timeError = _truckInController.text.isEmpty;
                        // _timeOutError = _truckOutController.text.isEmpty;
                        _locationError = _selectedLocation == null;
                      });

                      if (!_vehicleNumberError &&
                          !_driverNameError &&
                          !_dateError &&
                          !_timeError &&
                          !_locationError) {
                        _saveData();
                      }
                    },
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Show blur effect and loader when `isLoading` is true
          if (_isLoading) ...[
            // Add a blur effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black
                    .withOpacity(0.2), // Adjust opacity for dimming effect
              ),
            ),
            // Center the loader on the screen
            Center(
              child: CupertinoActivityIndicator(
                radius: 20.0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
